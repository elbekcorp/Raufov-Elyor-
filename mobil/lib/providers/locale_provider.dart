
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('uz');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }

  String getText(String key) {
    return _translations[_locale.languageCode]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'uz': {
      'app_title': 'Lug\'at va Tarjimon',
      'tab_dictionary': 'Lug\'at',
      'tab_translator': 'Tarjimon',
      'tab_quiz': 'Test',
      'tab_add': 'Qo\'shish',
      'search_hint': 'Qidirish...',
      'add_word_title': 'Yangi so\'z qo\'shish',
      'uzbek': 'O\'zbekcha',
      'english': 'Inglizcha',
      'russian': 'Ruscha',
      'save': 'Saqlash',
      'quiz_title': 'Bilimingizni sinang',
      'quiz_question': 'Ushbu so\'zning tarjimasi nima?',
      'quiz_score': 'Hisob',
      'quiz_min_words': 'Test boshlash uchun kamida 4 ta so\'z bo\'lishi kerak',
      'translate_button': 'Tarjima qilish',
      'speech_hint': 'Gapirish uchun bosing',
      'from': 'Qaysi tildan',
      'to': 'Qaysi tilga',
    },
    'en': {
      'app_title': 'Dictionary & Translator',
      'tab_dictionary': 'Dictionary',
      'tab_translator': 'Translator',
      'tab_quiz': 'Quiz',
      'tab_add': 'Add',
      'search_hint': 'Search...',
      'add_word_title': 'Add New Word',
      'uzbek': 'Uzbek',
      'english': 'English',
      'russian': 'Russian',
      'save': 'Save',
      'quiz_title': 'Test Your Knowledge',
      'quiz_question': 'What is the translation of this word?',
      'quiz_score': 'Score',
      'quiz_min_words': 'At least 4 words are required to start the quiz',
      'translate_button': 'Translate',
      'speech_hint': 'Click to speak',
      'from': 'From',
      'to': 'To',
    },
    'ru': {
      'app_title': 'Словарь и Переводчик',
      'tab_dictionary': 'Словарь',
      'tab_translator': 'Переводчик',
      'tab_quiz': 'Тест',
      'tab_add': 'Добавить',
      'search_hint': 'Поиск...',
      'add_word_title': 'Добавить новое слово',
      'uzbek': 'Узбекский',
      'english': 'Английский',
      'russian': 'Русский',
      'save': 'Сохранить',
      'quiz_title': 'Проверьте свои знания',
      'quiz_question': 'Какой перевод этого слова?',
      'quiz_score': 'Счет',
      'quiz_min_words': 'Для начала теста необходимо минимум 4 слова',
      'translate_button': 'Перевести',
      'speech_hint': 'Нажмите, чтобы говорить',
      'from': 'С какого языка',
      'to': 'На какой язык',
    },
  };
}
