import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/kipera_back_button.dart';
import '../../../../core/widgets/heatmap_widget.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  final Set<int> _selectedGoals = {};
  int? _selectedMethod;

  static const _totalPages = 3;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    debugPrint('📱 [Onboarding] next button tapped — currentPage: $_currentPage');
    if (_currentPage < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('🧭 [Onboarding] last page reached → navigating to /login');
      markOnboardingSeen();
      context.go('/login');
    }
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar: back button + "Maybe Later"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    KiperaBackButton(
                      onTap: () {
                        debugPrint('📱 [Onboarding] back button tapped — currentPage: $_currentPage');
                        _controller.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    )
                  else
                    const SizedBox(width: 44),
                  GestureDetector(
                    onTap: () {
                      debugPrint('🧭 [Onboarding] "Maybe Later" tapped → navigating to /login');
                      markOnboardingSeen();
                      context.go('/login');
                    },
                    child: Text(
                      'Maybe Later',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) {
                  debugPrint('🧭 [Onboarding] page changed to $i');
                  setState(() => _currentPage = i);
                },
                children: [
                  _GoalSelectionPage(
                    selectedGoals: _selectedGoals,
                    onToggle: (index) {
                      setState(() {
                        if (_selectedGoals.contains(index)) {
                          debugPrint('📱 [Onboarding] goal deselected — index: $index');
                          _selectedGoals.remove(index);
                        } else {
                          debugPrint('📱 [Onboarding] goal selected — index: $index');
                          _selectedGoals.add(index);
                        }
                      });
                    },
                  ),
                  _SaveSmarterPage(
                    selectedMethod: _selectedMethod,
                    onSelect: (index) {
                      debugPrint('📱 [Onboarding] method selected — index: $index');
                      setState(() => _selectedMethod = index);
                    },
                  ),
                  const _TrackProgressPage(),
                ],
              ),
            ),

            // Bottom: page indicators + next button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pill-shaped page indicators
                  Row(
                    children: List.generate(
                      _totalPages,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.purple
                              : (_isDark ? AppColors.borderDark : AppColors.borderLight),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Circular next button with purple border ring
                  GestureDetector(
                    onTap: _goToNextPage,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.purple,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _currentPage < _totalPages - 1
                              ? Icons.chevron_right
                              : Icons.check,
                          color: AppColors.purple,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1: What do you want to save for? ──

class _GoalSelectionPage extends StatelessWidget {
  final Set<int> selectedGoals;
  final ValueChanged<int> onToggle;

  const _GoalSelectionPage({
    required this.selectedGoals,
    required this.onToggle,
  });

  static const _options = [
    ('Travel', '\u2708\uFE0F'),
    ('Home', '\u{1F3E0}'),
    ('Education', '\u{1F393}'),
    ('Fun & Entertainment', '\u{1F3AE}'),
    ('Emergency Fund', '\u{1F4B0}'),
    ('Tech & Gadgets', '\u{1F4F1}'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'What do you want\nto save for?',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose what you\'d like to focus on first.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final isSelected = selectedGoals.contains(index);
                return GestureDetector(
                  onTap: () => onToggle(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.purpleLight.withValues(alpha: 0.25)
                          : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.purple
                            : borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _options[index].$2,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _options[index].$1,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Save Smarter ──

class _SaveSmarterPage extends StatelessWidget {
  final int? selectedMethod;
  final ValueChanged<int> onSelect;

  const _SaveSmarterPage({
    required this.selectedMethod,
    required this.onSelect,
  });

  static const _methods = [
    (
      '\u{1F4C8}',
      'Progressive',
      'Start small and increase daily. Day 1 = \$1, Day 2 = \$2...'
    ),
    (
      '\u{1F4CA}',
      'Fixed Daily',
      'Save the same amount every day. Simple and consistent.'
    ),
    (
      '\u{1F3B2}',
      'Random Envelopes',
      'Random amounts each day. Fun and surprising!'
    ),
    (
      '\u26A1',
      'Multiplier',
      'Exponential growth with a daily cap for big results.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Save Smarter',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a method that fits your lifestyle.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: ListView.separated(
              itemCount: _methods.length,
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final method = _methods[index];
                final isSelected = selectedMethod == index;
                return GestureDetector(
                  onTap: () => onSelect(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.purpleLight.withValues(alpha: 0.25)
                          : cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.purple
                            : borderColor,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.$1,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.$2,
                              style: context.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              method.$3,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Track Your Progress ──

class _TrackProgressPage extends StatelessWidget {
  const _TrackProgressPage();

  @override
  Widget build(BuildContext context) {
    // Build sample heatmap data for preview
    final now = DateTime.now();
    final sampleData = <DateTime, int>{};
    for (var i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      sampleData[key] = (i % 5 == 0) ? 0 : ((i * 3 + 7) % 5);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Track Your\nProgress',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visualize savings and unlock achievements.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Heatmap preview card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saving Heatmap',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                HeatmapWidget(data: sampleData, weeks: 8),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Achievement preview cards
          _AchievementPreviewTile(
            emoji: '\u{1F525}',
            title: '7-Day Streak',
            subtitle: 'Save for 7 days in a row',
          ),
          const SizedBox(height: 12),
          _AchievementPreviewTile(
            emoji: '\u{1F3C6}',
            title: 'Goal Achieved!',
            subtitle: 'Complete 100% of a goal',
          ),
        ],
      ),
    );
  }
}

class _AchievementPreviewTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _AchievementPreviewTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
