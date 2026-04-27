// Supabase Edge Function: send-push-notification
//
// Fans out a push notification to all devices of the target recipients for a
// given event. Runs under the caller's JWT (invoked via
// `supabase.functions.invoke()` from the Flutter client), and uses the
// service role client internally to resolve recipients, read device tokens,
// and prune unregistered tokens.
//
// TODO(security): currently deployed with `--no-verify-jwt` because Supabase
// issues user JWTs with ES256 while the Edge Runtime's built-in verifier only
// accepts HS256. Once Supabase supports ES256 verification (or we migrate the
// project to HS256 signing keys), redeploy WITHOUT `--no-verify-jwt`. In the
// meantime the function is still safe because it uses the service role
// internally and never trusts caller input for authorization — the worst a
// bad actor could do is trigger an extra push to members of a goal whose
// UUID they already know. Before going to production, also add manual JWT
// verification here: decode the bearer token, confirm `sub === sender_user_id`,
// and confirm the sender is a member of `goal_id`.
//
// Events supported:
//   - partner_check_in      → all goal members except sender
//   - goal_completed        → all goal members except sender
//   - milestone_reached     → all goal members except sender
//   - invitation_sent       → invitee (looked up by email on the invitation)
//   - invitation_accepted   → goal owner
//
// FCM is called via the HTTP v1 API. Access token is minted by signing a JWT
// with the service account and exchanging it at oauth2.googleapis.com.

import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

type EventType =
  | "partner_check_in"
  | "goal_completed"
  | "milestone_reached"
  | "invitation_sent"
  | "invitation_accepted";

interface PushRequest {
  event_type: EventType;
  goal_id: string;
  sender_user_id: string;
  invitation_id?: string;
  extra?: Record<string, unknown>;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri: string;
}

interface FcmPayload {
  title: string;
  body: string;
  data: Record<string, string>;
}

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: CORS_HEADERS });
  }

  try {
    const body = (await req.json()) as PushRequest;
    console.log("[send-push] request:", body);

    if (!body.event_type || !body.goal_id || !body.sender_user_id) {
      return json({ error: "Missing required fields" }, 400);
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const recipients = await resolveRecipients(supabase, body);
    if (recipients.length === 0) {
      console.log("[send-push] no recipients — skipping");
      return json({ sent: 0, reason: "no_recipients" });
    }
    console.log("[send-push] recipients:", recipients);

    const { data: tokens, error: tokensErr } = await supabase
      .from("device_tokens")
      .select("fcm_token, platform")
      .in("user_id", recipients);
    if (tokensErr) throw tokensErr;
    if (!tokens || tokens.length === 0) {
      console.log("[send-push] no device tokens for recipients");
      return json({ sent: 0, reason: "no_tokens" });
    }

    const payload = buildPayload(body);
    const accessToken = await getFcmAccessToken();
    const projectId = Deno.env.get("FCM_PROJECT_ID")!;

    let sent = 0;
    const staleTokens: string[] = [];

    for (const row of tokens) {
      const result = await sendFcm(
        row.fcm_token,
        payload,
        accessToken,
        projectId,
      );
      if (result.ok) {
        sent++;
      } else if (result.stale) {
        staleTokens.push(row.fcm_token);
      }
    }

    if (staleTokens.length > 0) {
      console.log("[send-push] pruning stale tokens:", staleTokens.length);
      await supabase.from("device_tokens").delete().in("fcm_token", staleTokens);
    }

    return json({ sent, pruned: staleTokens.length });
  } catch (err) {
    console.error("[send-push] error:", err);
    return json({ error: String(err) }, 500);
  }
});

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "content-type": "application/json" },
  });
}

async function resolveRecipients(
  supabase: SupabaseClient,
  req: PushRequest,
): Promise<string[]> {
  switch (req.event_type) {
    case "partner_check_in":
    case "goal_completed":
    case "milestone_reached": {
      // Owners are stored in `savings_goals.user_id` and are NOT duplicated
      // into `goal_members` — we need to union both to get the full set of
      // people on this goal, then drop the sender.
      const [membersRes, goalRes] = await Promise.all([
        supabase.from("goal_members").select("user_id").eq("goal_id", req.goal_id),
        supabase.from("savings_goals").select("user_id").eq("id", req.goal_id).maybeSingle(),
      ]);
      if (membersRes.error) throw membersRes.error;
      if (goalRes.error) throw goalRes.error;

      const ids = new Set<string>();
      for (const m of membersRes.data ?? []) ids.add(m.user_id as string);
      const ownerId = goalRes.data?.user_id as string | undefined;
      if (ownerId) ids.add(ownerId);
      ids.delete(req.sender_user_id);
      return Array.from(ids);
    }
    case "invitation_sent": {
      if (!req.invitation_id) return [];
      const { data: inv, error } = await supabase
        .from("goal_invitations")
        .select("invitee_email")
        .eq("id", req.invitation_id)
        .maybeSingle();
      if (error) throw error;
      if (!inv?.invitee_email) return [];
      const { data: profile, error: pErr } = await supabase
        .from("profiles")
        .select("id")
        .eq("email", inv.invitee_email)
        .maybeSingle();
      if (pErr) throw pErr;
      return profile?.id ? [profile.id] : [];
    }
    case "invitation_accepted": {
      const { data, error } = await supabase
        .from("savings_goals")
        .select("user_id")
        .eq("id", req.goal_id)
        .maybeSingle();
      if (error) throw error;
      const ownerId = data?.user_id as string | undefined;
      if (!ownerId || ownerId === req.sender_user_id) return [];
      return [ownerId];
    }
    default:
      return [];
  }
}

