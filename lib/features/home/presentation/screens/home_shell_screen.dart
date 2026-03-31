import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../invitations/presentation/providers/invitations_provider.dart';

class HomeShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShellScreen({super.key, required this.navigationShell});

  void _onNavTap(BuildContext context, int index, int pendingCount) {
    debugPrint('🧭 [HomeShell] tab changed — index: $index');
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final isDark = context.isDarkMode;
    final pendingCount = ref.watch(pendingInvitationCountProvider);

    if (pendingCount > 0) {
      debugPrint('🔔 [HomeShell] Pending invitations badge — count: $pendingCount');
    }

    return Scaffold(
      body: navigationShell,
      extendBody: true,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          heroTag: 'create_goal_fab',
          onPressed: () {
            debugPrint('🧭 [HomeShell] FAB tapped → navigating to /create-goal');
            context.push('/create-goal');
          },
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 70,
        padding: EdgeInsets.zero,
        color: isDark ? AppColors.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: context.l10n.home,
                isSelected: currentIndex == 0,
                isDark: isDark,
                onTap: () => _onNavTap(context, 0, pendingCount),
              ),
              _NavBarItemWithBadge(
                icon: Icons.notifications_none_rounded,
                activeIcon: Icons.notifications_rounded,
                label: context.l10n.alerts,
                isSelected: currentIndex == 1,
                isDark: isDark,
                badgeCount: pendingCount,
                onTap: () => _onNavTap(context, 1, pendingCount),
              ),
              const SizedBox(width: 56), // Space for FAB
              _NavBarItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: context.l10n.calendar,
                isSelected: currentIndex == 2,
                isDark: isDark,
                onTap: () => _onNavTap(context, 2, pendingCount),
              ),
              _NavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: context.l10n.profile,
                isSelected: currentIndex == 3,
                isDark: isDark,
                onTap: () => _onNavTap(context, 3, pendingCount),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.purple;
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.purpleLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'ClashDisplay',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nav bar item con badge circular para invitaciones pendientes
class _NavBarItemWithBadge extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final bool isDark;
  final int badgeCount;
  final VoidCallback onTap;

  const _NavBarItemWithBadge({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = badgeCount > 0 ? AppColors.pink : AppColors.purple;
    final inactiveColor = isDark
        ? AppColors.textSecondary
        : AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: (badgeCount > 0
                                  ? AppColors.pink
                                  : AppColors.purpleLight)
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? activeColor : inactiveColor,
                    size: 24,
                  ),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.pink,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'ClashDisplay',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
