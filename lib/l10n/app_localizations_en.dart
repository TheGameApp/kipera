// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kipera';

  @override
  String get onboardingTitle1 => 'Save Smarter';

  @override
  String get onboardingDesc1 =>
      'Choose from 8 different saving methods that fit your lifestyle';

  @override
  String get onboardingTitle2 => 'Track Your Progress';

  @override
  String get onboardingDesc2 =>
      'Visualize your savings with heatmaps and statistics';

  @override
  String get onboardingTitle3 => 'Achieve Your Goals';

  @override
  String get onboardingDesc3 =>
      'Unlock achievements and stay motivated with daily streaks';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get displayName => 'Display Name';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log In';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get google => 'Google';

  @override
  String get home => 'Home';

  @override
  String get statistics => 'Statistics';

  @override
  String get calendar => 'Calendar';

  @override
  String get settings => 'Settings';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get goalName => 'Goal Name';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get selectMethod => 'Select Method';

  @override
  String get preview => 'Preview';

  @override
  String get selectColor => 'Select Color';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get abandon => 'Abandon';

  @override
  String get todaysSaving => 'Today\'s Saving';

  @override
  String get checkIn => 'Check In';

  @override
  String get markAsSaved => 'Mark as Saved';

  @override
  String get streak => 'Streak';

  @override
  String get days => 'days';

  @override
  String get totalSaved => 'Total Saved';

  @override
  String get remaining => 'Remaining';

  @override
  String get progress => 'Progress';

  @override
  String get daysLeft => 'Days Left';

  @override
  String get achievements => 'Achievements';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get locked => 'Locked';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get progressive => 'Progressive';

  @override
  String get progressiveDesc =>
      'Start small, increase daily. Day 1=\$1, Day 2=\$2...';

  @override
  String get fixedDaily => 'Fixed Daily';

  @override
  String get fixedDailyDesc => 'Same amount every day. Simple and consistent.';

  @override
  String get reverseProgressive => 'Reverse Progressive';

  @override
  String get reverseProgressiveDesc =>
      'Start high, decrease daily. High motivation early on.';

  @override
  String get weeklyChallenge => 'Weekly Challenge';

  @override
  String get weeklyChallengeDesc => 'Increase your saving each week.';

  @override
  String get randomEnvelopes => 'Random (Envelopes)';

  @override
  String get randomEnvelopesDesc =>
      'Random amounts each day. Fun and surprising!';

  @override
  String get multiplier => 'Multiplier';

  @override
  String get multiplierDesc => 'Exponential growth with a daily cap.';

  @override
  String get biWeeklySteps => 'Bi-Weekly Steps';

  @override
  String get biWeeklyStepsDesc => 'Increase amount every two weeks.';

  @override
  String get penaltyMethod => 'Penalty';

  @override
  String get penaltyMethodDesc =>
      'Save a fixed amount each time you do a bad habit.';

  @override
  String get freeMethods => 'Free';

  @override
  String get premiumMethods => 'Premium';

  @override
  String estimatedDays(int days) {
    return 'Estimated: $days days';
  }

  @override
  String estimatedTotal(String amount) {
    return 'Total: \$$amount';
  }

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get createYourFirstGoal => 'Create your first savings goal!';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get goalCompleted => 'Goal Completed!';

  @override
  String get firstStep => 'First Step';

  @override
  String get firstStepDesc => 'Complete your first saving';

  @override
  String get streak3 => '3-Day Streak';

  @override
  String get streak3Desc => 'Save for 3 days in a row';

  @override
  String get weeklyWarrior => 'Weekly Warrior';

  @override
  String get weeklyWarriorDesc => 'Save for 7 days in a row';

  @override
  String get biweeklyChampion => 'Biweekly Champion';

  @override
  String get biweeklyChampionDesc => 'Save for 14 days in a row';

  @override
  String get monthlyMaster => 'Monthly Master';

  @override
  String get monthlyMasterDesc => 'Save for 30 days in a row';

  @override
  String get centurion => 'Centurion';

  @override
  String get centurionDesc => 'Save for 100 days in a row';

  @override
  String get quarterWay => '25% There';

  @override
  String get quarterWayDesc => 'Reach 25% of your goal';

  @override
  String get halfWay => 'Halfway!';

  @override
  String get halfWayDesc => 'Reach 50% of your goal';

  @override
  String get almostThere => 'Almost There!';

  @override
  String get almostThereDesc => 'Reach 75% of your goal';

  @override
  String get goalAchieved => 'Goal Achieved!';

  @override
  String get goalAchievedDesc => 'Complete 100% of your goal';

  @override
  String get club100 => '\$100 Club';

  @override
  String get club100Desc => 'Save \$100 in total';

  @override
  String get club1000 => '\$1,000 Club';

  @override
  String get club1000Desc => 'Save \$1,000 in total';

  @override
  String get perfectWeek => 'Perfect Week';

  @override
  String get perfectWeekDesc => 'Save every day for a full week';

  @override
  String get perfectMonth => 'Perfect Month';

  @override
  String get perfectMonthDesc => 'Save every day for a full month';

  @override
  String get comeback => 'Triumphant Return';

  @override
  String get comebackDesc => 'Resume saving after 3+ days off';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Log Out';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get version => 'Version';

  @override
  String get aboutKipera => 'About Kipera';
}
