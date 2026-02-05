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
      'next': 'Keyingisi',
      'finish': 'Tugalash',
      'quiz_summary':
          'Savollar: {total}, To\'g\'ri: {score}, Xatolar: {mistakes}.',
      'practice_mistakes': 'Faqat xatolar ustida ishlashni xohlaysizmi?',
      'yes': 'Ha',
      'no': 'Yo\'q',
      'info_title': 'Ma\'lumot',
      'add_info':
          'So\'zlarni qo\'shishda har bir til uchun tegishli maydonni to\'ldiring. Agar matn bir necha qatordan iborat bo\'lib, qatorlar boshida yoki oxirida + yoki = belgilari ajratuvchi sifatida ishlatilgan bo\'lsa, ular avtomatik tozalanadi. Formulalar ichidagi (+, =) belgilar esa saqlab qolinadi.',
      'quiz_guide_title': 'Test qo\'shish',
      'quiz_guide_content':
          'Testlar avtomatik ravishda "So\'z qo\'shish" bo\'limida qo\'shilgan so\'zlardan tuziladi. Yangi so\'z qo\'shing va u ushbu testda paydo bo\'ladi.',
      'practice_mistakes_title': 'Xatolar ustida ishlash',
      'practice_mistakes_desc':
          'Sizda {count} ta xato mavjud. Ular asosida yangi test boshlashni xohlaysizmi?',
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
      'next': 'Next',
      'finish': 'Finish',
      'quiz_summary':
          'Questions: {total}, Correct: {score}, Mistakes: {mistakes}.',
      'practice_mistakes': 'Do you want to practice only the mistakes?',
      'yes': 'Yes',
      'no': 'No',
      'info_title': 'Information',
      'add_info':
          'When adding words, fill in the respective fields for each language. If the text consists of multiple lines and + or = symbols are used as separators at the beginning or end of lines, they will be automatically cleaned. Symbols within formulas (+, =) will be preserved.',
      'quiz_guide_title': 'Adding Tests',
      'quiz_guide_content':
          'Tests are automatically generated from words added in the "Add Word" section. Add a new word and it will appear in this quiz.',
      'practice_mistakes_title': 'Practice Mistakes',
      'practice_mistakes_desc':
          'You have {count} mistakes. Would you like to start a new quiz based on them?',
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
      'next': 'Следующий',
      'finish': 'Завершить',
      'quiz_summary':
          'Вопросов: {total}, Правильно: {score}, Ошибок: {mistakes}.',
      'practice_mistakes': 'Хотите потренироваться только на ошибках?',
      'yes': 'Да',
      'no': 'Нет',
      'info_title': 'Информация',
      'add_info':
          'При добавлении слов заполните соответствующие поля для каждого языка. Если текст состоит из нескольких строк и в начале или конце строк используются символы + или = в качестве разделителей, они будут автоматически очищены. Символы внутри формул (+, =) будут сохранены.',
      'quiz_guide_title': 'Добавление тестов',
      'quiz_guide_content':
          'Тесты автоматически формируются из слов, добавленных в разделе "Добавить слово". Добавьте новое слово, и оно появится в этом тесте.',
      'practice_mistakes_title': 'Работа над ошибками',
      'practice_mistakes_desc':
          'У вас {count} ошибок. Хотите начать новый тест на их основе?',
    },
  };
}
