// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'التطبيق';

  @override
  String get loginTitle => 'مرحباً بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get fieldRequired => 'هذا الحقل إلزامي';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get invalidPhone => 'يرجى إدخال رقم هاتف صالح';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get authErrorGeneric => 'حدث خطأ ما، يرجى المحاولة مرة أخرى.';

  @override
  String get noAccountText => 'ليس لديك حساب؟';

  @override
  String get signUpText => 'إنشاء حساب';

  @override
  String get loginWithEmail => 'بريد إلكتروني';

  @override
  String get loginWithPhone => 'هاتف';

  @override
  String get loginMissingIdentifier => 'يرجى إدخال البريد الإلكتروني أو رقم الهاتف';

  @override
  String get forgotPassword => 'هل نسيت كلمة المرور؟';
}
