import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/kipera_snackbar.dart';
import '../providers/invitations_provider.dart';
import '../widgets/invitation_card.dart';
import '../../../../core/providers/sync_provider.dart';

class InvitationsScreen extends ConsumerStatefulWidget {
  const InvitationsScreen({super.key});

  @override
  ConsumerState<InvitationsScreen> createState() => _InvitationsScreenState();
}

class _InvitationsScreenState extends ConsumerState<InvitationsScreen> {
  String? _processingId;

  Future<void> _accept(String invitationId, String goalId, Map<String, dynamic> goalData) async {
    final l10n = context.l10n;
    debugPrint(
      '❤️ [InvitationsScreen] Accepting invitation — id: $invitationId',
    );
    setState(() => _processingId = invitationId);
    try {
      final service = ref.read(invitationServiceProvider);
      await service.acceptInvitation(invitationId);
      ref.invalidate(pendingInvitationsProvider);
      debugPrint(
        '✅ [InvitationsScreen] Invitation accepted — id: $invitationId',
      );

      // Trigger a sync so the new goal and members appear immediately on HomeScreen
      ref.read(syncServiceProvider).syncAll();

      // Schedule local notification if reminder_time is set
      debugPrint('📋 [InvitationsScreen] Checking method_config for goal: $goalId');
      final dynamic rawConfig = goalData['method_config'];
      Map<String, dynamic> methodConfig = {};

      if (rawConfig is Map<String, dynamic>) {
        debugPrint('📋 [InvitationsScreen] method_config is Map');
        methodConfig = rawConfig;
      } else if (rawConfig is String) {
        debugPrint('📋 [InvitationsScreen] method_config is String, attempting to decode JSON');
        try {
          methodConfig = jsonDecode(rawConfig) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('❌ [InvitationsScreen] Failed to decode method_config String: $e');
        }
      } else {
        debugPrint('⚠️ [InvitationsScreen] method_config is unknown type: ${rawConfig.runtimeType} or null');
      }

      final reminderHour = methodConfig['reminderHour'] as int?;
      final reminderMinute = methodConfig['reminderMinute'] as int?;

      if (reminderHour != null && reminderMinute != null) {
        final name = goalData['name'] as String? ?? 'Joint Goal';
        debugPrint('🔔 [InvitationsScreen] Found reminder logic — Time: $reminderHour:$reminderMinute for Goal: "$name"');
        
        await NotificationService().scheduleDailyReminder(
          goalId: goalId,
          hour: reminderHour,
          minute: reminderMinute,
          title: l10n.timeToSave,
          body: l10n.notificationBodyJoint(name),
        );
        debugPrint('✅ [InvitationsScreen] Joint Goal reminder scheduled successfully');
      } else {
        debugPrint('ℹ️ [InvitationsScreen] No valid reminderHour/reminderMinute in method_config. Skipping notifications.');
      }

      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: l10n.invitationAcceptedSuccess,
          type: KiperaSnackType.success,
          icon: Icons.favorite,
        );
      }
    } catch (e) {
      debugPrint(
        '❌ [InvitationsScreen] Accept failed — id: $invitationId | error: $e',
      );
      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: l10n.invitationAcceptedError,
          type: KiperaSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _reject(String invitationId) async {
    final l10n = context.l10n;
    debugPrint(
      '🚫 [InvitationsScreen] Rejecting invitation — id: $invitationId',
    );
    setState(() => _processingId = invitationId);
    try {
      final service = ref.read(invitationServiceProvider);
      await service.rejectInvitation(invitationId);
      ref.invalidate(pendingInvitationsProvider);
      debugPrint(
        '✅ [InvitationsScreen] Invitation rejected — id: $invitationId',
      );

      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: l10n.invitationDeclinedSuccess,
          type: KiperaSnackType.info,
        );
      }
    } catch (e) {
      debugPrint(
        '❌ [InvitationsScreen] Reject failed — id: $invitationId | error: $e',
      );
      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: l10n.invitationDeclinedError,
          type: KiperaSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitationsAsync = ref.watch(pendingInvitationsProvider);
    debugPrint('📋 [InvitationsScreen] build — watching pending invitations');

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                context.l10n.alerts,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Content
            Expanded(
              child: invitationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.loadInvitationsError,
                        style: context.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                data: (invitations) {
                  if (invitations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 64,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.noPendingInvitations,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.l10n.invitationEmptyState,
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: invitations.length,
                    itemBuilder: (context, index) {
                      final inv = invitations[index];
                      final goal =
                          inv['savings_goals'] as Map<String, dynamic>? ?? {};
                      final inviter =
                          inv['inviter'] as Map<String, dynamic>? ?? {};

                      return InvitationCard(
                        goalName: goal['name'] as String? ?? context.l10n.unknownGoal,
                        inviterName:
                            inviter['display_name'] as String? ?? context.l10n.someone,
                        targetAmount:
                            (goal['target_amount'] as num?)?.toDouble() ?? 0,
                        method: goal['method'] as String? ?? '',
                        iconName: goal['icon_name'] as String? ?? 'savings',
                        isLoading: _processingId == inv['id'],
                        onAccept: () => _accept(inv['id'] as String, inv['goal_id'] as String, goal),
                        onReject: () => _reject(inv['id'] as String),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
