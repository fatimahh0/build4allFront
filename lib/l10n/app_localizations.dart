import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please sign in to continue.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number.'**
  String get invalidPhone;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long.'**
  String get passwordTooShort;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorGeneric;

  /// No description provided for @noAccountText.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountText;

  /// No description provided for @signUpText.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUpText;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginWithEmail;

  /// No description provided for @loginWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get loginWithPhone;

  /// No description provided for @loginMissingIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or phone number.'**
  String get loginMissingIdentifier;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to sign up.'**
  String get registerSubtitle;

  /// No description provided for @registerStep1Of3.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3'**
  String get registerStep1Of3;

  /// No description provided for @registerWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign up with email'**
  String get registerWithEmail;

  /// No description provided for @registerWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Sign up with phone'**
  String get registerWithPhone;

  /// No description provided for @registerContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get registerContinueButton;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @alreadyHaveAccountText.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountText;

  /// No description provided for @verifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get verifyCodeTitle;

  /// No description provided for @verifyCodeSubtitleEmail.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email.'**
  String get verifyCodeSubtitleEmail;

  /// No description provided for @verifyCodeSubtitlePhone.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your phone.'**
  String get verifyCodeSubtitlePhone;

  /// No description provided for @verificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCodeLabel;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid verification code.'**
  String get invalidVerificationCode;

  /// No description provided for @verifyButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButtonLabel;

  /// No description provided for @completeProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get completeProfileTitle;

  /// No description provided for @completeProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a username and your real name.'**
  String get completeProfileSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstNameLabel;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastNameLabel;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters.'**
  String get usernameTooShort;

  /// No description provided for @publicProfileLabel.
  ///
  /// In en, this message translates to:
  /// **'Public profile'**
  String get publicProfileLabel;

  /// No description provided for @publicProfileDescription.
  ///
  /// In en, this message translates to:
  /// **'If enabled, your profile and activities can be found by other users.'**
  String get publicProfileDescription;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfileButton;

  /// No description provided for @profileCompletedSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Profile completed successfully. You can now log in.'**
  String get profileCompletedSuccessMessage;

  /// No description provided for @profileCompletedErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete profile. Please try again.'**
  String get profileCompletedErrorMessage;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon.'**
  String get featureComingSoon;

  /// No description provided for @changePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add a profile photo'**
  String get changePhotoHint;

  /// No description provided for @previousStepButton.
  ///
  /// In en, this message translates to:
  /// **'Previous Step'**
  String get previousStepButton;

  /// No description provided for @completeProfileNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile - Names'**
  String get completeProfileNamesTitle;

  /// No description provided for @completeProfileNamesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please provide your first and last name.'**
  String get completeProfileNamesSubtitle;

  /// No description provided for @firstNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get lastNameHint;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @completeProfileUsernameTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile - Username'**
  String get completeProfileUsernameTitle;

  /// No description provided for @completeProfileUsernameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username for your account.'**
  String get completeProfileUsernameSubtitle;

  /// No description provided for @completeProfilePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile - Photo'**
  String get completeProfilePhotoTitle;

  /// No description provided for @completeProfilePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a profile picture to personalize your account.'**
  String get completeProfilePhotoSubtitle;

  /// No description provided for @nextStepButton.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get nextStepButton;

  /// No description provided for @home_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome 👋'**
  String get home_welcome;

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search activities, items...'**
  String get home_search_hint;

  /// No description provided for @home_banner_title.
  ///
  /// In en, this message translates to:
  /// **'Discover your next hobby'**
  String get home_banner_title;

  /// No description provided for @home_banner_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore activities, classes and more near you.'**
  String get home_banner_subtitle;

  /// No description provided for @home_banner_button.
  ///
  /// In en, this message translates to:
  /// **'Start exploring'**
  String get home_banner_button;

  /// No description provided for @home_items_default_title.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get home_items_default_title;

  /// No description provided for @home_recommended_title.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get home_recommended_title;

  /// No description provided for @home_popular_title.
  ///
  /// In en, this message translates to:
  /// **'Popular now'**
  String get home_popular_title;

  /// No description provided for @home_bookings_title.
  ///
  /// In en, this message translates to:
  /// **'Upcoming bookings'**
  String get home_bookings_title;

  /// No description provided for @home_reviews_title.
  ///
  /// In en, this message translates to:
  /// **'Latest reviews'**
  String get home_reviews_title;

  /// No description provided for @connection_offline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get connection_offline;

  /// No description provided for @connection_server_down.
  ///
  /// In en, this message translates to:
  /// **'Server is not responding'**
  String get connection_server_down;

  /// No description provided for @connection_issue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get connection_issue;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
