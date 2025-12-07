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
  /// **'Search products, brands...'**
  String get home_search_hint;

  /// No description provided for @home_banner_title.
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get home_banner_title;

  /// No description provided for @home_banner_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Save up to 50% on selected items.'**
  String get home_banner_subtitle;

  /// No description provided for @home_banner_button.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
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

  /// No description provided for @home_flash_sale_title.
  ///
  /// In en, this message translates to:
  /// **'Flash Sale'**
  String get home_flash_sale_title;

  /// No description provided for @home_new_arrivals_title.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get home_new_arrivals_title;

  /// No description provided for @home_best_sellers_title.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get home_best_sellers_title;

  /// No description provided for @home_top_rated_title.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get home_top_rated_title;

  /// No description provided for @home_why_shop_title.
  ///
  /// In en, this message translates to:
  /// **'Why Shop With Us'**
  String get home_why_shop_title;

  /// No description provided for @home_why_shop_free_shipping_title.
  ///
  /// In en, this message translates to:
  /// **'Free Shipping'**
  String get home_why_shop_free_shipping_title;

  /// No description provided for @home_why_shop_free_shipping_subtitle.
  ///
  /// In en, this message translates to:
  /// **'On all orders over \$50'**
  String get home_why_shop_free_shipping_subtitle;

  /// No description provided for @home_why_shop_easy_returns_title.
  ///
  /// In en, this message translates to:
  /// **'Easy Returns'**
  String get home_why_shop_easy_returns_title;

  /// No description provided for @home_why_shop_easy_returns_subtitle.
  ///
  /// In en, this message translates to:
  /// **'30-day return policy'**
  String get home_why_shop_easy_returns_subtitle;

  /// No description provided for @home_why_shop_secure_payment_title.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment'**
  String get home_why_shop_secure_payment_title;

  /// No description provided for @home_why_shop_secure_payment_subtitle.
  ///
  /// In en, this message translates to:
  /// **'100% protected transactions'**
  String get home_why_shop_secure_payment_subtitle;

  /// No description provided for @home_why_shop_support_title.
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get home_why_shop_support_title;

  /// No description provided for @home_why_shop_support_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Always here to help you'**
  String get home_why_shop_support_subtitle;

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

  /// No description provided for @profile_login_required.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view your profile.'**
  String get profile_login_required;

  /// No description provided for @connection_issue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get connection_issue;

  /// No description provided for @explore_title.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore_title;

  /// No description provided for @explore_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search  places...'**
  String get explore_search_hint;

  /// No description provided for @explore_items_title.
  ///
  /// In en, this message translates to:
  /// **'All activities'**
  String get explore_items_title;

  /// No description provided for @explore_empty_message.
  ///
  /// In en, this message translates to:
  /// **'No results found. Try another keyword.'**
  String get explore_empty_message;

  /// No description provided for @explore_category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get explore_category_all;

  /// No description provided for @explore_results_label.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
  String explore_results_label(int count);

  /// No description provided for @explore_sort_relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get explore_sort_relevance;

  /// No description provided for @explore_sort_price_low_high.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get explore_sort_price_low_high;

  /// No description provided for @explore_sort_price_high_low.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get explore_sort_price_high_low;

  /// No description provided for @explore_sort_date_soonest.
  ///
  /// In en, this message translates to:
  /// **'Soonest date'**
  String get explore_sort_date_soonest;

  /// No description provided for @profileMotto.
  ///
  /// In en, this message translates to:
  /// **'Live your hobby!'**
  String get profileMotto;

  /// No description provided for @profile_load_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile. Please try again.'**
  String get profile_load_error;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @manageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get manageAccount;

  /// No description provided for @profileMakePrivate.
  ///
  /// In en, this message translates to:
  /// **'Make profile private'**
  String get profileMakePrivate;

  /// No description provided for @profileMakePublic.
  ///
  /// In en, this message translates to:
  /// **'Make profile public'**
  String get profileMakePublic;

  /// No description provided for @setInactive.
  ///
  /// In en, this message translates to:
  /// **'Set account inactive'**
  String get setInactive;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutConfirm;

  /// No description provided for @deactivate_title.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get deactivate_title;

  /// No description provided for @deactivate_warning.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to confirm deactivation.'**
  String get deactivate_warning;

  /// No description provided for @current_password_label.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get current_password_label;

  /// No description provided for @language_note.
  ///
  /// In en, this message translates to:
  /// **'Changing language will restart some screens.'**
  String get language_note;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your app content and settings.'**
  String get adminDashboardSubtitle;

  /// No description provided for @adminProductsTitle.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get adminProductsTitle;

  /// No description provided for @adminProductsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No products yet. Tap + to add your first product.'**
  String get adminProductsEmpty;

  /// No description provided for @adminProductsNewArrivals.
  ///
  /// In en, this message translates to:
  /// **'New arrivals'**
  String get adminProductsNewArrivals;

  /// No description provided for @adminProductsBestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best sellers'**
  String get adminProductsBestSellers;

  /// No description provided for @adminProductsDiscounted.
  ///
  /// In en, this message translates to:
  /// **'Discounted products'**
  String get adminProductsDiscounted;

  /// No description provided for @adminProductsSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get adminProductsSearchPlaceholder;

  /// No description provided for @accountInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive'**
  String get accountInactiveTitle;

  /// No description provided for @accountInactiveBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is currently inactive. Do you want to reactivate it to continue?'**
  String get accountInactiveBody;

  /// No description provided for @reactivateButton.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get reactivateButton;

  /// No description provided for @accountReactivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been reactivated successfully'**
  String get accountReactivated;

  /// No description provided for @chooseSignInRole.
  ///
  /// In en, this message translates to:
  /// **'Choose how to sign in'**
  String get chooseSignInRole;

  /// No description provided for @enterAsOwner.
  ///
  /// In en, this message translates to:
  /// **'Enter as Owner (Admin)'**
  String get enterAsOwner;

  /// No description provided for @enterAsUser.
  ///
  /// In en, this message translates to:
  /// **'Enter as User'**
  String get enterAsUser;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @loginInactiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate your account?'**
  String get loginInactiveTitle;

  /// No description provided for @loginInactiveMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account \"{name}\" is currently inactive. Do you want to reactivate it and continue?'**
  String loginInactiveMessage(Object name);

  /// No description provided for @loginInactiveReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get loginInactiveReactivate;

  /// No description provided for @loginInactiveCancel.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get loginInactiveCancel;

  /// No description provided for @loginInactiveRequired.
  ///
  /// In en, this message translates to:
  /// **'You must reactivate your account to sign in as user.'**
  String get loginInactiveRequired;

  /// No description provided for @loginChooseRoleTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how to sign in'**
  String get loginChooseRoleTitle;

  /// No description provided for @loginEnterAsOwner.
  ///
  /// In en, this message translates to:
  /// **'Enter as Owner (Admin)'**
  String get loginEnterAsOwner;

  /// No description provided for @loginEnterAsUser.
  ///
  /// In en, this message translates to:
  /// **'Enter as User'**
  String get loginEnterAsUser;

  /// No description provided for @loginRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role:'**
  String get loginRoleLabel;

  /// No description provided for @loginUserFallbackLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get loginUserFallbackLabel;

  /// No description provided for @loginInactiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been reactivated successfully.'**
  String get loginInactiveSuccess;

  /// No description provided for @productBadgeOnSale.
  ///
  /// In en, this message translates to:
  /// **'On sale'**
  String get productBadgeOnSale;

  /// No description provided for @productStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get productStatusDraft;

  /// No description provided for @productStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get productStatusActive;

  /// No description provided for @productStatusArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get productStatusArchived;

  /// No description provided for @errorNetworkNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet or server unreachable.'**
  String get errorNetworkNoInternet;

  /// No description provided for @errorNetworkServerDown.
  ///
  /// In en, this message translates to:
  /// **'The server is not responding. Please try again later.'**
  String get errorNetworkServerDown;

  /// No description provided for @errorServerUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected server error. Please try again.'**
  String get errorServerUnexpected;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorAuthUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get errorAuthUnauthorized;

  /// No description provided for @errorAuthForbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to perform this action.'**
  String get errorAuthForbidden;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutLabel;

  /// No description provided for @adminDashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get adminDashboardQuickActions;

  /// No description provided for @adminOverviewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Overview & analytics'**
  String get adminOverviewAnalytics;

  /// No description provided for @adminProjectsOwners.
  ///
  /// In en, this message translates to:
  /// **'Projects & owners'**
  String get adminProjectsOwners;

  /// No description provided for @adminUsersManagers.
  ///
  /// In en, this message translates to:
  /// **'Users & managers'**
  String get adminUsersManagers;

  /// No description provided for @adminSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminSettings;

  /// No description provided for @adminSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {role}'**
  String adminSignedInAs(Object role);

  /// No description provided for @adminProductCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create product'**
  String get adminProductCreateTitle;

  /// No description provided for @adminProductNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get adminProductNameLabel;

  /// No description provided for @adminProductNameHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Samsung laptop'**
  String get adminProductNameHint;

  /// No description provided for @adminProductNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get adminProductNameRequired;

  /// No description provided for @adminProductDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get adminProductDescriptionLabel;

  /// No description provided for @adminProductDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Short description of the product'**
  String get adminProductDescriptionHint;

  /// No description provided for @adminProductPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get adminProductPriceLabel;

  /// No description provided for @adminProductPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get adminProductPriceRequired;

  /// No description provided for @adminProductPriceInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price greater than 0'**
  String get adminProductPriceInvalid;

  /// No description provided for @adminProductStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity'**
  String get adminProductStockLabel;

  /// No description provided for @adminProductStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get adminProductStatusLabel;

  /// No description provided for @adminProductImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get adminProductImageUrlLabel;

  /// No description provided for @adminProductSkuLabel.
  ///
  /// In en, this message translates to:
  /// **'SKU (code)'**
  String get adminProductSkuLabel;

  /// No description provided for @adminProductTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Product type'**
  String get adminProductTypeLabel;

  /// No description provided for @adminProductTypeSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple'**
  String get adminProductTypeSimple;

  /// No description provided for @adminProductTypeVariable.
  ///
  /// In en, this message translates to:
  /// **'Variable (sizes / colors)'**
  String get adminProductTypeVariable;

  /// No description provided for @adminProductTypeGrouped.
  ///
  /// In en, this message translates to:
  /// **'Grouped (bundle)'**
  String get adminProductTypeGrouped;

  /// No description provided for @adminProductTypeExternal.
  ///
  /// In en, this message translates to:
  /// **'External / affiliate'**
  String get adminProductTypeExternal;

  /// No description provided for @adminProductVirtualLabel.
  ///
  /// In en, this message translates to:
  /// **'Virtual product (no shipping)'**
  String get adminProductVirtualLabel;

  /// No description provided for @adminProductDownloadableLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloadable product'**
  String get adminProductDownloadableLabel;

  /// No description provided for @adminProductDownloadUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Download URL'**
  String get adminProductDownloadUrlLabel;

  /// No description provided for @adminProductExternalUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'External URL'**
  String get adminProductExternalUrlLabel;

  /// No description provided for @adminProductButtonTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Button text'**
  String get adminProductButtonTextLabel;

  /// No description provided for @adminProductButtonTextHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: Add to cart, Buy now'**
  String get adminProductButtonTextHint;

  /// No description provided for @adminProductSaleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sale / discount'**
  String get adminProductSaleSectionTitle;

  /// No description provided for @adminProductSalePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get adminProductSalePriceLabel;

  /// No description provided for @adminProductSaleStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale start (ISO date)'**
  String get adminProductSaleStartLabel;

  /// No description provided for @adminProductSaleEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Sale end (ISO date)'**
  String get adminProductSaleEndLabel;

  /// No description provided for @adminProductAttributesTitle.
  ///
  /// In en, this message translates to:
  /// **'Attributes'**
  String get adminProductAttributesTitle;

  /// No description provided for @adminProductAttributeCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute code'**
  String get adminProductAttributeCodeLabel;

  /// No description provided for @adminProductAttributeValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Attribute value'**
  String get adminProductAttributeValueLabel;

  /// No description provided for @adminProductAddAttribute.
  ///
  /// In en, this message translates to:
  /// **'Add attribute'**
  String get adminProductAddAttribute;

  /// No description provided for @adminProductSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save product'**
  String get adminProductSaveButton;
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
