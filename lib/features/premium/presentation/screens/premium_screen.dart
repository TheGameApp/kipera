import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/kipera_back_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  /// 0 = monthly, 1 = yearly
  int _selectedPlan = 1;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Back button
              const KiperaBackButton(),

              const SizedBox(height: 28),

              // Headline
              Text(
                context.l10n.upgradeToPremium,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock exclusive challenges and advanced habit insights.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Lavender premium card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.purpleLight.withValues(alpha: isDark ? 0.15 : 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.purple.withValues(alpha: 0.4) : AppColors.purpleLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Diamond icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond_outlined,
                        color: AppColors.purple,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Premium Upgrade',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Get access to all 8 saving methods, unlimited goals, '
                      'advanced statistics, cloud sync, custom notifications, '
                      'and an ad-free experience.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Plan selection
              _PlanRadioTile(
                title: context.l10n.monthlyPlan,
                price: '\$4.99${context.l10n.perMonth}',
                subtitle: null,
                isSelected: _selectedPlan == 0,
                onTap: () {
                  debugPrint('📱 [Premium] plan selected — monthly');
                  setState(() => _selectedPlan = 0);
                },
              ),
              const SizedBox(height: 12),
              _PlanRadioTile(
                title: context.l10n.yearlyPlan,
                price: '\$39.99${context.l10n.perYear}',
                subtitle: 'Save 30%',
                isSelected: _selectedPlan == 1,
                onTap: () {
                  debugPrint('📱 [Premium] plan selected — yearly');
                  setState(() => _selectedPlan = 1);
                },
              ),

              const SizedBox(height: 32),

              // Subscribe button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint('📱 [Premium] subscribe tapped — plan: ${_selectedPlan == 0 ? "monthly" : "yearly"}');
                    // TODO: handle subscription
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Subscribe',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Radio-style plan card ──

class _PlanRadioTile extends StatelessWidget {
  final String title;
  final String price;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanRadioTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.purpleLight.withValues(alpha: 0.15)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.purple : borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.purple : borderColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.purple,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Price
            Text(
              price,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.purple : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
