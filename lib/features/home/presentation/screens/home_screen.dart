import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/home_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/goal_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('💾 [HomeScreen] build');
    final goalsAsync = ref.watch(activeGoalsProvider);
    final user = ref.watch(currentUserProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.todaysSaving,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hello, ${user?.userMetadata?['display_name'] ?? 'Saver'}!',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push('/achievements'),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryContainer,
                          child: const Icon(Icons.emoji_events,
                              color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          goalsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (goals) {
              if (goals.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          size: 80,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.noGoalsYet,
                          style: context.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.createYourFirstGoal,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/create-goal'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.createGoal),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.separated(
                  itemCount: goals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    return GoalCard(
                      goal: goal,
                      colorIndex: index % AppColors.goalColors.length,
                      onTap: () {
                        debugPrint('📱 [HomeScreen] goal card tapped — goalId: ${goal.id}, name: ${goal.name}');
                        context.push('/goal/${goal.id}');
                      },
                      onCheckIn: () {
                        debugPrint('📱 [HomeScreen] check-in tapped — goalId: ${goal.id}');
                        context.push('/check-in/${goal.id}');
                      },
                    );
                  },
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }
}
