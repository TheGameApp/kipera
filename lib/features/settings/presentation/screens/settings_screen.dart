import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/kipera_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = context.isDarkMode;
    final user = ref.watch(currentUserProvider);
    final displayName =
        user?.userMetadata?['display_name'] as String? ?? 'User';
    final initial = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : '?';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hello greeting
            Text(
              'Hello $displayName',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Profile card - sage green
            GestureDetector(
              onTap: () {
                debugPrint('📱 [Settings] profile card tapped');
              }, // TODO: navigate to profile
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.successContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: isDark
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'View profile',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Premium Plan section
            Text(
              'Premium Plan',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Premium card - cream/yellow
            GestureDetector(
              onTap: () {
                debugPrint('🧭 [Settings] premium card tapped → navigating to /premium');
                context.push('/premium');
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.cardDark
                      : AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You're on Free Plan",
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.upgradeToPremium,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        'Upgrade',
                        style: TextStyle(
                          color: isDark
                              ? AppColors.backgroundDark
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Account Settings section
            Text(
              'Account Settings',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Light Mode toggle
            _SettingsTile(
              icon: Icons.light_mode_outlined,
              title: context.l10n.lightMode,
              trailing: Switch(
                value: themeMode != ThemeMode.dark,
                onChanged: (_) {
                  debugPrint('⚙️ [Settings] theme toggled — current: $themeMode');
                  ref.read(themeProvider.notifier).toggle();
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.success,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),

            // Notifications
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: context.l10n.notifications,
              trailing: Switch(
                value: ref.watch(notificationsEnabledProvider),
                onChanged: (val) {
                  debugPrint('⚙️ [Settings] notifications toggled — $val');
                  ref.read(notificationsEnabledProvider.notifier).state = val;
                },
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.success,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),

            // Language
            _SettingsTile(
              icon: Icons.language_outlined,
              title: context.l10n.language,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ref.watch(localeProvider).languageCode == 'en'
                        ? 'English'
                        : 'Español',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textSecondary,
                  ),
                ],
              ),
              onTap: () {
                final currentLocale = ref.read(localeProvider);
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select Language',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading:
                              const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                          title: const Text('English'),
                          trailing: currentLocale.languageCode == 'en'
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.purple)
                              : null,
                          onTap: () {
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(const Locale('en'));
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          leading:
                              const Text('🇪🇸', style: TextStyle(fontSize: 24)),
                          title: const Text('Español'),
                          trailing: currentLocale.languageCode == 'es'
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.purple)
                              : null,
                          onTap: () {
                            ref
                                .read(localeProvider.notifier)
                                .setLocale(const Locale('es'));
                            Navigator.pop(ctx);
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Privacy Policy
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: 'Privacy Policy',
              trailing: Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textSecondary,
              ),
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  debugPrint('🔐 [Settings] logout tapped');
                  KiperaSnackBar.show(
                    context,
                    message: 'Logging out...',
                    type: KiperaSnackType.info,
                    icon: Icons.logout,
                    duration: const Duration(seconds: 2),
                  );
                  await ref.read(authNotifierProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  context.l10n.logout,
                  style: const TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isDark
                  ? AppColors.textPrimaryDark.withValues(alpha: 0.7)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
