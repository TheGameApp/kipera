import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_shell_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/create_goal/presentation/screens/create_goal_screen.dart';
import '../../features/goal_detail/presentation/screens/goal_detail_screen.dart';
import '../../features/check_in/presentation/screens/check_in_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider).valueOrNull ?? false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.valueOrNull != null;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation == '/onboarding';
      final isOnSplash = state.matchedLocation == '/splash';

      debugPrint('🧭 [Router] redirect — isLoading: $isLoading, isLoggedIn: $isLoggedIn, location: ${state.matchedLocation}, hasSeenOnboarding: $hasSeenOnboarding');

      // While auth is loading, stay on splash
      if (isLoading && isOnSplash) {
        return null;
      }

      // Auth resolved — redirect away from splash
      if (!isLoading && isOnSplash) {
        if (isLoggedIn) return '/home';
        if (!hasSeenOnboarding) return '/onboarding';
        return '/login';
      }

      // If not logged in and not on an auth page
      if (!isLoggedIn && !isOnAuthPage && !isOnSplash) {
        if (!hasSeenOnboarding) return '/onboarding';
        return '/login';
      }

      // If logged in but still on an auth/onboarding page
      if (isLoggedIn && (isOnAuthPage || isOnSplash)) {
        debugPrint('🧭 [Router] logged in & on auth page → redirecting to /home');
        return '/home';
      }
      debugPrint('🧭 [Router] no redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/statistics',
                builder: (context, state) => const StatisticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/create-goal',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateGoalScreen(),
      ),
      GoRoute(
        path: '/goal/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => GoalDetailScreen(
          goalId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/check-in/:goalId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CheckInScreen(
          goalId: state.pathParameters['goalId']!,
        ),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/premium',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
  );
});
