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
  String get home_search_hint => 'Search products, brands...';

  @override
  String get home_banner_title => 'Special Offers';

  @override
  String get home_banner_subtitle => 'Save up to 50% on selected items.';

  @override
  String get home_banner_button => 'Start shopping';

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
  String get home_flash_sale_title => 'Flash Sale';

  @override
  String get home_new_arrivals_title => 'New Arrivals';

  @override
  String get home_best_sellers_title => 'Best Sellers';

  @override
  String get home_top_rated_title => 'Top Rated';

  @override
  String get home_why_shop_title => 'Why Shop With Us';

  @override
  String get home_why_shop_free_shipping_title => 'Free Shipping';

  @override
  String get home_why_shop_free_shipping_subtitle => 'On all orders over \$50';

  @override
  String get home_why_shop_easy_returns_title => 'Easy Returns';

  @override
  String get home_why_shop_easy_returns_subtitle => '30-day return policy';

  @override
  String get home_why_shop_secure_payment_title => 'Secure Payment';

  @override
  String get home_why_shop_secure_payment_subtitle => '100% protected transactions';

  @override
  String get home_why_shop_support_title => '24/7 Support';

  @override
  String get home_why_shop_support_subtitle => 'Always here to help you';

  @override
  String get connection_offline => 'No internet connection';

  @override
  String get connection_server_down => 'Server is not responding';

  @override
  String get profile_login_required => 'Please log in to view your profile.';

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
  String get accountInactiveTitle => 'Your account is inactive';

  @override
  String get accountInactiveBody => 'Your account is currently inactive. Do you want to reactivate it to continue?';

  @override
  String get reactivateButton => 'Reactivate';

  @override
  String get accountReactivated => 'Your account has been reactivated successfully';

  @override
  String get chooseSignInRole => 'Choose how to sign in';

  @override
  String get enterAsOwner => 'Enter as Owner (Admin)';

  @override
  String get enterAsUser => 'Enter as User';

  @override
  String get roleLabel => 'Role';

  @override
  String get userLabel => 'User';

  @override
  String get loginInactiveTitle => 'Reactivate your account?';

  @override
  String loginInactiveMessage(Object name) {
    return 'Your account \"$name\" is currently inactive. Do you want to reactivate it and continue?';
  }

  @override
  String get loginInactiveReactivate => 'Reactivate';

  @override
  String get loginInactiveCancel => 'Not now';

  @override
  String get loginInactiveRequired => 'You must reactivate your account to sign in as user.';

  @override
  String get loginChooseRoleTitle => 'Choose how to sign in';

  @override
  String get loginEnterAsOwner => 'Enter as Owner (Admin)';

  @override
  String get loginEnterAsUser => 'Enter as User';

  @override
  String get loginRoleLabel => 'Role:';

  @override
  String get loginUserFallbackLabel => 'User';

  @override
  String get loginInactiveSuccess => 'Your account has been reactivated successfully.';

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
  String get adminProductNameLabel => 'Name';

  @override
  String get adminProductNameHint => 'Ex: MacBook Pro';

  @override
  String get adminProductNameRequired => 'Name is required';

  @override
  String get adminProductDescriptionLabel => 'Description';

  @override
  String get adminProductDescriptionHint => 'Short description...';

  @override
  String get adminProductPriceLabel => 'Price';

  @override
  String get adminProductPriceRequired => 'Price is required';

  @override
  String get adminProductPriceInvalid => 'Price must be greater than 0';

  @override
  String get adminProductStockLabel => 'Stock';

  @override
  String get adminProductStatusLabel => 'Status';

  @override
  String get adminProductImageUrlLabel => 'Image URL';

  @override
  String get adminProductSkuLabel => 'SKU';

  @override
  String get adminProductTypeLabel => 'Product type';

  @override
  String get adminProductTypeSimple => 'Simple';

  @override
  String get adminProductTypeVariable => 'Variable';

  @override
  String get adminProductTypeGrouped => 'Grouped';

  @override
  String get adminProductTypeExternal => 'External';

  @override
  String get adminProductVirtualLabel => 'Virtual product';

  @override
  String get adminProductDownloadableLabel => 'Downloadable';

  @override
  String get adminProductDownloadUrlLabel => 'Download URL';

  @override
  String get adminProductExternalUrlLabel => 'External URL';

  @override
  String get adminProductButtonTextLabel => 'Button text';

  @override
  String get adminProductButtonTextHint => 'Buy now';

  @override
  String get adminProductSaleSectionTitle => 'Sale';

  @override
  String get adminProductSalePriceLabel => 'Sale price';

  @override
  String get adminProductSaleStartLabel => 'Sale start date';

  @override
  String get adminProductSaleEndLabel => 'Sale end date';

  @override
  String get adminProductAttributesTitle => 'Attributes';

  @override
  String get adminProductAttributeCodeLabel => 'Attribute code';

  @override
  String get adminProductAttributeValueLabel => 'Value';

  @override
  String get adminProductAddAttribute => 'Add attribute';

  @override
  String get adminProductEditTitle => 'Edit product';

  @override
  String get adminProductCategoryLabel => 'Category';

  @override
  String get adminProductItemTypeLabel => 'Item type';

  @override
  String get adminStockHint => 'Ex: 50';

  @override
  String get adminProductImageLabel => 'Image';

  @override
  String get adminProductPickImage => 'Pick image';

  @override
  String get adminRemove => 'Remove';

  @override
  String get adminProductSkuHint => 'Ex: SKU-123';

  @override
  String get adminProductDownloadUrlHint => 'https://...';

  @override
  String get adminProductExternalUrlHint => 'https://...';

  @override
  String get adminProductSaveButton => 'Save product';

  @override
  String get adminNoCategories => 'No categories found';

  @override
  String get adminCreateCategory => 'Create category';

  @override
  String get adminNoItemTypes => 'No item types found';

  @override
  String get adminCreateItemType => 'Create item type';

  @override
  String get adminTaxesTitle => 'Taxes';

  @override
  String get adminTaxRulesTitle => 'Tax Rules';

  @override
  String get adminTaxAddRule => 'Add tax rule';

  @override
  String get adminTaxNoRules => 'No tax rules found.';

  @override
  String get adminTaxCreateRuleTitle => 'Create Tax Rule';

  @override
  String get adminTaxEditRuleTitle => 'Edit Tax Rule';

  @override
  String get adminTaxRuleNameLabel => 'Rule name';

  @override
  String get adminTaxRuleNameHint => 'Ex: Standard VAT 11%';

  @override
  String get adminTaxRuleNameRequired => 'Tax rule name is required';

  @override
  String get adminTaxRuleRateLabel => 'Rate (%)';

  @override
  String get adminTaxRuleRateHint => '11.00';

  @override
  String get adminTaxRuleRateRequired => 'Rate is required';

  @override
  String get adminTaxRuleRateInvalid => 'Rate must be a valid number > 0';

  @override
  String get adminTaxAppliesToShippingLabel => 'Applies to shipping';

  @override
  String get adminTaxEnabledLabel => 'Enabled';

  @override
  String get adminTaxCountryIdLabel => 'Country ID (optional)';

  @override
  String get adminTaxCountryIdHint => '1';

  @override
  String get adminTaxRegionIdLabel => 'Region ID (optional)';

  @override
  String get adminTaxRegionIdHint => '2';

  @override
  String get adminTaxRateShort => 'Rate';

  @override
  String get adminTaxAppliesToShippingShort => 'Shipping tax';

  @override
  String get adminTaxEnabledShort => 'Enabled';

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminCreate => 'Create';

  @override
  String get adminUpdate => 'Update';

  @override
  String get adminEdit => 'Edit';

  @override
  String get adminDelete => 'Delete';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get adminSessionExpired => 'Your session has expired. Please log in again.';

  @override
  String get adminTaxCountryLabel => 'Country';

  @override
  String get adminTaxCountryHint => 'Select country';

  @override
  String get adminTaxRegionLabel => 'Region';

  @override
  String get adminTaxSelectCountryFirst => 'Select country first';

  @override
  String get adminTaxRegionHint => 'Select region';

  @override
  String get adminTaxRulesTitleShort => 'Tax Rules';

  @override
  String get adminTaxRulesSubtitle => 'Manage tax rules for your products.';

  @override
  String get taxPreviewLoading => 'Calculating tax preview...';

  @override
  String get taxPreviewTitle => 'Tax Preview';

  @override
  String get itemsTaxLabel => 'Items Tax';

  @override
  String get shippingTaxLabel => 'Shipping Tax';

  @override
  String get totalTaxLabel => 'Total Tax';

  @override
  String get taxClassNone => 'No Tax';

  @override
  String get taxClassStandard => 'Standard Rate';

  @override
  String get taxClassReduced => 'Reduced Rate';

  @override
  String get taxClassZero => 'Zero Rate';

  @override
  String get taxClassLabel => 'Tax Class';

  @override
  String get taxClassHint => 'Select tax class';

  @override
  String get adminTaxCountryRequired => 'Country is required';

  @override
  String get adminTaxRegionRequired => 'Region is required';

  @override
  String get adminTaxRulePresetLabel => 'Rule Preset';

  @override
  String get adminTaxRulePresetHint => 'Select a preset to auto-fill fields';

  @override
  String get adminCustom => 'Custom';

  @override
  String get adminTaxAutoNameLabel => 'Auto-generate name';
}
