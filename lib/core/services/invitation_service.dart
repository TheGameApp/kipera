import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../database/app_database.dart';
import 'notification_hook.dart';
import 'supabase_service.dart';

/// Service managing invitation lifecycle: create, accept, reject, deep links.
class InvitationService {
  final SupabaseService _supabase;
  // ignore: unused_field — used in future phases for local caching
  final AppDatabase _db;
  final NotificationHook _notificationHook;

  InvitationService({
    required SupabaseService supabase,
    required AppDatabase db,
    NotificationHook notificationHook = const NoOpNotificationHook(),
  })  : _supabase = supabase,
        _db = db,
        _notificationHook = notificationHook;

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
  Future<void> acceptInvitation(String invitationId) async {
    debugPrint('❤️ [InvitationService] Accepting invitation — id: $invitationId');
    try {
      await _supabase.acceptInvitation(invitationId);
      debugPrint('✅ [InvitationService] Invitation accepted — id: $invitationId');

      // 🔔 Notification hook
      await _notificationHook.onInvitationAccepted(invitationId, '');
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
