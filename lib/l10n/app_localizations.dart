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

  /// No description provided for @abandon.
  ///
  /// In en, this message translates to:
  /// **'Abandon'**
  String get abandon;

  /// No description provided for @aboutKipera.
  ///
  /// In en, this message translates to:
  /// **'About Kipera'**
  String get aboutKipera;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @activeGoalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Goals'**
  String get activeGoalsLabel;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLabel;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

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

  /// No description provided for @alreadyCheckedIn.
  ///
  /// In en, this message translates to:
  /// **'You already checked in today! Come back tomorrow.'**
  String get alreadyCheckedIn;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log In'**
  String get alreadyHaveAccount;

  /// No description provided for @alreadyHaveAccountStart.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccountStart;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kipera'**
  String get appName;

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

  /// No description provided for @byGoal.
  ///
  /// In en, this message translates to:
  /// **'By Goal'**
  String get byGoal;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

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

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @checkInGoalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found. It may have been deleted.'**
  String get checkInGoalNotFound;

  /// No description provided for @chooseReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Choose a daily reminder time to stay on track.'**
  String get chooseReminderTime;

  /// No description provided for @club100.
  ///
  /// In en, this message translates to:
  /// **'\$100 Club'**
  String get club100;

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

  /// No description provided for @club100Desc.
  ///
  /// In en, this message translates to:
  /// **'Save \$100 in total'**
  String get club100Desc;

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

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @coupleGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Couple Goal'**
  String get coupleGoalLabel;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @createGoalAmountValidation.
  ///
  /// In en, this message translates to:
  /// **'Set a target amount greater than \$0 for your goal.'**
  String get createGoalAmountValidation;

  /// No description provided for @createGoalError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong creating your goal. Please try again.'**
  String get createGoalError;

  /// No description provided for @createGoalLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to create a goal.'**
  String get createGoalLoginRequired;

  /// No description provided for @createGoalNameValidation.
  ///
  /// In en, this message translates to:
  /// **'Give your goal a name so you can identify it easily.'**
  String get createGoalNameValidation;

  /// No description provided for @createGoalPartnerEmailValidation.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address for your partner.'**
  String get createGoalPartnerEmailValidation;

  /// No description provided for @createGoalTimeValidation.
  ///
  /// In en, this message translates to:
  /// **'Choose a daily reminder time to stay on track.'**
  String get createGoalTimeValidation;

  /// No description provided for @createGoalValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name and amount'**
  String get createGoalValidation;

  /// No description provided for @createYourFirstGoal.
  ///
  /// In en, this message translates to:
  /// **'Create your first savings goal!'**
  String get createYourFirstGoal;

  /// No description provided for @currentlyAt.
  ///
  /// In en, this message translates to:
  /// **'Currently {time}'**
  String currentlyAt(String time);

  /// No description provided for @dailyReminderAt.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder at {time}'**
  String dailyReminderAt(String time);

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day {number}'**
  String dayLabel(int number);

  /// No description provided for @dayLeftToGoal.
  ///
  /// In en, this message translates to:
  /// **'day left to reach your goal'**
  String get dayLeftToGoal;

  /// No description provided for @dayOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Day {completed} of {total}'**
  String dayOfTotal(int completed, int total);

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String daysCount(int count);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @defaultUserName.
  ///
  /// In en, this message translates to:
  /// **'Saver'**
  String get defaultUserName;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteGoalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteGoalConfirmation(String name);

  /// No description provided for @deleteGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoalTitle;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get dontHaveAccount;

  /// No description provided for @dontHaveAccountStart.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccountStart;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editGoalName.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal Name'**
  String get editGoalName;

  /// No description provided for @editReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder Time'**
  String get editReminderTime;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @enterNameAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a goal name and target amount to continue.'**
  String get enterNameAndAmount;

  /// No description provided for @enterPartnerEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address for your partner.'**
  String get enterPartnerEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @errorCreatingGoal.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong creating your goal. Please try again.'**
  String get errorCreatingGoal;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorPrefix(String error);

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

  /// No description provided for @expectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected: '**
  String get expectedLabel;

  /// No description provided for @fillInformation.
  ///
  /// In en, this message translates to:
  /// **'Fill your information below'**
  String get fillInformation;

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

  /// No description provided for @fixedMethodOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Save the same amount every day. Simple and consistent.'**
  String get fixedMethodOnboardingDesc;

  /// No description provided for @fixedMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Fixed Daily'**
  String get fixedMethodTitle;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to get the password reset link.'**
  String get forgotPasswordDesc;

  /// No description provided for @freeMethods.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeMethods;

  /// No description provided for @freePlanStatus.
  ///
  /// In en, this message translates to:
  /// **'You\'re on Free Plan'**
  String get freePlanStatus;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @giveGoalName.
  ///
  /// In en, this message translates to:
  /// **'Give your goal a name so you can identify it easily.'**
  String get giveGoalName;

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

  /// No description provided for @goalAchievedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete 100% of a goal'**
  String get goalAchievedSubtitle;

  /// No description provided for @goalAchievedTitle.
  ///
  /// In en, this message translates to:
  /// **'Goal Achieved!'**
  String get goalAchievedTitle;

  /// No description provided for @goalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Goal Completed!'**
  String get goalCompleted;

  /// No description provided for @goalCreated.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" created! Your saving journey starts now.'**
  String goalCreated(String name);

  /// No description provided for @goalDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has been deleted.'**
  String goalDeletedSuccess(String name);

  /// No description provided for @goalLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Goal: {name}'**
  String goalLabelPrefix(String name);

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @goalNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Trip to Europe'**
  String get goalNameExample;

  /// No description provided for @goalNameHint.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalNameHint;

  /// No description provided for @goalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Goal not found'**
  String get goalNotFound;

  /// No description provided for @goalReachedLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal reached! '**
  String get goalReachedLabel;

  /// No description provided for @goalRenamed.
  ///
  /// In en, this message translates to:
  /// **'Goal renamed to \"{name}\"'**
  String goalRenamed(String name);

  /// No description provided for @goalsProgress.
  ///
  /// In en, this message translates to:
  /// **'Goals Progress'**
  String get goalsProgress;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

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

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String helloUser(String name);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get invalidEmailError;

  /// No description provided for @invitationAcceptedError.
  ///
  /// In en, this message translates to:
  /// **'Could not accept invitation. Try again.'**
  String get invitationAcceptedError;

  /// No description provided for @invitationAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'❤️ Invitation accepted! You can now save together.'**
  String get invitationAcceptedSuccess;

  /// No description provided for @invitationDeclinedError.
  ///
  /// In en, this message translates to:
  /// **'Could not decline invitation. Try again.'**
  String get invitationDeclinedError;

  /// No description provided for @invitationDeclinedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined.'**
  String get invitationDeclinedSuccess;

  /// No description provided for @invitationEmptyState.
  ///
  /// In en, this message translates to:
  /// **'When someone invites you to save\ntogether, it will appear here.'**
  String get invitationEmptyState;

  /// No description provided for @invitationError.
  ///
  /// In en, this message translates to:
  /// **'Could not send invitation. Try again.'**
  String get invitationError;

  /// No description provided for @invitationSent.
  ///
  /// In en, this message translates to:
  /// **'❤️ Invitation sent to {email}!'**
  String invitationSent(String email);

  /// No description provided for @invitationSentError.
  ///
  /// In en, this message translates to:
  /// **'Could not send invitation. Try again.'**
  String get invitationSentError;

  /// No description provided for @invitationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'❤️ Invitation sent to {email}!'**
  String invitationSentSuccess(String email);

  /// No description provided for @inviteAnotherPartner.
  ///
  /// In en, this message translates to:
  /// **'Invite Another Partner'**
  String get inviteAnotherPartner;

  /// No description provided for @invitePartner.
  ///
  /// In en, this message translates to:
  /// **'Invite Partner'**
  String get invitePartner;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @leaveGoal.
  ///
  /// In en, this message translates to:
  /// **'Leave Goal'**
  String get leaveGoal;

  /// No description provided for @leaveGoalConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave \"{name}\"? You will be removed from this couple goal and stop receiving reminders.'**
  String leaveGoalConfirmation(String name);

  /// No description provided for @leaveSharedGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop syncing and cancel reminders'**
  String get leaveSharedGoalSubtitle;

  /// No description provided for @leaveSharedGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Shared Goal'**
  String get leaveSharedGoalTitle;

  /// No description provided for @leftGoalError.
  ///
  /// In en, this message translates to:
  /// **'Failed to leave goal.'**
  String get leftGoalError;

  /// No description provided for @leftGoalSuccess.
  ///
  /// In en, this message translates to:
  /// **'You have left \"{name}\".'**
  String leftGoalSuccess(String name);

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @loadInvitationsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load invitations'**
  String get loadInvitationsError;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get loggingOut;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginLink;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to create a goal.'**
  String get loginRequired;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @markAsSaved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Saved'**
  String get markAsSaved;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

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

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

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

  /// No description provided for @multiplierMethodOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Exponential growth with a daily cap for big results.'**
  String get multiplierMethodOnboardingDesc;

  /// No description provided for @multiplierMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get multiplierMethodTitle;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noGoalsYet.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get noGoalsYet;

  /// No description provided for @noPendingInvitations.
  ///
  /// In en, this message translates to:
  /// **'No pending invitations'**
  String get noPendingInvitations;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @notificationBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget your \"{name}\" goal today.'**
  String notificationBody(String name);

  /// No description provided for @notificationBodyJoint.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget your joint savings for \"{name}\" today.'**
  String notificationBodyJoint(String name);

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of '**
  String get ofLabel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Choose from 8 different saving methods that fit your lifestyle'**
  String get onboardingDesc1;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Visualize your savings with heatmaps and statistics'**
  String get onboardingDesc2;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Unlock achievements and stay motivated with daily streaks'**
  String get onboardingDesc3;

  /// No description provided for @onboardingEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get onboardingEducation;

  /// No description provided for @onboardingEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get onboardingEmergency;

  /// No description provided for @onboardingFun.
  ///
  /// In en, this message translates to:
  /// **'Fun & Entertainment'**
  String get onboardingFun;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose what you\'d like to focus on first.'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want\nto save for?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get onboardingHome;

  /// No description provided for @onboardingMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a method that fits your lifestyle.'**
  String get onboardingMethodSubtitle;

  /// No description provided for @onboardingMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Smarter'**
  String get onboardingMethodTitle;

  /// No description provided for @onboardingTech.
  ///
  /// In en, this message translates to:
  /// **'Tech & Gadgets'**
  String get onboardingTech;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Save Smarter'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Achieve Your Goals'**
  String get onboardingTitle3;

  /// No description provided for @onboardingTrackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visualize savings and unlock achievements.'**
  String get onboardingTrackSubtitle;

  /// No description provided for @onboardingTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your\nProgress'**
  String get onboardingTrackTitle;

  /// No description provided for @onboardingTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get onboardingTravel;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'or Login with'**
  String get orLoginWith;

  /// No description provided for @orSignUpWith.
  ///
  /// In en, this message translates to:
  /// **'or Sign Up with'**
  String get orSignUpWith;

  /// No description provided for @partnerEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Partner\'s email address'**
  String get partnerEmailHint;

  /// No description provided for @partnerInviteInfo.
  ///
  /// In en, this message translates to:
  /// **'Your partner will receive an invitation to join this goal.'**
  String get partnerInviteInfo;

  /// No description provided for @partnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get partnerLabel;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordMinChar.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get passwordMinChar;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

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

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumMethods.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumMethods;

  /// No description provided for @premiumPlan.
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// No description provided for @premiumSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock exclusive challenges and advanced habit insights.'**
  String get premiumSubtitle;

  /// No description provided for @premiumUpgradeDesc.
  ///
  /// In en, this message translates to:
  /// **'Get access to all 8 saving methods, unlimited goals, advanced statistics, cloud sync, custom notifications, and an ad-free experience.'**
  String get premiumUpgradeDesc;

  /// No description provided for @premiumUpgradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Upgrade'**
  String get premiumUpgradeTitle;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @proLabel.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proLabel;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

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

  /// No description provided for @progressiveMethodOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Start small and increase daily. Day 1 = \$1, Day 2 = \$2...'**
  String get progressiveMethodOnboardingDesc;

  /// No description provided for @progressiveMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Progressive'**
  String get progressiveMethodTitle;

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

  /// No description provided for @randomMethodOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Random amounts each day. Fun and surprising!'**
  String get randomMethodOnboardingDesc;

  /// No description provided for @randomMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'Random Envelopes'**
  String get randomMethodTitle;

  /// No description provided for @reachGoalInPrefix.
  ///
  /// In en, this message translates to:
  /// **'You can reach your goal in just '**
  String get reachGoalInPrefix;

  /// No description provided for @reachGoalInSuffix.
  ///
  /// In en, this message translates to:
  /// **'!'**
  String get reachGoalInSuffix;

  /// No description provided for @reachGoalRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {day left to reach your goal} other {days left to reach your goal}}'**
  String reachGoalRemaining(int count);

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @reminderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated to {time}'**
  String reminderUpdated(String time);

  /// No description provided for @requiredReminder.
  ///
  /// In en, this message translates to:
  /// **'Required — keep yourself on track'**
  String get requiredReminder;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a reset link.'**
  String get resetLinkSent;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

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

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @savePercentage.
  ///
  /// In en, this message translates to:
  /// **'Save {percentage}'**
  String savePercentage(String percentage);

  /// No description provided for @saveWithPartner.
  ///
  /// In en, this message translates to:
  /// **'Save together with your partner'**
  String get saveWithPartner;

  /// No description provided for @savingHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Saving Heatmap'**
  String get savingHeatmap;

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

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get selectMethod;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendInvitationNewPartner.
  ///
  /// In en, this message translates to:
  /// **'Send invitation to a new partner'**
  String get sendInvitationNewPartner;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @setTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Set a target amount greater than \$0 for your goal.'**
  String get setTargetAmount;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signUpLink.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpLink;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @someone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get someone;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @stepOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String stepOfTotal(int current, int total);

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

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

  /// No description provided for @streak7Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Save for 7 days in a row'**
  String get streak7Subtitle;

  /// No description provided for @streak7Title.
  ///
  /// In en, this message translates to:
  /// **'7-Day Streak'**
  String get streak7Title;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @tapToSetReminder.
  ///
  /// In en, this message translates to:
  /// **'Tap to set a reminder time'**
  String get tapToSetReminder;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @targetAmountExample.
  ///
  /// In en, this message translates to:
  /// **'1000'**
  String get targetAmountExample;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get thisActionCannotBeUndone;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @timeToSave.
  ///
  /// In en, this message translates to:
  /// **'Time to save!'**
  String get timeToSave;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @todaysSaving.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Saving'**
  String get todaysSaving;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total: '**
  String get totalLabel;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get totalSaved;

  /// No description provided for @totalTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Target'**
  String get totalTargetLabel;

  /// No description provided for @turnIntoCoupleGoal.
  ///
  /// In en, this message translates to:
  /// **'Turn this into a couple goal'**
  String get turnIntoCoupleGoal;

  /// No description provided for @unknownGoal.
  ///
  /// In en, this message translates to:
  /// **'Unknown Goal'**
  String get unknownGoal;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get userLabel;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

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

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// No description provided for @yesterdayLabel.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayLabel;
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
