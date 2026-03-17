import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Ensures the Supabase user exists in the local users table.
/// This is needed for foreign key constraints on savings_goals.
final syncUserProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return;
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();
  debugPrint('🔄 [SyncUser] upserting user ${user.id} into local DB');
  await db.usersDao.upsertUser(UsersCompanion(
    id: Value(user.id),
    email: Value(user.email ?? ''),
    displayName: Value(user.userMetadata?['display_name'] as String?),
    createdAt: Value(now),
    updatedAt: Value(now),
  ));
  debugPrint('✅ [SyncUser] user synced to local DB');
});

final activeGoalsProvider = StreamProvider<List<SavingsGoal>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  // Ensure user is synced before watching goals
  ref.watch(syncUserProvider);
  final db = ref.watch(databaseProvider);
  return db.goalsDao.watchActiveGoals(user.id);
});

final goalDetailProvider = FutureProvider.family<SavingsGoal?, String>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.goalsDao.getGoalById(goalId);
});

final totalSavedForGoalProvider = FutureProvider.family<double, String>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.entriesDao.getTotalSavedForGoal(goalId);
});

final entriesForGoalProvider = StreamProvider.family<List<SavingEntry>, String>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.entriesDao.watchEntriesForGoal(goalId);
});

final completedEntriesProvider = FutureProvider.family<List<SavingEntry>, String>((ref, goalId) {
  final db = ref.watch(databaseProvider);
  return db.entriesDao.getCompletedEntriesForGoal(goalId);
});
