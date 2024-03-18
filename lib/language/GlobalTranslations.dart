import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Preferences related
///
const String _storageKey = "MyApplication_";
const List<String> _supportedLanguages = ['en','zh','ms'];
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class GlobalTranslations {
  Locale? _locale;
  Map<dynamic, dynamic>? _localizedValues;
  VoidCallback? _onLocaleChangedCallback;
  ///
  /// Returns the list of supported Locales
  ///
  Iterable<Locale> supportedLocales() => _supportedLanguages.map<Locale>((lang) => new Locale(lang, ''));
  ///
  /// Returns the translation that corresponds to the [key]
  ///
  bool sharePreferExist = true;
  String text(String key,String key2) {
    // Return the requested string
    return (_localizedValues == null ||  _localizedValues?[key] == null || _localizedValues?[key][key2] == null) ? '** $key not found' : _localizedValues?[key][key2];
  }

  bool isSharePreferExist() {
    // Return the requested string
    return sharePreferExist;
  }

  ///
  /// Returns the current language code
  ///
  get currentLanguage => _locale == null ? '' : _locale?.languageCode;

  ///
  /// Returns the current Locale
  ///
  get locale => _locale;

  ///
  /// One-time initialization
  ///
  Future<Null> init([String? language]) async {
    if (_locale == null){
      await setNewLanguage(language??'en');
    }
    return null;
  }

  /// ----------------------------------------------------------
  /// Method that saves/restores the preferred language
  /// ----------------------------------------------------------
  getPreferredLanguage() async {
    return _getApplicationSavedInformation('language');
  }
  setPreferredLanguage(String lang) async {
    return _setApplicationSavedInformation('language', lang);
  }

  ///
  /// Routine to change the language
  ///
  ///
  Future<Null> setNewLanguage2([String? newLanguage, bool saveInPrefs = false,Function? setState]) async{
    await allTranslations.setNewLanguage(newLanguage??'en', true).then((value){
      setState!(() {
        allTranslations.setNewLanguage(newLanguage??'en', true);
      });
    });
    return null;
  }


  Future<bool> setNewLanguage([String? newLanguage, bool saveInPrefs = false]) async {
    String language = newLanguage??'en';
    String oldLanguage = "";
    if (language == null){
      language = await getPreferredLanguage();
    }
    if(await getPreferredLanguage()!=""){
      oldLanguage =await getPreferredLanguage();
    }else{
      oldLanguage = "en";
    }
    // Set the locale
    if (language == ""){
      language = "en";
      sharePreferExist = false;
    }
    _locale = Locale(language, "");

    //todo test
    var dir;
    if(Platform.isIOS){
      dir = await getApplicationDocumentsDirectory();
    }else{
      dir  = await getExternalStorageDirectory();
    }

    String path = dir.path;
    File file =  File('$path/language/${locale.languageCode}.json');
    String jsonContent = "";
    if(file.existsSync()){
      jsonContent = await file.readAsString();
    }else{
      jsonContent = await rootBundle.loadString("lib/language/${locale.languageCode}.json");
    }
//todo test
    // Load the language strings
    // String jsonContent = await rootBundle.loadString("lib/language/${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    // If we are asked to save the new language in the application preferences
    if (saveInPrefs){
      await setPreferredLanguage(language);
      sharePreferExist = true;
    }
    // If there is a callback to invoke to notify that a language has changed
    if (_onLocaleChangedCallback != null){
      _onLocaleChangedCallback!();
    }

    return oldLanguage!=language?true:false;
  }

  ///
  /// Callback to be invoked when the user changes the language
  ///
  set onLocaleChangedCallback(VoidCallback callback){
    _onLocaleChangedCallback = callback;
  }

  ///
  /// Application Preferences related
  ///
  /// ----------------------------------------------------------
  /// Generic routine to fetch an application preference
  /// ----------------------------------------------------------
  Future<String> _getApplicationSavedInformation(String name) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.getString(_storageKey + name) ?? '';
  }

  /// ----------------------------------------------------------
  /// Generic routine to saves an application preference
  /// ----------------------------------------------------------
  Future<bool> _setApplicationSavedInformation(String name, String value) async {
    final SharedPreferences prefs = await _prefs;

    return prefs.setString(_storageKey + name, value);
  }


  ///
  /// Singleton Factory
  ///
  static GlobalTranslations _translations = new GlobalTranslations._internal();

  factory GlobalTranslations() {
    return _translations;
  }
  GlobalTranslations._internal();
}

GlobalTranslations allTranslations = new GlobalTranslations();
