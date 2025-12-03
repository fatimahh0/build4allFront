// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'App';

  @override
  String get loginTitle => 'Log in';

  @override
  String get loginSubtitle => 'Welcome back! Please sign in to continue.';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get loginButton => 'Log in';

  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get invalidPhone => 'Please enter a valid phone number.';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters long.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get noAccountText => 'Don\'t have an account?';

  @override
  String get signUpText => 'Sign up';

  @override
  String get loginWithEmail => 'Email';

  @override
  String get loginWithPhone => 'Phone';

  @override
  String get loginMissingIdentifier => 'Please enter your email or phone number.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Choose how you want to sign up.';

  @override
  String get registerStep1Of3 => 'Step 1 of 3';

  @override
  String get registerWithEmail => 'Sign up with email';

  @override
  String get registerWithPhone => 'Sign up with phone';

  @override
  String get registerContinueButton => 'Continue';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get alreadyHaveAccountText => 'Already have an account?';

  @override
  String get verifyCodeTitle => 'Enter verification code';

  @override
  String get verifyCodeSubtitleEmail => 'We sent a code to your email.';

  @override
  String get verifyCodeSubtitlePhone => 'We sent a code to your phone.';

  @override
  String get verificationCodeLabel => 'Verification code';

  @override
  String get invalidVerificationCode => 'Please enter a valid verification code.';

  @override
  String get verifyButtonLabel => 'Verify';

  @override
  String get completeProfileTitle => 'Complete your profile';

  @override
  String get completeProfileSubtitle => 'Pick a username and your real name.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get firstNameLabel => 'First name';

  @override
  String get lastNameLabel => 'Last name';

  @override
  String get usernameTooShort => 'Username must be at least 3 characters.';

  @override
  String get publicProfileLabel => 'Public profile';

  @override
  String get publicProfileDescription => 'If enabled, your profile and activities can be found by other users.';

  @override
  String get saveProfileButton => 'Save profile';

  @override
  String get profileCompletedSuccessMessage => 'Profile completed successfully. You can now log in.';

  @override
  String get profileCompletedErrorMessage => 'Failed to complete profile. Please try again.';

  @override
  String get featureComingSoon => 'This feature is coming soon.';

  @override
  String get changePhotoHint => 'Tap to add a profile photo';

  @override
  String get previousStepButton => 'Previous Step';

  @override
  String get completeProfileNamesTitle => 'Complete Your Profile - Names';

  @override
  String get completeProfileNamesSubtitle => 'Please provide your first and last name.';

  @override
  String get firstNameHint => 'Enter your first name';

  @override
  String get lastNameHint => 'Enter your last name';

  @override
  String get continueButton => 'Continue';

  @override
  String get completeProfileUsernameTitle => 'Complete Your Profile - Username';

  @override
  String get completeProfileUsernameSubtitle => 'Choose a unique username for your account.';

  @override
  String get completeProfilePhotoTitle => 'Complete Your Profile - Photo';

  @override
  String get completeProfilePhotoSubtitle => 'Add a profile picture to personalize your account.';

  @override
  String get nextStepButton => 'Next Step';

  @override
  String get home_welcome => 'Welcome 👋';

  @override
  String get home_search_hint => 'Search activities, items...';

  @override
  String get home_banner_title => 'Discover your next hobby';

  @override
  String get home_banner_subtitle => 'Explore activities, classes and more near you.';

  @override
  String get home_banner_button => 'Start exploring';

  @override
  String get home_items_default_title => 'Items';

  @override
  String get home_recommended_title => 'Recommended for you';

  @override
  String get home_popular_title => 'Popular now';

  @override
  String get home_bookings_title => 'Upcoming bookings';

  @override
  String get home_reviews_title => 'Latest reviews';

  @override
  String get connection_offline => 'No internet connection';

  @override
  String get connection_server_down => 'Server is not responding';

  @override
  String get connection_issue => 'Connection issue';

  @override
  String get explore_title => 'Explore';

  @override
  String get explore_search_hint => 'Search  places...';

  @override
  String get explore_items_title => 'All activities';

  @override
  String get explore_empty_message => 'No results found. Try another keyword.';

  @override
  String get explore_category_all => 'All';

  @override
  String explore_results_label(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
  }

  @override
  String get explore_sort_relevance => 'Relevance';

  @override
  String get explore_sort_price_low_high => 'Price: Low to High';

  @override
  String get explore_sort_price_high_low => 'Price: High to Low';

  @override
  String get explore_sort_date_soonest => 'Soonest date';

  @override
  String get profileMotto => 'Live your hobby!';

  @override
  String get profile_load_error => 'Couldn\'t load your profile. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get manageAccount => 'Manage account';

  @override
  String get profileMakePrivate => 'Make profile private';

  @override
  String get profileMakePublic => 'Make profile public';

  @override
  String get setInactive => 'Set account inactive';

  @override
  String get profileLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get deactivate_title => 'Deactivate account';

  @override
  String get deactivate_warning => 'Enter your password to confirm deactivation.';

  @override
  String get current_password_label => 'Current password';

  @override
  String get language_note => 'Changing language will restart some screens.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get logout => 'Log out';

  @override
  String get adminDashboardTitle => 'Admin dashboard';

  @override
  String get adminDashboardSubtitle => 'Manage your app content and settings.';

  @override
  String get adminProductsTitle => 'Products';

  @override
  String get adminProductsEmpty => 'No products yet. Tap + to add your first product.';

  @override
  String get adminProductsNewArrivals => 'New arrivals';

  @override
  String get adminProductsBestSellers => 'Best sellers';

  @override
  String get adminProductsDiscounted => 'Discounted products';

  @override
  String get adminProductsSearchPlaceholder => 'Search products...';

  @override
  String get productBadgeOnSale => 'On sale';

  @override
  String get productStatusDraft => 'Draft';

  @override
  String get productStatusActive => 'Active';

  @override
  String get productStatusArchived => 'Archived';

  @override
  String get errorNetworkNoInternet => 'No internet or server unreachable.';

  @override
  String get errorNetworkServerDown => 'The server is not responding. Please try again later.';

  @override
  String get errorServerUnexpected => 'Unexpected server error. Please try again.';

  @override
  String get errorUnexpected => 'Unexpected error. Please try again.';

  @override
  String get errorAuthUnauthorized => 'Your session has expired. Please log in again.';

  @override
  String get errorAuthForbidden => 'You don\'t have permission to perform this action.';

  @override
  String get logoutLabel => 'Logout';

  @override
  String get adminDashboardQuickActions => 'Quick actions';

  @override
  String get adminOverviewAnalytics => 'Overview & analytics';

  @override
  String get adminProjectsOwners => 'Projects & owners';

  @override
  String get adminUsersManagers => 'Users & managers';

  @override
  String get adminSettings => 'Settings';

  @override
  String adminSignedInAs(Object role) {
    return 'Signed in as $role';
  }

  @override
  String get adminProductCreateTitle => 'Create product';

  @override
  String get adminProductNameLabel => 'Product name';

  @override
  String get adminProductNameHint => 'Ex: Samsung laptop';

  @override
  String get adminProductNameRequired => 'Product name is required';

  @override
  String get adminProductDescriptionLabel => 'Description';

  @override
  String get adminProductDescriptionHint => 'Short description of the product';

  @override
  String get adminProductPriceLabel => 'Price';

  @override
  String get adminProductPriceRequired => 'Price is required';

  @override
  String get adminProductPriceInvalid => 'Enter a valid price greater than 0';

  @override
  String get adminProductStockLabel => 'Stock quantity';

  @override
  String get adminProductStatusLabel => 'Status';

  @override
  String get adminProductImageUrlLabel => 'Image URL';

  @override
  String get adminProductSkuLabel => 'SKU (code)';

  @override
  String get adminProductTypeLabel => 'Product type';

  @override
  String get adminProductTypeSimple => 'Simple';

  @override
  String get adminProductTypeVariable => 'Variable (sizes / colors)';

  @override
  String get adminProductTypeGrouped => 'Grouped (bundle)';

  @override
  String get adminProductTypeExternal => 'External / affiliate';

  @override
  String get adminProductVirtualLabel => 'Virtual product (no shipping)';

  @override
  String get adminProductDownloadableLabel => 'Downloadable product';

  @override
  String get adminProductDownloadUrlLabel => 'Download URL';

  @override
  String get adminProductExternalUrlLabel => 'External URL';

  @override
  String get adminProductButtonTextLabel => 'Button text';

  @override
  String get adminProductButtonTextHint => 'Ex: Add to cart, Buy now';

  @override
  String get adminProductSaleSectionTitle => 'Sale / discount';

  @override
  String get adminProductSalePriceLabel => 'Sale price';

  @override
  String get adminProductSaleStartLabel => 'Sale start (ISO date)';

  @override
  String get adminProductSaleEndLabel => 'Sale end (ISO date)';

  @override
  String get adminProductAttributesTitle => 'Attributes';

  @override
  String get adminProductAttributeCodeLabel => 'Attribute code';

  @override
  String get adminProductAttributeValueLabel => 'Attribute value';

  @override
  String get adminProductAddAttribute => 'Add attribute';

  @override
  String get adminProductSaveButton => 'Save product';
}
