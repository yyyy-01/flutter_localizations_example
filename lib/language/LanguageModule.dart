import 'GlobalTranslations.dart';

class LanguageModule {
  static String checkTranslation(String key, String content) {
    String aa = allTranslations.text(key, content);

    if (aa.startsWith("**")) {
      aa = content;
    }

    return aa;
  }

  static void changeLanguage(String language, bool save, Function setState) {
    allTranslations.setNewLanguage2(language, true, setState);
  }

  static String getLanguage(String text1, String text2) {
    return allTranslations.text(text1, text2);
  }

  static String getCurrentLanguage() {
    return allTranslations.currentLanguage;
  }
}
