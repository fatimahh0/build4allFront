// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Application';

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get fieldRequired => 'Ce champ est obligatoire';

  @override
  String get invalidEmail => 'Veuillez entrer une adresse e-mail valide';

  @override
  String get invalidPhone => 'Veuillez entrer un numéro de téléphone valide';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get authErrorGeneric => 'Une erreur s\'est produite, veuillez réessayer.';

  @override
  String get noAccountText => 'Vous n\'avez pas de compte ?';

  @override
  String get signUpText => 'Inscrivez-vous';

  @override
  String get loginWithEmail => 'E-mail';

  @override
  String get loginWithPhone => 'Téléphone';

  @override
  String get loginMissingIdentifier => 'Veuillez entrer votre e-mail ou votre téléphone';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';
}
