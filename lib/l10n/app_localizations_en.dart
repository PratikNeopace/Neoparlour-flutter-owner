// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NeoParlour Partner';

  @override
  String get loginTitle => 'LOGIN';

  @override
  String get loginSubtitle =>
      'Create an account or log in to book and manage your appointments';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get or => 'OR';

  @override
  String get emailAddress => 'Email address';

  @override
  String get continueBtn => 'CONTINUE';
}
