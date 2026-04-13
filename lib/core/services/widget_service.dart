import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../database/app_database.dart';
import '../utils/heatmap_utils.dart';

/// Service that manages home screen widget data updates.
///
/// Uses the `home_widget` package to share data between Flutter and
/// native widgets (iOS Widget Extension / Android AppWidget).
///
/// Data flow:
/// 1. Flutter saves data to shared container via HomeWidget.saveWidgetData()
/// 2. Flutter requests widget update via HomeWidget.updateWidget()
/// 3. Native widget reads data from shared container (UserDefaults/SharedPreferences)
///
/// Shared keys (used in both Flutter and native code):
///   - "goal_name"        : String — display name of the selected goal
///   - "goal_progress"    : double — 0.0 to 1.0 progress ratio
///   - "goal_saved"       : double — total amount saved
///   - "goal_target"      : double — target amount
///   - "goal_color"       : String — hex color string
///   - "goal_icon"        : String — icon name
///   - "goal_streak"      : int    — current streak count
///   - "goal_is_couple"   : bool   — whether it's a couple goal
///   - "last_updated"     : String — ISO8601 timestamp
class WidgetService {
  // App group ID for iOS shared container
  // Must match the App Group configured in Xcode for both the main app and widget extension
  static const String _iOSAppGroupId = 'group.com.kipera.app';

  // Android widget provider class name
  static const String _androidWidgetName = 'KiperaWidgetProvider';

  // iOS widget kind
  static const String _iOSWidgetName = 'KiperaWidget';

  // SharedPreferences key for persisting the selected widget goal
  static const String _selectedGoalKey = 'widget_selected_goal_id';

  final AppDatabase _db;

  WidgetService(this._db);

  /// Initialize home_widget with platform-specific identifiers.
  Future<void> init() async {
    await HomeWidget.setAppGroupId(_iOSAppGroupId);
  }

  // ── Goal Selection ──

  /// Set which goal should be displayed in the home screen widget.
  Future<void> setWidgetGoal(String goalId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedGoalKey, goalId);
    debugPrint('📱 [WidgetService] Widget goal set to: $goalId');
  }

  /// Get the currently selected widget goal ID (null if none).
  Future<String?> getWidgetGoalId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedGoalKey);
  }

  /// Refresh the widget using data from the currently selected goal.
  /// If no goal is selected, uses the first active goal.
  Future<void> refreshWidgetFromSelectedGoal(String userId) async {
    try {
      final selectedId = await getWidgetGoalId();
      SavingsGoal? goal;

      if (selectedId != null) {
        goal = await _db.goalsDao.getGoalById(selectedId);
      }

      // Fallback to first active goal if selected goal not found
      if (goal == null) {
        final goals = await _db.goalsDao.getActiveGoals(userId);
        if (goals.isNotEmpty) {
          goal = goals.first;
          await setWidgetGoal(goal.id);
        }
      }

      if (goal == null) {
        await clearWidgetData();
        return;
      }

      final totalSaved = await _db.entriesDao.getTotalSavedForGoal(goal.id);
      final entries = await _db.entriesDao.getCompletedEntriesForGoal(goal.id);
      final dates = entries.map((e) => e.date).toList();
      final streak = HeatmapUtils.calculateStreak(dates);

      await updateWidgetData(
        goalName: goal.name,
        totalSaved: totalSaved,
        targetAmount: goal.targetAmount,
        colorHex: goal.colorHex,
        iconName: goal.iconName,
        streak: streak,
        isCoupleGoal: goal.isCoupleGoal,
      );
    } catch (e) {
      debugPrint('❌ [WidgetService] Failed to refresh widget: $e');
    }
  }

  // ── Data Update ──

  /// Update widget data for a specific goal.
  /// Call this after every check-in, sync, or goal change.
  Future<void> updateWidgetData({
    required String goalName,
    required double totalSaved,
    required double targetAmount,
    required String colorHex,
    required String iconName,
    required int streak,
    required bool isCoupleGoal,
  }) async {
    try {
      final progress = targetAmount > 0
          ? (totalSaved / targetAmount).clamp(0.0, 1.0)
          : 0.0;

      await Future.wait([
        HomeWidget.saveWidgetData('goal_name', goalName),
        HomeWidget.saveWidgetData('goal_progress', progress),
        HomeWidget.saveWidgetData('goal_saved', totalSaved),
        HomeWidget.saveWidgetData('goal_target', targetAmount),
        HomeWidget.saveWidgetData('goal_color', colorHex),
        HomeWidget.saveWidgetData('goal_icon', iconName),
        HomeWidget.saveWidgetData('goal_streak', streak),
        HomeWidget.saveWidgetData('goal_is_couple', isCoupleGoal),
        HomeWidget.saveWidgetData('last_updated', DateTime.now().toIso8601String()),
      ]);

      // Request native widget refresh
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );

      debugPrint('✅ [WidgetService] Widget updated: $goalName (${ (progress * 100).toStringAsFixed(0)}%)');
    } catch (e) {
      debugPrint('❌ [WidgetService] Failed to update widget: $e');
    }
  }

  /// Clear all widget data (e.g., when user logs out).
  Future<void> clearWidgetData() async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData('goal_name', ''),
        HomeWidget.saveWidgetData('goal_progress', 0.0),
        HomeWidget.saveWidgetData('goal_saved', 0.0),
        HomeWidget.saveWidgetData('goal_target', 0.0),
        HomeWidget.saveWidgetData('goal_color', ''),
        HomeWidget.saveWidgetData('goal_icon', ''),
        HomeWidget.saveWidgetData('goal_streak', 0),
        HomeWidget.saveWidgetData('goal_is_couple', false),
        HomeWidget.saveWidgetData('last_updated', ''),
      ]);

      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );

      debugPrint('✅ [WidgetService] Widget data cleared');
    } catch (e) {
      debugPrint('❌ [WidgetService] Failed to clear widget: $e');
    }
  }
}
