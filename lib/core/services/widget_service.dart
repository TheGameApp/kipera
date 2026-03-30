import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../../database/app_database.dart';

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

  // ignore: unused_field — will be used to auto-load goal data for widget refresh
  final AppDatabase _db;

  WidgetService(this._db);

  /// Initialize home_widget with platform-specific identifiers.
  Future<void> init() async {
    await HomeWidget.setAppGroupId(_iOSAppGroupId);
  }

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
