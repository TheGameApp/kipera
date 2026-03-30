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

  // Listen for real-time changes on the invitations table
  final stream = supabase
      .from('goal_invitations')
      .stream(primaryKey: ['id'])
      .eq('invitee_email', user.email!);

  // Yield new fully-joined queries every time the underlying rows change
  await for (final _ in stream) {
    yield await service.getPendingInvitations(user.email!);
  }
});

/// Count of pending invitations (for badge display).
final pendingInvitationCountProvider = Provider<int>((ref) {
  final invitations = ref.watch(pendingInvitationsProvider).valueOrNull;
  return invitations?.length ?? 0;
});
