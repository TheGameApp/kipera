// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get abandon => 'Abandon';

  @override
  String get aboutKipera => 'About Kipera';

  @override
  String get accept => 'Accept';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String get achievements => 'Achievements';

  @override
  String get activeGoalsLabel => 'Active Goals';

  @override
  String get activityLabel => 'Activity';

  @override
  String get alerts => 'Alerts';

  @override
  String get allTime => 'All Time';

  @override
  String get almostThere => 'Almost There!';

  @override
  String get almostThereDesc => 'Reach 75% of your goal';

  @override
  String get alreadyCheckedIn =>
      'You already checked in today! Come back tomorrow.';

  @override
  String get alreadyHaveAccount => 'Already have an account? Log In';

  @override
  String get alreadyHaveAccountStart => 'Already have an account? ';

  @override
  String get appName => 'Kipera';

  @override
  String get biWeeklySteps => 'Bi-Weekly Steps';

  @override
  String get biWeeklyStepsDesc => 'Increase amount every two weeks.';

  @override
  String get biweeklyChampion => 'Biweekly Champion';

  @override
  String get biweeklyChampionDesc => 'Save for 14 days in a row';

  @override
  String get byGoal => 'By Goal';

  @override
  String get calendar => 'Calendar';

  @override
  String get cancel => 'Cancel';

  @override
  String get centurion => 'Centurion';

  @override
  String get centurionDesc => 'Save for 100 days in a row';

  @override
  String get checkIn => 'Check In';

  @override
  String get checkInGoalNotFound => 'Goal not found. It may have been deleted.';

  @override
  String get chooseReminderTime =>
      'Choose a daily reminder time to stay on track.';

  @override
  String get club100 => '\$100 Club';

  @override
  String get club1000 => '\$1,000 Club';

  @override
  String get club1000Desc => 'Save \$1,000 in total';

  @override
  String get club100Desc => 'Save \$100 in total';

  @override
  String get comeback => 'Triumphant Return';

  @override
  String get comebackDesc => 'Resume saving after 3+ days off';

  @override
  String get confirm => 'Confirm';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get coupleGoalLabel => 'Couple Goal';

  @override
  String get createAccount => 'Create Account';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get createGoalAmountValidation =>
      'Set a target amount greater than \$0 for your goal.';

  @override
  String get createGoalError =>
      'Something went wrong creating your goal. Please try again.';

  @override
  String get createGoalLoginRequired =>
      'You need to be logged in to create a goal.';

  @override
  String get createGoalNameValidation =>
      'Give your goal a name so you can identify it easily.';

  @override
  String get createGoalPartnerEmailValidation =>
      'Enter a valid email address for your partner.';

  @override
  String get createGoalTimeValidation =>
      'Choose a daily reminder time to stay on track.';

  @override
  String get createGoalValidation => 'Please enter a name and amount';

  @override
  String get createYourFirstGoal => 'Create your first savings goal!';

  @override
  String currentlyAt(String time) {
    return 'Currently $time';
  }

  @override
  String dailyReminderAt(String time) {
    return 'Daily reminder at $time';
  }

  @override
  String get darkMode => 'Dark Mode';

  @override
  String dayLabel(int number) {
    return 'Day $number';
  }

  @override
  String get dayLeftToGoal => 'day left to reach your goal';

  @override
  String dayOfTotal(int completed, int total) {
    return 'Day $completed of $total';
  }

  @override
  String get days => 'days';

  @override
  String reachGoalRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days left to reach your goal',
      one: 'day left to reach your goal',
    );
    return '$_temp0';
  }

  @override
  String get decline => 'Decline';

  @override
  String get defaultUserName => 'Saver';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String deleteGoalConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get deleteGoalTitle => 'Delete Goal';

  @override
  String get displayName => 'Display Name';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Sign Up';

  @override
  String get dontHaveAccountStart => 'Don\'t have an account? ';

  @override
  String get edit => 'Edit';

  @override
  String get editGoalName => 'Edit Goal Name';

  @override
  String get editReminderTime => 'Edit Reminder Time';

  @override
  String get email => 'Email';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get enterName => 'Enter your name';

  @override
  String get enterNameAndAmount =>
      'Please enter a goal name and target amount to continue.';

  @override
  String get enterPartnerEmail =>
      'Enter a valid email address for your partner.';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get errorCreatingGoal =>
      'Something went wrong creating your goal. Please try again.';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String estimatedDays(int days) {
    return 'Estimated: $days days';
  }

  @override
  String estimatedTotal(String amount) {
    return 'Total: \$$amount';
  }

  @override
  String get expectedLabel => 'Expected: ';

  @override
  String get fillInformation => 'Fill your information below';

  @override
  String get firstStep => 'First Step';

  @override
  String get firstStepDesc => 'Complete your first saving';

  @override
  String get fixedDaily => 'Fixed Daily';

  @override
  String get fixedDailyDesc => 'Same amount every day. Simple and consistent.';

  @override
  String get fixedMethodOnboardingDesc =>
      'Save the same amount every day. Simple and consistent.';

  @override
  String get fixedMethodTitle => 'Fixed Daily';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get forgotPasswordDesc =>
      'Enter your email address to get the password reset link.';

  @override
  String get freeMethods => 'Free';

  @override
  String get freePlanStatus => 'You\'re on Free Plan';

  @override
  String get getStarted => 'Get Started';

  @override
  String get giveGoalName =>
      'Give your goal a name so you can identify it easily.';

  @override
  String get goalAchieved => 'Goal Achieved!';

  @override
  String get goalAchievedDesc => 'Complete 100% of your goal';

  @override
  String get goalAchievedSubtitle => 'Complete 100% of a goal';

  @override
  String get goalAchievedTitle => 'Goal Achieved!';

  @override
  String get goalCompleted => 'Goal Completed!';

  @override
  String goalCreated(String name) {
    return '\"$name\" created! Your saving journey starts now.';
  }

  @override
  String goalDeletedSuccess(String name) {
    return '\"$name\" has been deleted.';
  }

  @override
  String goalLabelPrefix(String name) {
    return 'Goal: $name';
  }

  @override
  String get goalName => 'Goal Name';

  @override
  String get goalNameExample => 'e.g., Trip to Europe';

  @override
  String get goalNameHint => 'Goal name';

  @override
  String get goalNotFound => 'Goal not found';

  @override
  String get goalReachedLabel => 'Goal reached! ';

  @override
  String goalRenamed(String name) {
    return 'Goal renamed to \"$name\"';
  }

  @override
  String get goalsProgress => 'Goals Progress';

  @override
  String get google => 'Google';

  @override
  String get halfWay => 'Halfway!';

  @override
  String get halfWayDesc => 'Reach 50% of your goal';

  @override
  String helloUser(String name) {
    return 'Hello, $name!';
  }

  @override
  String get home => 'Home';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidEmailError => 'Please enter a valid email.';

  @override
  String get invitationAcceptedError =>
      'Could not accept invitation. Try again.';

  @override
  String get invitationAcceptedSuccess =>
      '❤️ Invitation accepted! You can now save together.';

  @override
  String get invitationDeclinedError =>
      'Could not decline invitation. Try again.';

  @override
  String get invitationDeclinedSuccess => 'Invitation declined.';

  @override
  String get invitationEmptyState =>
      'When someone invites you to save\ntogether, it will appear here.';

  @override
  String get invitationError => 'Could not send invitation. Try again.';

  @override
  String invitationSent(String email) {
    return '❤️ Invitation sent to $email!';
  }

  @override
  String get invitationSentError => 'Could not send invitation. Try again.';

  @override
  String invitationSentSuccess(String email) {
    return '❤️ Invitation sent to $email!';
  }

  @override
  String get inviteAnotherPartner => 'Invite Another Partner';

  @override
  String get invitePartner => 'Invite Partner';

  @override
  String get language => 'Language';

  @override
  String get leaveGoal => 'Leave Goal';

  @override
  String leaveGoalConfirmation(String name) {
    return 'Are you sure you want to leave \"$name\"? You will be removed from this couple goal and stop receiving reminders.';
  }

  @override
  String get leaveSharedGoalSubtitle => 'Stop syncing and cancel reminders';

  @override
  String get leaveSharedGoalTitle => 'Leave Shared Goal';

  @override
  String get leftGoalError => 'Failed to leave goal.';

  @override
  String leftGoalSuccess(String name) {
    return 'You have left \"$name\".';
  }

  @override
  String get lightMode => 'Light Mode';

  @override
  String get loadInvitationsError => 'Could not load invitations';

  @override
  String get locked => 'Locked';

  @override
  String get loggingOut => 'Logging out...';

  @override
  String get login => 'Log In';

  @override
  String get loginLink => 'Log In';

  @override
  String get loginRequired => 'You need to be logged in to create a goal.';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get logout => 'Log Out';

  @override
  String get markAsSaved => 'Mark as Saved';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get monthlyMaster => 'Monthly Master';

  @override
  String get monthlyMasterDesc => 'Save for 30 days in a row';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get multiplier => 'Multiplier';

  @override
  String get multiplierDesc => 'Exponential growth with a daily cap.';

  @override
  String get multiplierMethodOnboardingDesc =>
      'Exponential growth with a daily cap for big results.';

  @override
  String get multiplierMethodTitle => 'Multiplier';

  @override
  String get next => 'Next';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get noPendingInvitations => 'No pending invitations';

  @override
  String get notSet => 'Not set';

  @override
  String notificationBody(String name) {
    return 'Don\'t forget your \"$name\" goal today.';
  }

  @override
  String notificationBodyJoint(String name) {
    return 'Don\'t forget your joint savings for \"$name\" today.';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get ofLabel => 'of ';

  @override
  String get ok => 'OK';

  @override
  String get onboardingDesc1 =>
      'Choose from 8 different saving methods that fit your lifestyle';

  @override
  String get onboardingDesc2 =>
      'Visualize your savings with heatmaps and statistics';

  @override
  String get onboardingDesc3 =>
      'Unlock achievements and stay motivated with daily streaks';

  @override
  String get onboardingEducation => 'Education';

  @override
  String get onboardingEmergency => 'Emergency Fund';

  @override
  String get onboardingFun => 'Fun & Entertainment';

  @override
  String get onboardingGoalSubtitle =>
      'Choose what you\'d like to focus on first.';

  @override
  String get onboardingGoalTitle => 'What do you want\nto save for?';

  @override
  String get onboardingHome => 'Home';

  @override
  String get onboardingMethodSubtitle =>
      'Pick a method that fits your lifestyle.';

  @override
  String get onboardingMethodTitle => 'Save Smarter';

  @override
  String get onboardingTech => 'Tech & Gadgets';

  @override
  String get onboardingTitle1 => 'Save Smarter';

  @override
  String get onboardingTitle2 => 'Track Your Progress';

  @override
  String get onboardingTitle3 => 'Achieve Your Goals';

  @override
  String get onboardingTrackSubtitle =>
      'Visualize savings and unlock achievements.';

  @override
  String get onboardingTrackTitle => 'Track Your\nProgress';

  @override
  String get onboardingTravel => 'Travel';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get orLoginWith => 'or Login with';

  @override
  String get orSignUpWith => 'or Sign Up with';

  @override
  String get partnerEmailHint => 'Partner\'s email address';

  @override
  String get partnerInviteInfo =>
      'Your partner will receive an invitation to join this goal.';

  @override
  String get partnerLabel => 'Partner';

  @override
  String get password => 'Password';

  @override
  String get passwordMinChar => 'Min 6 characters';

  @override
  String get pause => 'Pause';

  @override
  String get penaltyMethod => 'Penalty';

  @override
  String get penaltyMethodDesc =>
      'Save a fixed amount each time you do a bad habit.';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get perfectMonth => 'Perfect Month';

  @override
  String get perfectMonthDesc => 'Save every day for a full month';

  @override
  String get perfectWeek => 'Perfect Week';

  @override
  String get perfectWeekDesc => 'Save every day for a full week';

  @override
  String get premium => 'Premium';

  @override
  String get premiumMethods => 'Premium';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get premiumSubtitle =>
      'Unlock exclusive challenges and advanced habit insights.';

  @override
  String get premiumUpgradeDesc =>
      'Get access to all 8 saving methods, unlimited goals, advanced statistics, cloud sync, custom notifications, and an ad-free experience.';

  @override
  String get premiumUpgradeTitle => 'Premium Upgrade';

  @override
  String get preview => 'Preview';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get proLabel => 'PRO';

  @override
  String get profile => 'Profile';

  @override
  String get progress => 'Progress';

  @override
  String get progressive => 'Progressive';

  @override
  String get progressiveDesc =>
      'Start small, increase daily. Day 1=\$1, Day 2=\$2...';

  @override
  String get progressiveMethodOnboardingDesc =>
      'Start small and increase daily. Day 1 = \$1, Day 2 = \$2...';

  @override
  String get progressiveMethodTitle => 'Progressive';

  @override
  String get quarterWay => '25% There';

  @override
  String get quarterWayDesc => 'Reach 25% of your goal';

  @override
  String get randomEnvelopes => 'Random (Envelopes)';

  @override
  String get randomEnvelopesDesc =>
      'Random amounts each day. Fun and surprising!';

  @override
  String get randomMethodOnboardingDesc =>
      'Random amounts each day. Fun and surprising!';

  @override
  String get randomMethodTitle => 'Random Envelopes';

  @override
  String get reachGoalInPrefix => 'You can reach your goal in just ';

  @override
  String get reachGoalInSuffix => '!';

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get register => 'Sign Up';

  @override
  String get remaining => 'Remaining';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String reminderUpdated(String time) {
    return 'Reminder updated to $time';
  }

  @override
  String get requiredReminder => 'Required — keep yourself on track';

  @override
  String get resetLinkSent => 'Check your email for a reset link.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resume => 'Resume';

  @override
  String get reverseProgressive => 'Reverse Progressive';

  @override
  String get reverseProgressiveDesc =>
      'Start high, decrease daily. High motivation early on.';

  @override
  String get save => 'Save';

  @override
  String savePercentage(String percentage) {
    return 'Save $percentage';
  }

  @override
  String get saveWithPartner => 'Save together with your partner';

  @override
  String get savingHeatmap => 'Saving Heatmap';

  @override
  String get selectColor => 'Select Color';

  @override
  String get selectIcon => 'Select Icon';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectMethod => 'Select Method';

  @override
  String get send => 'Send';

  @override
  String get sendInvitationNewPartner => 'Send invitation to a new partner';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get setTargetAmount =>
      'Set a target amount greater than \$0 for your goal.';

  @override
  String get settings => 'Settings';

  @override
  String get signUpLink => 'Sign Up';

  @override
  String get skip => 'Skip';

  @override
  String get someone => 'Someone';

  @override
  String get statistics => 'Statistics';

  @override
  String stepOfTotal(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get streak => 'Streak';

  @override
  String get streak3 => '3-Day Streak';

  @override
  String get streak3Desc => 'Save for 3 days in a row';

  @override
  String get streak7Subtitle => 'Save for 7 days in a row';

  @override
  String get streak7Title => '7-Day Streak';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get tapToSetReminder => 'Tap to set a reminder time';

  @override
  String get targetAmount => 'Target Amount';

  @override
  String get targetAmountExample => '1000';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisWeek => 'This Week';

  @override
  String get timeToSave => 'Time to save!';

  @override
  String get today => 'Today';

  @override
  String get todayLabel => 'Today';

  @override
  String get todaysSaving => 'Today\'s Saving';

  @override
  String get totalLabel => 'Total: ';

  @override
  String get totalSaved => 'Total Saved';

  @override
  String get totalTargetLabel => 'Total Target';

  @override
  String get turnIntoCoupleGoal => 'Turn this into a couple goal';

  @override
  String get unknownGoal => 'Unknown Goal';

  @override
  String get unlocked => 'Unlocked';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get userLabel => 'You';

  @override
  String get version => 'Version';

  @override
  String get viewProfile => 'View profile';

  @override
  String get weeklyChallenge => 'Weekly Challenge';

  @override
  String get weeklyChallengeDesc => 'Increase your saving each week.';

  @override
  String get weeklyWarrior => 'Weekly Warrior';

  @override
  String get weeklyWarriorDesc => 'Save for 7 days in a row';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get yesterdayLabel => 'Yesterday';
}
