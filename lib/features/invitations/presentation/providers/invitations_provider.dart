import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/services/invitation_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';

/// Provider for the InvitationService.
final invitationServiceProvider = Provider<InvitationService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final db = ref.watch(databaseProvider);
  final hook = ref.watch(notificationHookProvider);
  return InvitationService(supabase: supabase, db: db, notificationHook: hook);
});

/// Streams pending invitations reactively for the current user.
final pendingInvitationsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.email == null) {
    yield [];
    return;
  }

  final service = ref.read(invitationServiceProvider);
  final supabase = ref.read(supabaseServiceProvider).client;

  // 1. Initial fetch independently (to avoid being blocked by websocket timeouts)
  try {
    yield await service.getPendingInvitations(user.email!);
  } catch (e) {
    debugPrint('❌ [InvitationsProvider] Initial fetch failed: $e');
    yield []; // fall back to empty or let error propagate
  }

  // 2. Real-time stream
  try {
    final stream = supabase
        .from('goal_invitations')
        .stream(primaryKey: ['id'])
        .eq('invitee_email', user.email!);

    // skip(1) because the stream emits the current state upon connecting, 
    // which we already fetched above.
    await for (final _ in stream.skip(1)) {
      yield await service.getPendingInvitations(user.email!);
    }
  } catch (e) {
    debugPrint('⚠️ [InvitationsProvider] Realtime connection timeout/error: $e');
    // If the websocket connection fails, the provider just continues with 
    // the last yielded value. The UI won't crash.
  }
});

/// Count of pending invitations (for badge display).
final pendingInvitationCountProvider = Provider<int>((ref) {
  final invitations = ref.watch(pendingInvitationsProvider).valueOrNull;
  return invitations?.length ?? 0;
});
