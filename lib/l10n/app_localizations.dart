import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kipera'**
  String get appName;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Save Smarter'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Choose from 8 different saving methods that fit your lifestyle'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Visualize your savings with heatmaps and statistics'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Achieve Your Goals'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Unlock achievements and stay motivated with daily streaks'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get alreadyHaveAccount;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @selectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get selectMethod;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get selectColor;

  /// No description provided for @selectIcon.
  ///
  /// In en, this message translates to:
  /// **'Select Icon'**
  String get selectIcon;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @abandon.
  ///
  /// In en, this message translates to:
  /// **'Abandon'**
  String get abandon;

  /// No description provided for @todaysSaving.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Saving'**
  String get todaysSaving;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @markAsSaved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Saved'**
  String get markAsSaved;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get totalSaved;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @progressive.
  ///
  /// In en, this message translates to:
  /// **'Progressive'**
  String get progressive;

  /// No description provided for @progressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Start small, increase daily. Day 1=\$1, Day 2=\$2...'**
  String get progressiveDesc;

  /// No description provided for @fixedDaily.
  ///
  /// In en, this message translates to:
  /// **'Fixed Daily'**
  String get fixedDaily;

  /// No description provided for @fixedDailyDesc.
  ///
  /// In en, this message translates to:
  /// **'Same amount every day. Simple and consistent.'**
  String get fixedDailyDesc;

  /// No description provided for @reverseProgressive.
  ///
  /// In en, this message translates to:
  /// **'Reverse Progressive'**
  String get reverseProgressive;

  /// No description provided for @reverseProgressiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Start high, decrease daily. High motivation early on.'**
  String get reverseProgressiveDesc;

  /// No description provided for @weeklyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenge'**
  String get weeklyChallenge;

  /// No description provided for @weeklyChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase your saving each week.'**
  String get weeklyChallengeDesc;

  /// No description provided for @randomEnvelopes.
  ///
  /// In en, this message translates to:
  /// **'Random (Envelopes)'**
  String get randomEnvelopes;

  /// No description provided for @randomEnvelopesDesc.
  ///
  /// In en, this message translates to:
  /// **'Random amounts each day. Fun and surprising!'**
  String get randomEnvelopesDesc;

  /// No description provided for @multiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get multiplier;

  /// No description provided for @multiplierDesc.
  ///
  /// In en, this message translates to:
  /// **'Exponential growth with a daily cap.'**
  String get multiplierDesc;

  /// No description provided for @biWeeklySteps.
  ///
  /// In en, this message translates to:
  /// **'Bi-Weekly Steps'**
  String get biWeeklySteps;

  /// No description provided for @biWeeklyStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase amount every two weeks.'**
  String get biWeeklyStepsDesc;

  /// No description provided for @penaltyMethod.
  ///
  /// In en, this message translates to:
  /// **'Penalty'**
  String get penaltyMethod;

  /// No description provided for @penaltyMethodDesc.
  ///
  /// In en, this message translates to:
  /// **'Save a fixed amount each time you do a bad habit.'**
  String get penaltyMethodDesc;

  /// No description provided for @freeMethods.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeMethods;

  /// No description provided for @premiumMethods.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumMethods;

  /// No description provided for @estimatedDays.
  ///
  /// In en, this message translates to:
  /// **'Estimated: {days} days'**
  String estimatedDays(int days);

  /// No description provided for @estimatedTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: \${amount}'**
  String estimatedTotal(String amount);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoalsYet;

  /// No description provided for @createYourFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Create your first savings goal!'**
  String get createYourFirstGoal;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal Completed!'**
  String get goalCompleted;

  /// No description provided for @firstStep.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get firstStep;

  /// No description provided for @firstStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first saving'**
  String get firstStepDesc;

  /// No description provided for @streak3.
  ///
  /// In en, this message translates to:
  /// **'3-Day Streak'**
  String get streak3;

  /// No description provided for @streak3Desc.
  ///
  /// In en, this message translates to:
  /// **'Save for 3 days in a row'**
  String get streak3Desc;

  /// No description provided for @weeklyWarrior.
  ///
  /// In en, this message translates to:
  /// **'Weekly Warrior'**
  String get weeklyWarrior;

  /// No description provided for @weeklyWarriorDesc.
  ///
  /// In en, this message translates to:
  /// **'Save for 7 days in a row'**
  String get weeklyWarriorDesc;

  /// No description provided for @biweeklyChampion.
  ///
  /// In en, this message translates to:
  /// **'Biweekly Champion'**
  String get biweeklyChampion;

  /// No description provided for @biweeklyChampionDesc.
  ///
  /// In en, this message translates to:
  /// **'Save for 14 days in a row'**
  String get biweeklyChampionDesc;

  /// No description provided for @monthlyMaster.
  ///
  /// In en, this message translates to:
  /// **'Monthly Master'**
  String get monthlyMaster;

  /// No description provided for @monthlyMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Save for 30 days in a row'**
  String get monthlyMasterDesc;

  /// No description provided for @centurion.
  ///
  /// In en, this message translates to:
  /// **'Centurion'**
  String get centurion;

  /// No description provided for @centurionDesc.
  ///
  /// In en, this message translates to:
  /// **'Save for 100 days in a row'**
  String get centurionDesc;

  /// No description provided for @quarterWay.
  ///
  /// In en, this message translates to:
  /// **'25% There'**
  String get quarterWay;

  /// No description provided for @quarterWayDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 25% of your goal'**
  String get quarterWayDesc;

  /// No description provided for @halfWay.
  ///
  /// In en, this message translates to:
  /// **'Halfway!'**
  String get halfWay;

  /// No description provided for @halfWayDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 50% of your goal'**
  String get halfWayDesc;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost There!'**
  String get almostThere;

  /// No description provided for @almostThereDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach 75% of your goal'**
  String get almostThereDesc;

  /// No description provided for @goalAchieved.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved!'**
  String get goalAchieved;

  /// No description provided for @goalAchievedDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 100% of your goal'**
  String get goalAchievedDesc;

  /// No description provided for @club100.
  ///
  /// In en, this message translates to:
  /// **'\$100 Club'**
  String get club100;

  /// No description provided for @club100Desc.
  ///
  /// In en, this message translates to:
  /// **'Save \$100 in total'**
  String get club100Desc;

  /// No description provided for @club1000.
  ///
  /// In en, this message translates to:
  /// **'\$1,000 Club'**
  String get club1000;

  /// No description provided for @club1000Desc.
  ///
  /// In en, this message translates to:
  /// **'Save \$1,000 in total'**
  String get club1000Desc;

  /// No description provided for @perfectWeek.
  ///
  /// In en, this message translates to:
  /// **'Perfect Week'**
  String get perfectWeek;

  /// No description provided for @perfectWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'Save every day for a full week'**
  String get perfectWeekDesc;

  /// No description provided for @perfectMonth.
  ///
  /// In en, this message translates to:
  /// **'Perfect Month'**
  String get perfectMonth;

  /// No description provided for @perfectMonthDesc.
  ///
  /// In en, this message translates to:
  /// **'Save every day for a full month'**
  String get perfectMonthDesc;

  /// No description provided for @comeback.
  ///
  /// In en, this message translates to:
  /// **'Triumphant Return'**
  String get comeback;

  /// No description provided for @comebackDesc.
  ///
  /// In en, this message translates to:
  /// **'Resume saving after 3+ days off'**
  String get comebackDesc;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @aboutKipera.
  ///
  /// In en, this message translates to:
  /// **'About Kipera'**
  String get aboutKipera;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
