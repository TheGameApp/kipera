import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

class HomeShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShellScreen({super.key, required this.navigationShell});

  void _onNavTap(int index) {
    debugPrint('🧭 [HomeShell] tab changed — index: $index');
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final isDark = context.isDarkMode;

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
                onTap: () => _onNavTap(0),
              ),
              _NavBarItem(
                icon: Icons.bar_chart_outlined,
                activeIcon: Icons.bar_chart_rounded,
                label: context.l10n.statistics,
                isSelected: currentIndex == 1,
                isDark: isDark,
                onTap: () => _onNavTap(1),
              ),
              const SizedBox(width: 56), // Space for FAB
              _NavBarItem(
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: context.l10n.calendar,
                isSelected: currentIndex == 2,
                isDark: isDark,
                onTap: () => _onNavTap(2),
              ),
              _NavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: context.l10n.profile,
                isSelected: currentIndex == 3,
                isDark: isDark,
                onTap: () => _onNavTap(3),
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
