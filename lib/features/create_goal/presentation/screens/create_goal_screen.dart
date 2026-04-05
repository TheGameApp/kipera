import 'dart:convert';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/saving_methods.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/saving_calculator.dart';
import '../../../../core/widgets/kipera_back_button.dart';
import '../../../../core/widgets/kipera_snackbar.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../invitations/presentation/providers/invitations_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  bool _isCreating = false;

  // Step 1
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  TimeOfDay? _reminderTime;
  bool _isCoupleGoal = false;
  final _partnerEmailController = TextEditingController();

  // Step 2
  SavingMethod _selectedMethod = SavingMethod.progressive;
  final _fixedAmountController = TextEditingController(text: '10');
  final _baseAmountController = TextEditingController(text: '1');
  final _multiplierController = TextEditingController(text: '1.05');
  final _maxAmountController = TextEditingController(text: '20');

  // Step 3
  int _selectedColorIndex = 0;
  String _selectedIcon = 'savings';

  final _icons = [
    'savings',
    'flight',
    'laptop',
    'home',
    'school',
    'car_rental',
    'shopping_bag',
    'sports_esports',
    'celebration',
    'beach_access',
    'pets',
    'favorite',
    'diamond',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _fixedAmountController.dispose();
    _baseAmountController.dispose();
    _multiplierController.dispose();
    _maxAmountController.dispose();
    _partnerEmailController.dispose();
    super.dispose();
  }

  /// Validates the current step before proceeding.
  /// Returns true if valid, false otherwise (shows snackbar).
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      final name = _nameController.text.trim();
      final amountText = _amountController.text.trim();
      final amount = double.tryParse(amountText);

      if (name.isEmpty && amountText.isEmpty) {
        KiperaSnackBar.show(
          context,
        message: context.l10n.enterNameAndAmount,
          type: KiperaSnackType.warning,
        );
        return false;
      }
      if (name.isEmpty) {
        KiperaSnackBar.show(
          context,
          message: context.l10n.giveGoalName,
          type: KiperaSnackType.warning,
          icon: Icons.edit_outlined,
        );
        return false;
      }
      if (amountText.isEmpty || amount == null || amount <= 0) {
        KiperaSnackBar.show(
          context,
          message: context.l10n.setTargetAmount,
          type: KiperaSnackType.warning,
          icon: Icons.attach_money,
        );
        return false;
      }
      if (_reminderTime == null) {
        setState(() {}); // trigger visual update on reminder field
        KiperaSnackBar.show(
          context,
          message: context.l10n.chooseReminderTime,
          type: KiperaSnackType.warning,
          icon: Icons.notifications_outlined,
        );
        return false;
      }
      if (_isCoupleGoal) {
        final email = _partnerEmailController.text.trim();
        if (email.isEmpty || !email.contains('@')) {
          KiperaSnackBar.show(
            context,
            message: context.l10n.enterPartnerEmail,
            type: KiperaSnackType.warning,
            icon: Icons.email_outlined,
          );
          return false;
        }
      }
    }
    // Step 2 (method) always has a default selection, no validation needed.
    // Step 3 (appearance) always has defaults, no validation needed.
    return true;
  }

  void _nextStep() {
    debugPrint('[CreateGoal] next step tapped — currentStep: $_currentStep');

    if (!_validateCurrentStep()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      debugPrint('[CreateGoal] moved to step $_currentStep');
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('[CreateGoal] final step — creating goal');
      _createGoal();
    }
  }

  void _previousStep() {
    debugPrint(
      '[CreateGoal] previous step tapped — currentStep: $_currentStep',
    );
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      debugPrint('[CreateGoal] moved back to step $_currentStep');
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('[CreateGoal] already at first step — popping');
      context.pop();
    }
  }

  MethodConfig _buildConfig() {
    return MethodConfig(
      fixedAmount: double.tryParse(_fixedAmountController.text),
      baseAmount: double.tryParse(_baseAmountController.text),
      multiplierFactor: double.tryParse(_multiplierController.text),
      maxAmount: double.tryParse(_maxAmountController.text),
      reminderHour: _reminderTime?.hour,
      reminderMinute: _reminderTime?.minute,
    );
  }

  Future<void> _createGoal() async {
    if (_isCreating) return;

    final l10n = context.l10n;
    final user = ref.read(currentUserProvider);
    if (user == null) {
      debugPrint('❌ [CreateGoal] no user found — aborting');
      KiperaSnackBar.show(
        context,
        message: l10n.loginRequired,
        type: KiperaSnackType.error,
        icon: Icons.person_off_outlined,
      );
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    setState(() => _isCreating = true);

    debugPrint(
      '[CreateGoal] creating goal — name: $name, amount: $amount, method: ${_selectedMethod.name}, color: $_selectedColorIndex, icon: $_selectedIcon',
    );

    try {
      final config = _buildConfig();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final memberCount = _isCoupleGoal ? 2 : 1;
      
      final days = SavingCalculator.estimatedDays(
        method: _selectedMethod,
        targetAmount: amount,
        config: config,
        memberCount: memberCount,
      );

      final colorHex = AppColors.goalColors[_selectedColorIndex]
          .toARGB32()
          .toRadixString(16)
          .padLeft(8, '0');

      debugPrint('[CreateGoal] colorHex: $colorHex, userId: ${user.id}, days: $days');

      final goalId = const Uuid().v4();
      final db = ref.read(databaseProvider);
      await db.goalsDao.insertGoal(
        SavingsGoalsCompanion.insert(
          id: goalId,
          userId: user.id,
          name: name,
          targetAmount: amount,
          method: _selectedMethod.name,
          methodConfig: jsonEncode(config.toJson()),
          colorHex: colorHex,
          iconName: _selectedIcon,
          startDate: today,
          endDate: Value(days > 0 ? today.add(Duration(days: days)) : null),
          isCoupleGoal: Value(_isCoupleGoal),
          createdAt: now,
          updatedAt: now,
        ),
      );

      debugPrint('✅ [CreateGoal] goal created successfully');

      // Schedule daily notification reminder
      final notifService = NotificationService();
      await notifService.scheduleDailyReminder(
        goalId: goalId,
        hour: _reminderTime!.hour,
        minute: _reminderTime!.minute,
        title: l10n.timeToSave,
        body: l10n.notificationBody(name),
      );
      await notifService.debugListPending();

      // Trigger sync immediately to ensure the goal exists in Supabase
      // before we try to insert an invitation that references it.
      await ref.read(syncServiceProvider).syncAll();

      // Si es meta de pareja, enviar invitación al partner
      if (_isCoupleGoal) {
        final partnerEmail = _partnerEmailController.text.trim();
        try {
          final invService = ref.read(invitationServiceProvider);
          await invService.sendInvitation(
            goalId: goalId,
            inviterUserId: user.id,
            inviteeEmail: partnerEmail,
          );
          debugPrint('✅ [CreateGoal] invitation sent to $partnerEmail');
        } catch (e) {
          debugPrint('⚠️ [CreateGoal] invitation send failed but goal was created: $e');
          // No se bloquea la creación del goal si la invitación falla
        }
      }

      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: l10n.goalCreated(name),
          type: KiperaSnackType.success,
        );
        // Small delay so user sees the success message
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.pop();
      }
    } catch (e, st) {
      debugPrint('❌ [CreateGoal] ERROR creating goal: $e');
      debugPrint('❌ [CreateGoal] Stack trace: $st');
      if (mounted) {
        KiperaSnackBar.show(
          context,
          message: l10n.errorCreatingGoal,
          type: KiperaSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _pickReminderTime() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    final stepTitles = [
      context.l10n.stepOfTotal(1, 3),
      context.l10n.stepOfTotal(2, 3),
      context.l10n.stepOfTotal(3, 3)
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Custom header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    KiperaBackButton(onTap: _previousStep),
                    Text(
                      stepTitles[_currentStep],
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Step indicator: circles with connecting lines
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Row(
                  children: [
                    for (int i = 0; i < 3; i++) ...[
                      _buildStepCircle(i),
                      if (i < 2)
                        Expanded(
                          child: Container(
                            height: 1.5,
                            color: i < _currentStep
                                ? AppColors.primary
                                : (context.isDarkMode
                                    ? AppColors.borderDark
                                    : AppColors.borderLight),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildNameAmountStep(),
                    _buildMethodStep(isPremium),
                    _buildAppearanceStep(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.purple.withValues(alpha: 0.5),
                      disabledForegroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_currentStep == 2)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.auto_awesome, size: 20),
                                ),
                              Text(
                                _currentStep < 2
                                    ? context.l10n.next
                                    : context.l10n.confirm,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step) {
    final isCompleted = step < _currentStep;
    final isCurrent = step == _currentStep;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isCompleted || isCurrent
              ? AppColors.primary
              : (context.isDarkMode
                  ? AppColors.borderDark
                  : AppColors.borderLight),
          width: isCurrent ? 2 : 1.5,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${step + 1}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isCurrent
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
      ),
    );
  }

  Widget _buildRequiredLabel(String text, {bool required = true}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildNameAmountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequiredLabel(context.l10n.goalName),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: context.l10n.goalNameExample,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
          ),
          const SizedBox(height: 24),
          _buildRequiredLabel(context.l10n.targetAmount),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '1000',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 24),
          // Reminder Time
          _buildRequiredLabel(context.l10n.reminderTime),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickReminderTime,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? AppColors.inputBgDark
                    : AppColors.inputBgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _reminderTime == null
                      ? AppColors.warning.withValues(alpha: 0.7)
                      : AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: _reminderTime != null
                        ? AppColors.primary
                        : AppColors.warning,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _reminderTime != null
                              ? _formatTime(_reminderTime!)
                              : context.l10n.tapToSetReminder,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: _reminderTime != null
                                ? null
                                : AppColors.textSecondary,
                          ),
                        ),
                        if (_reminderTime == null)
                          Text(
                            context.l10n.requiredReminder,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.warning.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _reminderTime != null
                        ? Icons.check_circle_outline
                        : Icons.chevron_right,
                    color: _reminderTime != null
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Couple Goal Toggle ───────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isCoupleGoal
                  ? AppColors.pink.withValues(alpha: context.isDarkMode ? 0.15 : 0.08)
                  : (context.isDarkMode ? AppColors.inputBgDark : AppColors.inputBgLight),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isCoupleGoal ? AppColors.pink : (context.isDarkMode ? AppColors.borderDark : AppColors.borderLight),
                width: _isCoupleGoal ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('❤️', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.coupleGoalLabel,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            context.l10n.saveWithPartner,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isCoupleGoal,
                      onChanged: (val) => setState(() => _isCoupleGoal = val),
                      activeTrackColor: AppColors.pink,
                      activeThumbColor: Colors.white,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: context.isDarkMode ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ],
                ),
                // Partner email field — solo visible si es couple goal
                if (_isCoupleGoal) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _partnerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: context.l10n.partnerEmailHint,
                      prefixIcon: const Icon(Icons.email_outlined),
                      prefixIconColor: AppColors.pink,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.pink, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.pink.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.partnerInviteInfo,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ─────────────────────────────────────────────────────────────────

          const SizedBox(height: 24),
          if (_amountController.text.isNotEmpty) _buildEstimatePreview(),
        ],
      ),
    );
  }

  Widget _buildEstimatePreview() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return const SizedBox.shrink();

    final config = _buildConfig();
    final memberCount = _isCoupleGoal ? 2 : 1;
    
    final days = SavingCalculator.estimatedDays(
      method: _selectedMethod,
      targetAmount: amount,
      config: config,
      memberCount: memberCount,
    );
    final total = SavingCalculator.totalForDays(
      method: _selectedMethod,
      config: config,
      days: days,
      memberCount: memberCount,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.purple.withValues(alpha: 0.15),
            AppColors.pink.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: AppColors.purple,
            size: 28,
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.isDarkMode
                    ? AppColors.textDark
                    : AppColors.textLight,
              ),
              children: [
                TextSpan(text: context.l10n.reachGoalInPrefix),
                TextSpan(
                  text: context.l10n.daysCount(days),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.purple,
                  ),
                ),
                TextSpan(text: context.l10n.reachGoalInSuffix),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.l10n.totalLabel}\$${total.toStringAsFixed(2)}',
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodStep(bool isPremium) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: SavingMethod.values.length + 1, // +1 for estimate preview at top
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        // First item is the estimate preview
        if (index == 0) return _buildEstimatePreview();

        final method = SavingMethod.values[index - 1];
        final isLocked = !method.isFree && !isPremium;

        return GestureDetector(
          onTap: isLocked
              ? () {
                  debugPrint(
                    '[CreateGoal] locked method tapped — ${method.name} — navigating to /premium',
                  );
                  context.push('/premium');
                }
              : () {
                  debugPrint('[CreateGoal] method selected — ${method.name}');
                  setState(() => _selectedMethod = method);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedMethod == method
                  ? (context.isDarkMode
                      ? AppColors.primaryContainer.withValues(alpha: 0.25)
                      : AppColors.primaryContainer)
                  : context.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedMethod == method
                    ? AppColors.primary
                    : (context.isDarkMode
                        ? AppColors.borderDark
                        : AppColors.borderLight),
                width: _selectedMethod == method ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getMethodIcon(method),
                  color: _selectedMethod == method
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _getMethodName(context, method),
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                context.l10n.proLabel,
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getMethodDesc(context, method),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedMethod == method)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppearanceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.selectColor,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(AppColors.goalColors.length, (i) {
              return GestureDetector(
                onTap: () {
                  debugPrint('[CreateGoal] color selected — index: $i');
                  setState(() => _selectedColorIndex = i);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.goalColors[i],
                    shape: BoxShape.circle,
                    border: _selectedColorIndex == i
                        ? Border.all(color: AppColors.primary, width: 3)
                        : null,
                  ),
                  child: _selectedColorIndex == i
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                ),
              );
            }),
          ),
          const SizedBox(height: 32),
          Text(
            context.l10n.selectIcon,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _icons.map((iconName) {
              final isSelected = _selectedIcon == iconName;
              return GestureDetector(
                onTap: () {
                  debugPrint('[CreateGoal] icon selected — $iconName');
                  setState(() => _selectedIcon = iconName);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (context.isDarkMode
                            ? AppColors.primaryContainer.withValues(alpha: 0.25)
                            : AppColors.primaryContainer)
                        : context.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: AppColors.primary, width: 2)
                        : Border.all(
                            color: context.isDarkMode
                                ? AppColors.borderDark
                                : AppColors.borderLight,
                          ),
                  ),
                  child: Icon(
                    _iconFromName(iconName),
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Preview card
          _buildGoalPreviewCard(),
        ],
      ),
    );
  }

  Widget _buildGoalPreviewCard() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.goalColors[_selectedColorIndex],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            context.l10n.preview,
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _iconFromName(_selectedIcon),
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isEmpty ? context.l10n.goalName : name,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            amount > 0 ? '\$${amount.toStringAsFixed(2)}' : '\$0.00',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              Icon(
                _getMethodIcon(_selectedMethod),
                size: 14,
                color: AppColors.textSecondary,
              ),
              Text(
                _getMethodName(context, _selectedMethod),
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              if (_reminderTime != null) ...[
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(_reminderTime!),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getMethodName(BuildContext context, SavingMethod method) {
    return switch (method) {
      SavingMethod.progressive => context.l10n.progressive,
      SavingMethod.fixedDaily => context.l10n.fixedDaily,
      SavingMethod.reverseProgressive => context.l10n.reverseProgressive,
      SavingMethod.weeklyChallenge => context.l10n.weeklyChallenge,
      SavingMethod.randomEnvelopes => context.l10n.randomEnvelopes,
      SavingMethod.multiplier => context.l10n.multiplier,
      SavingMethod.biWeeklySteps => context.l10n.biWeeklySteps,
      SavingMethod.penalty => context.l10n.penaltyMethod,
    };
  }

  String _getMethodDesc(BuildContext context, SavingMethod method) {
    return switch (method) {
      SavingMethod.progressive => context.l10n.progressiveDesc,
      SavingMethod.fixedDaily => context.l10n.fixedDailyDesc,
      SavingMethod.reverseProgressive => context.l10n.reverseProgressiveDesc,
      SavingMethod.weeklyChallenge => context.l10n.weeklyChallengeDesc,
      SavingMethod.randomEnvelopes => context.l10n.randomEnvelopesDesc,
      SavingMethod.multiplier => context.l10n.multiplierDesc,
      SavingMethod.biWeeklySteps => context.l10n.biWeeklyStepsDesc,
      SavingMethod.penalty => context.l10n.penaltyMethodDesc,
    };
  }

  IconData _getMethodIcon(SavingMethod method) {
    return switch (method) {
      SavingMethod.progressive => Icons.trending_up,
      SavingMethod.fixedDaily => Icons.attach_money,
      SavingMethod.reverseProgressive => Icons.trending_down,
      SavingMethod.weeklyChallenge => Icons.calendar_month,
      SavingMethod.randomEnvelopes => Icons.shuffle,
      SavingMethod.multiplier => Icons.rocket_launch,
      SavingMethod.biWeeklySteps => Icons.stacked_line_chart,
      SavingMethod.penalty => Icons.gavel,
    };
  }

  IconData _iconFromName(String name) {
    return switch (name) {
      'flight' => Icons.flight,
      'laptop' => Icons.laptop,
      'home' => Icons.home,
      'school' => Icons.school,
      'car_rental' => Icons.car_rental,
      'shopping_bag' => Icons.shopping_bag,
      'sports_esports' => Icons.sports_esports,
      'celebration' => Icons.celebration,
      'beach_access' => Icons.beach_access,
      'pets' => Icons.pets,
      'favorite' => Icons.favorite,
      'diamond' => Icons.diamond,
      _ => Icons.savings,
    };
  }
}
