import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import 'push_notification_service.dart';
import 'supabase_service.dart';

/// Service managing invitation lifecycle: create, accept, reject, deep links.
class InvitationService {
  final SupabaseService _supabase;
  // ignore: unused_field — used in future phases for local caching
  final AppDatabase _db;

  InvitationService({
    required SupabaseService supabase,
    required AppDatabase db,
  })  : _supabase = supabase,
        _db = db;

  /// Send an invitation for a couple goal.
  Future<String> sendInvitation({
    required String goalId,
    required String inviterUserId,
    required String inviteeEmail,
  }) async {
    final invitationId = const Uuid().v4();
    final now = DateTime.now();

    final data = {
      'id': invitationId,
      'goal_id': goalId,
      'inviter_id': inviterUserId,
      'invitee_email': inviteeEmail,
      'status': 'pending',
      'created_at': now.toIso8601String(),
    };

    try {
      await _supabase.createInvitation(data);
      debugPrint('✅ [InvitationService] Invitation sent — goalId: $goalId | to: $inviteeEmail | invId: $invitationId');
    } catch (e) {
      debugPrint('❌ [InvitationService] Send failed — goalId: $goalId | to: $inviteeEmail | error: $e');
      rethrow;
    }

    // Fire-and-forget push to the invitee. Failure here must not break the
    // invitation flow — the row is already created in Supabase.
    sendPushEvent(
      _supabase.client,
      eventType: 'invitation_sent',
      goalId: goalId,
      senderUserId: inviterUserId,
      invitationId: invitationId,
    ).ignore();

    return invitationId;
  }

  /// Fetch pending invitations for the current user's email.
  Future<List<Map<String, dynamic>>> getPendingInvitations(String email) async {
    debugPrint('📥 [InvitationService] Fetching pending invitations — email: $email');
    try {
      final result = await _supabase.fetchPendingInvitations(email);
      debugPrint('📥 [InvitationService] Found ${result.length} pending invitations');
      return result;
    } catch (e) {
      debugPrint('❌ [InvitationService] Fetch failed — email: $email | error: $e');
      return [];
    }
  }

  /// Accept an invitation — calls the server-side RPC for transactional safety.
  /// [acceptedByUserId] is the id of the user accepting the invitation; used
  /// to notify the goal owner via push. Optional for backwards compatibility.
  Future<void> acceptInvitation(String invitationId, {String? acceptedByUserId}) async {
    debugPrint('❤️ [InvitationService] Accepting invitation — id: $invitationId');
    try {
      await _supabase.acceptInvitation(invitationId);
      debugPrint('✅ [InvitationService] Invitation accepted — id: $invitationId');

      // No local notification for the accepter — they just tapped "Accept"
      // and the screen already shows a success snackbar. The inviter is
      // notified via FCM push below.

      // Fire-and-forget push to the goal owner. We need the goal_id from the
      // invitation row — look it up post-accept (the row still exists, status
      // just changed to `accepted`).
      if (acceptedByUserId != null) {
        try {
          final inv = await _supabase.client
              .from('goal_invitations')
              .select('goal_id')
              .eq('id', invitationId)
              .maybeSingle();
          final goalId = inv?['goal_id'] as String?;
          if (goalId != null) {
            sendPushEvent(
              _supabase.client,
              eventType: 'invitation_accepted',
              goalId: goalId,
              senderUserId: acceptedByUserId,
              invitationId: invitationId,
            ).ignore();
          }
        } catch (e) {
          debugPrint('⚠️ [InvitationService] push lookup failed: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ [InvitationService] Accept failed — id: $invitationId | error: $e');
      rethrow;
    }
  }

  /// Reject an invitation.
  Future<void> rejectInvitation(String invitationId) async {
    debugPrint('🚫 [InvitationService] Rejecting invitation — id: $invitationId');
    try {
      await _supabase.rejectInvitation(invitationId);
      debugPrint('✅ [InvitationService] Invitation rejected — id: $invitationId');
    } catch (e) {
      debugPrint('❌ [InvitationService] Reject failed — id: $invitationId | error: $e');
      rethrow;
    }
  }

  /// Generate a deep link for sharing an invitation.
  String generateDeepLink(String invitationId) {
    return 'kipera://invite?id=$invitationId';
  }
}