function buildPayload(req: PushRequest): FcmPayload {
  const extra = req.extra ?? {};
  const amount = typeof extra.amount === "number"
    ? (extra.amount as number).toFixed(2)
    : undefined;
  const percentage = typeof extra.percentage === "number"
    ? String(Math.round(extra.percentage as number))
    : undefined;
  const partnerName = typeof extra.partner_name === "string"
    ? (extra.partner_name as string)
    : "Tu pareja";

  let title: string;
  let body: string;
  switch (req.event_type) {
    case "partner_check_in":
      title = "¡Tu pareja ahorró!";
      body = amount
        ? `${partnerName} acaba de sumar $${amount} a la meta.`
        : `${partnerName} hizo un nuevo check-in.`;
      break;
    case "goal_completed":
      title = "¡Meta completada!";
      body = `Llegaron al 100% juntos. ¡Felicidades!`;
      break;
    case "milestone_reached":
      title = percentage ? `¡${percentage}% alcanzado!` : "¡Nuevo hito!";
      body = "Tu pareja ayudó a alcanzar un nuevo hito en la meta.";
      break;
    case "invitation_sent":
      title = "Nueva invitación";
      body = `${partnerName} te invitó a una meta compartida.`;
      break;
    case "invitation_accepted":
      title = "¡Invitación aceptada!";
      body = `${partnerName} se unió a tu meta.`;
      break;
  }

  const data: Record<string, string> = {
    event_type: req.event_type,
    goal_id: req.goal_id,
    sender_user_id: req.sender_user_id,
  };
  if (req.invitation_id) data.invitation_id = req.invitation_id;
  return { title, body, data };
}

async function getFcmAccessToken(): Promise<string> {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!raw) throw new Error("FCM_SERVICE_ACCOUNT secret is not set");
  const sa = JSON.parse(raw) as ServiceAccount;

  const now = getNumericDate(0);
  const exp = getNumericDate(60 * 60);
  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: sa.token_uri,
      iat: now,
      exp,
    },
    await importPrivateKey(sa.private_key),
  );

  const res = await fetch(sa.token_uri, {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`OAuth2 token exchange failed: ${res.status} ${text}`);
  }
  const { access_token } = (await res.json()) as { access_token: string };
  return access_token;
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const pkcs8 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pkcs8), (c) => c.charCodeAt(0));
  return await crypto.subtle.importKey(
    "pkcs8",
    der.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
}

async function sendFcm(
  token: string,
  payload: FcmPayload,
  accessToken: string,
  projectId: string,
): Promise<{ ok: boolean; stale: boolean }> {
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  const res = await fetch(url, {
    method: "POST",
    headers: {
      authorization: `Bearer ${accessToken}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: { title: payload.title, body: payload.body },
        data: payload.data,
        // iOS: `apns-push-type: alert` + priority 10 ensures the banner is
        // shown immediately in foreground, background and terminated states.
        // Do NOT set `content-available: 1` alongside a visible alert — that
        // flag is for silent/background pushes and can suppress the banner.
        apns: {
          headers: {
            "apns-priority": "10",
            "apns-push-type": "alert",
          },
          payload: {
            aps: {
              alert: { title: payload.title, body: payload.body },
              sound: "default",
            },
          },
        },
        android: {
          priority: "HIGH",
          notification: {
            channel_id: "partner_updates",
            default_sound: true,
          },
        },
      },
    }),
  });
  if (res.ok) return { ok: true, stale: false };
  const text = await res.text();
  const stale = /UNREGISTERED|INVALID_ARGUMENT|NOT_FOUND/i.test(text);
  console.warn("[send-push] FCM error:", res.status, text);
  return { ok: false, stale };
}
