/// Abstract hook for notification events.
/// Implementations can send push notifications, local notifications,
/// analytics events, or any other side-effect.
///
/// The default [NoOpNotificationHook] does nothing — swap in a real
/// implementation (e.g. FCM-based) when push notifications are set up.
///
/// Integration points:
///   - SyncService.pullRemoteChanges() → onPartnerCheckIn, onInvitationReceived
///   - InvitationService.acceptInvitation() → onInvitationAccepted
///   - CheckInScreen._checkIn() → onMilestoneReached, onGoalCompleted
abstract class NotificationHook {
  /// Called when a partner completes a check-in on a shared goal.
  /// [goalId] The shared goal ID.
  /// [partnerId] The partner's user ID.
  /// [amount] The amount saved by the partner.
  Future<void> onPartnerCheckIn(String goalId, String partnerId, double amount);

  /// Called when the current user receives a new invitation.
  /// [goalId] The goal to which the user is invited.
  /// [inviterName] Display name of the person who sent the invitation.
  Future<void> onInvitationReceived(String goalId, String inviterName);

  /// Called when a partner accepts the user's invitation.
  /// [goalId] The goal for which the invitation was accepted.
  /// [partnerName] Display name of the partner who accepted.
  Future<void> onInvitationAccepted(String goalId, String partnerName);

  /// Called when a goal reaches 100% completion.
  /// [goalId] The completed goal ID.
  Future<void> onGoalCompleted(String goalId);

  /// Called when a goal reaches a milestone (25%, 50%, 75%).
  /// [goalId] The goal ID.
  /// [percentage] The milestone percentage reached.
  Future<void> onMilestoneReached(String goalId, double percentage);
}

/// Default no-op implementation — does nothing.
/// Replace with FCM/APNs implementation when push notifications are added.
class NoOpNotificationHook implements NotificationHook {
  const NoOpNotificationHook();

  @override
  Future<void> onPartnerCheckIn(String goalId, String partnerId, double amount) async {}

  @override
  Future<void> onInvitationReceived(String goalId, String inviterName) async {}

  @override
  Future<void> onInvitationAccepted(String goalId, String partnerName) async {}

  @override
  Future<void> onGoalCompleted(String goalId) async {}

  @override
  Future<void> onMilestoneReached(String goalId, double percentage) async {}
}
