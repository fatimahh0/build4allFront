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
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to continue';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get loginButton => 'Log in';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get authErrorGeneric => 'Something went wrong, please try again.';

  @override
  String get noAccountText => 'Don\'t have an account?';

  @override
  String get signUpText => 'Sign up';

  @override
  String get loginWithEmail => 'Email';

  @override
  String get loginWithPhone => 'Phone';

  @override
  String get loginMissingIdentifier => 'Please enter your email or phone';

  @override
  String get forgotPassword => 'Forgot password?';
}
