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

  @override
  String get adminShippingTitle => 'Shipping Methods';

  @override
  String get adminShippingAdd => 'Add method';

  @override
  String get adminShippingNoMethods => 'No shipping methods yet';

  @override
  String get adminShippingCreateTitle => 'Create shipping method';

  @override
  String get adminShippingEditTitle => 'Edit shipping method';

  @override
  String get adminShippingNameLabel => 'Name';

  @override
  String get adminShippingNameRequired => 'Name is required';

  @override
  String get adminShippingDescLabel => 'Description';

  @override
  String get adminShippingTypeLabel => 'Method type';

  @override
  String get adminShippingTypeHint => 'Select type';

  @override
  String get adminShippingFlatRateLabel => 'Flat rate';

  @override
  String get adminShippingPerKgLabel => 'Price per kg';

  @override
  String get adminShippingThresholdLabel => 'Free shipping threshold';

  @override
  String get adminShippingCountryLabel => 'Country';

  @override
  String get adminShippingCountryHint => 'Select country';

  @override
  String get adminShippingCountryRequired => 'Country is required';

  @override
  String get adminShippingRegionLabel => 'Region';

  @override
  String get adminShippingRegionHint => 'Select region (optional)';

  @override
  String get adminShippingSelectCountryFirst => 'Select country first';

  @override
  String get adminShippingEnabledLabel => 'Enabled';

  @override
  String get adminShippingEnabledShort => 'Enabled';

  @override
  String get adminShippingTypeShort => 'Type';

  @override
  String get shippingTypeFlatRate => 'Flat rate';

  @override
  String get shippingTypeFree => 'Free';

  @override
  String get shippingTypeWeightBased => 'Weight based';

  @override
  String get shippingTypePriceBased => 'Price based';

  @override
  String get shippingTypePricePerKg => 'Price per kg';

  @override
  String get shippingTypeLocalPickup => 'Local pickup';

  @override
  String get shippingTypeFreeOverThreshold => 'Free over threshold';

  @override
  String get adminConfirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get adminShippingCreateButton => 'Create method';

  @override
  String get adminDeleted => 'Deleted';

  @override
  String get refreshLabel => 'Refresh';

  @override
  String get adminEnabledOnly => 'Enabled only';

  @override
  String get adminShowAll => 'Show all';

  @override
  String get adminDisabled => 'Disabled only';

  @override
  String get adminActive => 'Active only';

  @override
  String get adminCreated => 'Created';

  @override
  String get adminUpdated => 'Updated';

  @override
  String get adminHomeBannersTitle => 'Home Banners';

  @override
  String get adminHomeBannerAdd => 'Add banner';

  @override
  String get adminHomeBannerNoBanners => 'No banners yet';

  @override
  String get adminHomeBannerCreateTitle => 'Create home banner';

  @override
  String get adminHomeBannerEditTitle => 'Edit home banner';

  @override
  String get adminHomeBannerTitleLabel => 'Title';

  @override
  String get adminHomeBannerSubtitleLabel => 'Subtitle';

  @override
  String get adminHomeBannerTargetTypeLabel => 'Target type';

  @override
  String get adminHomeBannerTargetIdLabel => 'Target ID';

  @override
  String get adminHomeBannerTargetUrlLabel => 'Target URL';

  @override
  String get adminHomeBannerSortOrderLabel => 'Sort order';

  @override
  String get adminHomeBannerActiveLabel => 'Active';

  @override
  String get adminImageLabel => 'Banner image';

  @override
  String get adminChooseFromGallery => 'Choose from gallery';

  @override
  String get adminTakePhoto => 'Take photo';

  @override
  String get adminRemoveImage => 'Remove';

  @override
  String get adminImageRequired => 'Image is required';

  @override
  String get adminTargetShort => 'Target';

  @override
  String get adminSortShort => 'Sort';

  @override
  String get adminUntitled => 'Untitled';

  @override
  String get adminHomeBannerEdit => 'Edit banner';

  @override
  String get adminHomeBannerCreate => 'Create banner';

  @override
  String get adminHomeBannerImageLabel => 'Banner image';

  @override
  String get adminHomeBannerImageRequired => 'Image is required';

  @override
  String get adminPickFromGallery => 'Gallery';

  @override
  String get adminPickFromCamera => 'Camera';

  @override
  String get adminHomeBannerSortLabel => 'Sort order';

  @override
  String get adminHomeBannerLoadingTargets => 'Loading targets...';

  @override
  String get adminHomeBannerTargetTypeHint => 'Select target type';

  @override
  String get adminHomeBannerTargetNone => 'None';

  @override
  String get adminHomeBannerTargetCategory => 'Category';

  @override
  String get adminHomeBannerTargetProduct => 'Product';

  @override
  String get adminHomeBannerTargetUrl => 'External URL';

  @override
  String get adminHomeBannerUrlRequired => 'URL is required';

  @override
  String get adminHomeBannerTargetCategoryLabel => 'Category';

  @override
  String get adminHomeBannerTargetCategoryHint => 'Select category';

  @override
  String get adminHomeBannerCategoryRequired => 'Category is required';

  @override
  String get adminHomeBannerTargetProductLabel => 'Product';

  @override
  String get adminHomeBannerTargetProductHint => 'Select product';

  @override
  String get adminHomeBannerProductRequired => 'Product is required';

  @override
  String get adminActiveLabel => 'Active';

  @override
  String get adminNoOptions => 'No options';

  @override
  String get noResultsLabel => 'No results';

  @override
  String get searchLabel => 'Search...';

  @override
  String get adminProductsSearchHint => 'Search products...';

  @override
  String get adminProductsFilterAll => 'All products';

  @override
  String get adminProductEditSubtitle => 'Update product details';

  @override
  String get adminProductCreateSubtitle => 'Add a new product';

  @override
  String get adminProductSectionBasicInfoTitle => 'Basic info';

  @override
  String get adminProductSectionPricingTitle => 'Pricing';

  @override
  String get adminProductSectionBasicInfoSubtitle => 'Name, description, type, SKU';

  @override
  String get adminProductSectionPricingSubtitle => 'Price, sale, stock';

  @override
  String get adminProductSectionMetaTitle => 'Meta';

  @override
  String get adminProductSectionMetaSubtitle => 'SEO title & description';

  @override
  String get adminSelectCategoryFirst => 'Select category first';

  @override
  String get adminProductImageSectionTitle => 'Product image';

  @override
  String get adminProductImageSectionSubtitle => 'Upload product image';

  @override
  String get adminProductSectionConfigTitle => 'Product configuration';

  @override
  String get adminProductSectionConfigSubtitle => 'Virtual, downloadable, external';

  @override
  String get adminProductSaleSectionSubtitle => 'Set sale price and duration';

  @override
  String get adminProductAttributesSubtitle => 'Add custom attributes';

  @override
  String get cart_title => 'Shopping Cart';

  @override
  String get cart_empty_message => 'Your cart is empty. Start adding items!';

  @override
  String get cart_total_label => 'Total:';

  @override
  String get cart_checkout_button => 'Proceed to Checkout';

  @override
  String get cart_item_added => 'Item added to cart';

  @override
  String get cart_item_removed => 'Item removed from cart';

  @override
  String get cart_clear_confirmation => 'Are you sure you want to clear the cart?';

  @override
  String get cart_item_quantity_label => 'Quantity:';

  @override
  String get cart_item_updated => 'Cart item updated';

  @override
  String get cart_checkout => 'Checkout';

  @override
  String get cart_clear => 'Clear Cart';

  @override
  String get cart_empty_cta => 'Browse Products';

  @override
  String get cart_cleared => 'Cart has been cleared';

  @override
  String get adminProductNoAttributesHint => 'No attributes added yet.';

  @override
  String get cart_add_button => 'Add to Cart';

  @override
  String get home_book_now_button => 'Book Now';

  @override
  String get home_view_details_button => 'View Details';

  @override
  String get cart_login_required_title => 'Login Required';

  @override
  String get cart_login_required_message => 'Please log in to proceed to checkout.';

  @override
  String get cancel_button => 'Cancel';

  @override
  String get login_button => 'Log In';

  @override
  String get cart_item_added_snackbar => 'Item added to cart';

  @override
  String get coupons_title => 'Coupons';

  @override
  String get coupons_saved => 'Coupon saved successfully';

  @override
  String get coupons_deleted => 'Coupon deleted successfully';

  @override
  String get coupons_empty => 'No coupons yet. Create your first one!';

  @override
  String get coupons_type_percent => 'Percentage';

  @override
  String get coupons_type_fixed => 'Fixed amount';

  @override
  String get coupons_type_free_shipping => 'Free shipping';

  @override
  String get coupons_inactive_badge => 'Inactive';

  @override
  String get coupons_delete_title => 'Delete coupon';

  @override
  String coupons_delete_confirm(Object code) {
    return 'Are you sure you want to delete coupon $code?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get coupons_add => 'Add coupon';

  @override
  String get coupons_edit => 'Edit coupon';

  @override
  String get coupons_code => 'Code';

  @override
  String get coupons_code_required => 'Coupon code is required';

  @override
  String get coupons_description => 'Description';

  @override
  String get coupons_type => 'Discount type';

  @override
  String get coupons_value_percent => 'Discount (%)';

  @override
  String get coupons_value_amount => 'Discount amount';

  @override
  String get coupons_value_required => 'Discount value is required';

  @override
  String get coupons_value_invalid => 'Enter a valid discount value';

  @override
  String get coupons_max_uses => 'Max uses';

  @override
  String get coupons_min_order_amount => 'Min order amount';

  @override
  String get coupons_max_discount_amount => 'Max discount amount';

  @override
  String get coupons_active => 'Active';

  @override
  String get common_save => 'Save';

  @override
  String get adminCouponsTitle => 'Coupons';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutLoading => 'Loading checkout…';

  @override
  String get checkoutEmptyCart => 'Your cart is empty.';

  @override
  String get checkoutGoBack => 'Go back';

  @override
  String get checkoutItemsTitle => 'Items';

  @override
  String get checkoutAddressTitle => 'Shipping Address';

  @override
  String get checkoutCountryIdLabel => 'Country ID';

  @override
  String get checkoutCountryIdHint => 'Optional';

  @override
  String get checkoutRegionIdLabel => 'Region ID';

  @override
  String get checkoutRegionIdHint => 'Optional';

  @override
  String get checkoutCityLabel => 'City';

  @override
  String get checkoutCityHint => 'Enter city';

  @override
  String get checkoutPostalCodeLabel => 'Postal Code';

  @override
  String get checkoutPostalCodeHint => 'Optional';

  @override
  String get checkoutApplyAddress => 'Update shipping';

  @override
  String get checkoutCouponTitle => 'Coupon';

  @override
  String get checkoutCouponLabel => 'Coupon Code';

  @override
  String get checkoutCouponHint => 'Enter coupon (optional)';

  @override
  String get checkoutShippingTitle => 'Shipping';

  @override
  String get checkoutNoShippingMethods => 'No shipping methods found. Update address then refresh.';

  @override
  String get checkoutRefreshShipping => 'Refresh shipping';

  @override
  String get checkoutSelectShipping => 'Please select a shipping method';

  @override
  String get checkoutPaymentTitle => 'Payment';

  @override
  String get checkoutPaymentCash => 'Cash on delivery';

  @override
  String get checkoutStripeNote => 'Stripe requires payment confirmation (coming next).';

  @override
  String get checkoutSelectPayment => 'Please select a payment method';

  @override
  String get checkoutSummaryTitle => 'Order Summary';

  @override
  String get checkoutSubtotal => 'Subtotal';

  @override
  String get checkoutShipping => 'Shipping';

  @override
  String get checkoutTax => 'Tax';

  @override
  String get checkoutTotal => 'Total';

  @override
  String get checkoutPlaceOrder => 'Place Order';

  @override
  String get orderSummaryTitle => 'Order summary';

  @override
  String get secureCheckout => 'Secure checkout';

  @override
  String get itemsSubtotalLabel => 'Items subtotal';

  @override
  String get shippingLabel => 'Shipping';

  @override
  String get taxLabel => 'Tax';

  @override
  String get discountLabel => 'Discount';

  @override
  String get totalLabel => 'Total';

  @override
  String get taxesShippingNote => 'Taxes and shipping are calculated based on your address.';

  @override
  String get searchHint => 'Search...';

  @override
  String get noOptions => 'No options';

  @override
  String get noResults => 'No results';

  @override
  String get missingUserToken => 'Missing user token';

  @override
  String itemNumber(int id) {
    return 'Item #$id';
  }

  @override
  String qtyPriceLine(int qty, String price) {
    return 'x$qty • $price';
  }

  @override
  String checkoutOrderPlacedToast(int orderId) {
    return 'Order placed ✅ (# $orderId)';
  }

  @override
  String orderTitle(int orderId) {
    return 'Order #$orderId';
  }

  @override
  String orderDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get orderItemsTitle => 'Items';

  @override
  String orderQtyUnitLine(int qty, String unit) {
    return 'Qty: $qty • Unit: $unit';
  }

  @override
  String get grandTotalLabel => 'Grand Total';

  @override
  String get downloadInvoicePdf => 'Download Invoice PDF';

  @override
  String get checkoutErrorCartEmpty => 'Cart is empty';

  @override
  String get checkoutErrorSelectPayment => 'Select a payment method';

  @override
  String get checkoutErrorSelectCountry => 'Select a country';

  @override
  String get checkoutErrorSelectRegion => 'Select a region';

  @override
  String get checkoutErrorEnterCity => 'Enter city';

  @override
  String get checkoutErrorEnterPostalCode => 'Enter postal code';

  @override
  String get checkoutErrorSelectShipping => 'Select a shipping method';

  @override
  String get checkoutErrorShippingMissing => 'Shipping method is missing';

  @override
  String get checkoutErrorStripeNotReady => 'Stripe not wired yet';

  @override
  String get commonDash => '-';

  @override
  String orderDetailsTitle(Object orderId) {
    return 'Order #$orderId';
  }

  @override
  String orderDetailsDateLine(Object date) {
    return 'Date: $date';
  }

  @override
  String get orderDetailsItemsTitle => 'Items';

  @override
  String orderDetailsItemFallback(Object itemId) {
    return 'Item #$itemId';
  }

  @override
  String orderDetailsQtyUnitLine(Object qty, Object unitPrice) {
    return 'Qty: $qty  •  Unit: $unitPrice';
  }

  @override
  String get orderDetailsSubtotal => 'Subtotal';

  @override
  String get orderDetailsShipping => 'Shipping';

  @override
  String get orderDetailsTax => 'Tax';

  @override
  String orderDetailsCouponLine(Object code) {
    return 'Coupon ($code)';
  }

  @override
  String get orderDetailsGrandTotal => 'Grand Total';

  @override
  String get orderDetailsDownloadInvoice => 'Download Invoice PDF';

  @override
  String common_stock_label(Object stock) {
    return 'Stock: $stock';
  }

  @override
  String get ordersTitle => 'My Orders';

  @override
  String get ordersLoading => 'Loading orders…';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyBody => 'When you place an order, it will show up here.';

  @override
  String get ordersReload => 'Reload';

  @override
  String get ordersFilterAll => 'All';

  @override
  String get ordersFilterPending => 'Pending';

  @override
  String get ordersFilterCompleted => 'Completed';

  @override
  String get ordersFilterCanceled => 'Canceled';

  @override
  String get ordersNoResultsForFilter => 'No orders match this filter.';

  @override
  String get ordersQtyLabel => 'Qty';

  @override
  String get ordersPaid => 'Paid';

  @override
  String get ordersUnpaid => 'Unpaid';

  @override
  String get ordersStatusPending => 'Pending';

  @override
  String get ordersStatusCompleted => 'Completed';

  @override
  String get ordersStatusCanceled => 'Canceled';

  @override
  String get ordersStatusUnknown => 'Unknown';

  @override
  String get ordersUnknownItem => 'Item';

  @override
  String get ordersQty => 'Qty';

  @override
  String get profileLoginRequired => 'Please log in to view your profile.';

  @override
  String get sessionExpired => 'Session expired. Please log in again.';

  @override
  String get login => 'Login';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get profileLoadFailed => 'Failed to load profile.';

  @override
  String get username => 'Username';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get publicProfile => 'Public profile';

  @override
  String get save => 'Save';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get password => 'Password';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty_title => 'No notifications yet';

  @override
  String get notifications_empty_subtitle => 'When something happens, it’ll show up here. For now… peace and quiet 😌';

  @override
  String get notifications_retry => 'Retry';

  @override
  String get privacy_policy_title => 'Privacy Policy';

  @override
  String get privacy_policy_intro_title => 'Your privacy matters';

  @override
  String get privacy_policy_intro_body => 'This policy explains what we collect, why we collect it, and how you control your data.';

  @override
  String get privacy_policy_collect_title => 'What we collect';

  @override
  String get privacy_policy_collect_body => 'Basic profile info (name, email/phone), account settings, and app usage needed to provide the service.';

  @override
  String get privacy_policy_use_title => 'How we use your data';

  @override
  String get privacy_policy_use_body => 'To run the app, personalize your experience, improve features, and keep the platform secure.';

  @override
  String get privacy_policy_share_title => 'Sharing';

  @override
  String get privacy_policy_share_body => 'We don’t sell your data. We only share what’s needed with trusted services (like hosting) to operate the app.';

  @override
  String get privacy_policy_security_title => 'Security';

  @override
  String get privacy_policy_security_body => 'We use standard security practices, but no system is 100% perfect. Keep your password private.';

  @override
  String get privacy_policy_choices_title => 'Your choices';

  @override
  String get privacy_policy_choices_body => 'You can change visibility (public/private), update profile info, or request account actions based on the app features.';

  @override
  String get privacy_policy_contact_title => 'Contact';

  @override
  String get privacy_policy_contact_body => 'If you have questions about privacy, contact the app support team.';

  @override
  String get privacy_policy_last_updated => 'Last updated: Dec 19, 2025';

  @override
  String get home_bottom_slide_thankyou_title => 'THANK YOU';

  @override
  String get home_bottom_slide_thankyou_message => 'We appreciate your trust. Our team works daily to keep quality high and service fast.';

  @override
  String get home_bottom_slide_secure_title => 'SECURE & SAFE';

  @override
  String get home_bottom_slide_secure_message => 'Secure payments, controlled products, and clean packaging — the basics done right.';

  @override
  String get home_bottom_slide_support_title => 'REAL SUPPORT';

  @override
  String get home_bottom_slide_support_message => 'Need help? We reply. No “seen” and disappear vibes 😅';

  @override
  String get home_bottom_benefit_contact => 'CONTACT AN\nACCREDITED EXPERT';

  @override
  String get home_bottom_benefit_secure_payments => 'SECURED\nPAYMENTS';

  @override
  String get home_bottom_benefit_authentic_products => 'AUTHENTIC &\nCONTROLLED PRODUCTS';

  @override
  String home_bottom_benefit_free_delivery_above(String amount) {
    return 'FREE DELIVERY\nABOVE $amount';
  }

  @override
  String get home_trailing_limited_time => 'Limited time';

  @override
  String get home_trailing_see_all => 'See all';

  @override
  String get home_sale_tag => 'SALE';

  @override
  String home_stock_label(int count) {
    return 'Stock: $count';
  }

  @override
  String get home_bookings_placeholder => 'Bookings feed not wired yet.';

  @override
  String get home_footer_contact_title => 'Contact us';

  @override
  String get home_footer_contact_desc => 'Need help? We’re one message away.';

  @override
  String get home_footer_free_delivery_title => 'Free delivery';

  @override
  String get home_footer_free_delivery_desc => 'Available on selected orders and areas.';

  @override
  String get home_footer_returns_title => 'Easy returns';

  @override
  String get home_footer_returns_desc => 'Simple return policy on eligible items.';

  @override
  String get ownerPaymentSettingsTitle => 'Payment Methods';

  @override
  String get ownerPaymentSettingsDesc => 'Enable and configure gateways for this project';

  @override
  String get ownerPaymentConfigure => 'Configure';

  @override
  String get ownerPaymentIncomplete => 'Incomplete';

  @override
  String get ownerPaymentConfigHint => 'Configure fields below. Required fields must be filled.';

  @override
  String get paymentMethodsTitle => 'Payment Methods';

  @override
  String get paymentSearchHint => 'Search…';

  @override
  String get paymentNoResults => 'No results';

  @override
  String get paymentConfigure => 'Configure';

  @override
  String get paymentCancel => 'Cancel';

  @override
  String get paymentSave => 'Save';

  @override
  String get paymentFillFields => 'Fill the fields below, then Save.';

  @override
  String get paymentSavedKeepHint => 'Saved (leave empty to keep)';

  @override
  String get paymentRequiredLabel => '• required';

  @override
  String get paymentIncomplete => 'Incomplete';

  @override
  String get adminPaymentConfigTitle => 'Payment Methods';

  @override
  String get checkoutConfirmDialogTitle => 'Confirm checkout';

  @override
  String checkoutConfirmCartCleared(int itemCount) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: 'After checkout, your cart will become empty ($itemCount items).',
      one: 'After checkout, your cart will become empty (1 item).',
      zero: 'After checkout, your cart will become empty.',
    );
    return '$_temp0 Do you want to continue?';
  }

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';
}
