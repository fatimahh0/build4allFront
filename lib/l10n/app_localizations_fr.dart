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
  String get loginTitle => 'Connexion';

  @override
  String get loginSubtitle => 'Ravi de vous revoir ! Connectez-vous pour continuer.';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get phoneLabel => 'Numéro de téléphone';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get fieldRequired => 'Ce champ est obligatoire.';

  @override
  String get invalidEmail => 'Veuillez saisir une adresse e-mail valide.';

  @override
  String get invalidPhone => 'Veuillez saisir un numéro de téléphone valide.';

  @override
  String get passwordTooShort => 'Le mot de passe doit contenir au moins 6 caractères.';

  @override
  String get authErrorGeneric => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get noAccountText => 'Vous n\'avez pas de compte ?';

  @override
  String get signUpText => 'S\'inscrire';

  @override
  String get loginWithEmail => 'E-mail';

  @override
  String get loginWithPhone => 'Téléphone';

  @override
  String get loginMissingIdentifier => 'Veuillez saisir votre e-mail ou votre numéro de téléphone.';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle => 'Choisissez comment vous souhaitez vous inscrire.';

  @override
  String get registerStep1Of3 => 'Étape 1 sur 3';

  @override
  String get registerWithEmail => 'S\'inscrire avec un e-mail';

  @override
  String get registerWithPhone => 'S\'inscrire avec un téléphone';

  @override
  String get registerContinueButton => 'Continuer';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get alreadyHaveAccountText => 'Vous avez déjà un compte ?';

  @override
  String get verifyCodeTitle => 'Entrez le code de vérification';

  @override
  String get verifyCodeSubtitleEmail => 'Nous avons envoyé un code à votre e-mail.';

  @override
  String get verifyCodeSubtitlePhone => 'Nous avons envoyé un code à votre téléphone.';

  @override
  String get verificationCodeLabel => 'Code de vérification';

  @override
  String get invalidVerificationCode => 'Veuillez saisir un code de vérification valide.';

  @override
  String get verifyButtonLabel => 'Vérifier';

  @override
  String get completeProfileTitle => 'Compléter votre profil';

  @override
  String get completeProfileSubtitle => 'Choisissez un pseudo et votre vrai nom.';

  @override
  String get usernameLabel => 'Nom d\'utilisateur';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get lastNameLabel => 'Nom de famille';

  @override
  String get usernameTooShort => 'Le nom d\'utilisateur doit contenir au moins 3 caractères.';

  @override
  String get publicProfileLabel => 'Profil public';

  @override
  String get publicProfileDescription => 'Si activé, votre profil et vos activités peuvent être trouvés par les autres utilisateurs.';

  @override
  String get saveProfileButton => 'Enregistrer le profil';

  @override
  String get profileCompletedSuccessMessage => 'Profil complété avec succès. Vous pouvez maintenant vous connecter.';

  @override
  String get profileCompletedErrorMessage => 'Échec de la complétion du profil. Veuillez réessayer.';

  @override
  String get featureComingSoon => 'Cette fonctionnalité arrive bientôt.';

  @override
  String get changePhotoHint => 'Appuyez pour ajouter une photo de profil';

  @override
  String get previousStepButton => 'Étape précédente';

  @override
  String get completeProfileNamesTitle => 'Complétez votre profil - Noms';

  @override
  String get completeProfileNamesSubtitle => 'Veuillez fournir votre prénom et votre nom de famille.';

  @override
  String get firstNameHint => ' Entrez votre prénom';

  @override
  String get lastNameHint => ' Entrez votre nom de famille';

  @override
  String get continueButton => 'Continuer';

  @override
  String get completeProfileUsernameTitle => 'Complétez votre profil - Nom d\'utilisateur';

  @override
  String get completeProfileUsernameSubtitle => 'Choisissez un nom d\'utilisateur unique pour votre compte.';

  @override
  String get completeProfilePhotoTitle => 'Complétez votre profil - Photo';

  @override
  String get completeProfilePhotoSubtitle => 'Ajoutez une photo de profil pour personnaliser votre compte.';

  @override
  String get nextStepButton => 'Étape suivante';

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
  String get connection_offline => 'Pas de connexion Internet';

  @override
  String get connection_server_down => 'Le serveur ne répond pas';

  @override
  String get connection_issue => 'Problème de connexion';

  @override
  String get explore_title => 'Explorer';

  @override
  String get explore_search_hint => 'Rechercher  des articles...';

  @override
  String get explore_items_title => 'Articles';

  @override
  String get explore_empty_message => 'Aucun résultat. Essayez de modifier vos filtres.';

  @override
  String get explore_category_all => 'Tout';

  @override
  String explore_results_label(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '1 résultat',
      zero: 'Aucun résultat',
    );
    return '$_temp0';
  }

  @override
  String get explore_sort_relevance => 'Pertinence';

  @override
  String get explore_sort_price_low_high => 'Prix : du plus bas au plus élevé';

  @override
  String get explore_sort_price_high_low => 'Prix : du plus élevé au plus bas';

  @override
  String get explore_sort_date_soonest => 'Date : le plus proche';

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
}
