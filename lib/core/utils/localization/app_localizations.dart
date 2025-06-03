import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcinus/core/utils/app_logger.dart';

// Generated file - Manually created for now based on app_es.arb
// Contains methods to access the localized strings.
// Replace with generated file if using intl_utils or similar later.

/// Clase responsable de cargar y proporcionar las cadenas de texto localizadas.
///
/// Se accede a través de `AppLocalizations.of(context)`. 
class AppLocalizations {
  /// Constructor que requiere el [locale] actual.
  AppLocalizations(this.locale);

  final Locale locale;
  
  /// Almacena los strings localizados cargados desde el archivo ARB.
  final Map<String, String> _localizedStrings = {};

  /// Obtiene la instancia de [AppLocalizations] más cercana en el árbol de widgets.
  ///
  /// Devuelve `null` si no se encuentra ninguna instancia.
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Delegado para registrar esta clase en [MaterialApp.localizationsDelegates].
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Carga las cadenas de texto localizadas para el [locale] actual desde
  /// el archivo ARB correspondiente.
  Future<bool> load() async {
    // Load the language JSON file from the "l10n" folder
    final jsonString = await rootBundle.loadString(
      'lib/l10n/app_${locale.languageCode}.arb',
    );
    
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

    _localizedStrings.addAll(
      Map.fromEntries(
        jsonMap.entries
          .where((entry) => !entry.key.startsWith('@@')) // Omitir metadatos
          .map((entry) => MapEntry(entry.key, entry.value.toString())),
      ),
    );
    
    // Load plural/gender messages (Manually define for now)
    // This part needs specific handling based on intl package usage.
    // For simple strings, the map above is sufficient.

    return true;
  }

  /// Traduce la [key] dada usando las cadenas cargadas.
  ///
  /// Opcionalmente, puede recibir [args] para sustituir placeholders
  /// en la cadena (por ejemplo, `translate('helloUser', args: {'name': 'Flutter'})`).
  /// Devuelve la [key] si no se encuentra la traducción.
  String translate(String key, {Map<String, Object>? args}) {
     // Return key if not found, maybe log this?
    if (!_localizedStrings.containsKey(key)) {
      AppLogger.logWarning(
        'Translation key "$key" not found for locale "${locale.languageCode}".'
      );
      return key;
    }
    final baseString = _localizedStrings[key]!;

    if (args == null || args.isEmpty) {
      return baseString;
    }

    // Basic placeholder substitution (replace {placeholder} with value)
    // More complex ICU format requires intl package's parser
    var result = baseString;
    args.forEach((placeholder, value) {
      result = result.replaceAll('{$placeholder}', value.toString());
    });
    return result;
  }

  // --- Specific Getters for common strings (add as needed) ---

  /// Título de la aplicación.
  String get appName => translate('appName');
  /// Mensaje genérico de error.
  String get errorOccurred => translate('errorOccurred');
  /// Texto para el botón de reintentar.
  String get retry => translate('retry');
  /// Texto indicador de carga.
  String get loading => translate('loading');
  /// Texto para el botón de guardar.
  String get save => translate('save');
  /// Texto para el botón de cancelar.
  String get cancel => translate('cancel');
  /// Mensaje de error para campos obligatorios.
  String get requiredField => translate('requiredField');
  /// Mensaje de error para email inválido.
  String get invalidEmail => translate('invalidEmail');
  /// Mensaje de error para contraseña corta.
  String passwordTooShort(int minLength) => 
      translate('passwordTooShort', args: {'minLength': minLength});
  /// Mensaje de error cuando las contraseñas no coinciden.
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  /// Texto para el botón de iniciar sesión.
  String get login => translate('login');
  /// Texto para el botón de registrarse.
  String get register => translate('register');
  /// Etiqueta para el campo de email.
  String get email => translate('email');
  /// Etiqueta para el campo de contraseña.
  String get password => translate('password');
  /// Etiqueta para el campo de confirmar contraseña.
  String get confirmPassword => translate('confirmPassword');
  /// Texto para la opción de cerrar sesión.
  String get logout => translate('logout');
  /// Texto para la opción de ajustes.
  String get settings => translate('settings');
  /// Texto para la opción de perfil.
  String get profile => translate('profile');
  /// Texto para la opción de inicio.
  String get home => translate('home');
  /// Texto para la opción de búsqueda.
  String get search => translate('search');
  /// Texto para el botón de OK.
  String get ok => translate('ok');
  /// Texto para la opción 'Sí'.
  String get yes => translate('yes');
  /// Texto para la opción 'No'.
  String get no => translate('no');
  /// Texto para la opción de eliminar.
  String get delete => translate('delete');
  /// Texto para la opción de editar.
  String get edit => translate('edit');
  /// Texto para la opción de añadir.
  String get add => translate('add');
  /// Texto para la opción de cerrar.
  String get close => translate('close');

}

/// Delegado interno para [AppLocalizations].
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {

  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all supported language codes here
    return ['es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  // ignore: unnecessary_overrides
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 
