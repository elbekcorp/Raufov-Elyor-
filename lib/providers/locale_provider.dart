import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('uz');
  Locale get locale => _locale;

  final Map<String, Map<String, String>> _localizedValues = {
    'uz': {
      'app_title': 'Bilimingni Test Qil',
      'sections': 'Bo\'limlar',
      'add_section': 'Bo\'lim qo\'shish',
      'add_test': 'Test qo\'shish',
      'edit_test': 'Testni tahrirlash',
      'save': 'Saqlash',
      'cancel': 'Bekor qilish',
      'delete': 'O\'chirish',
      'questions': 'savollar',
      'test_name': 'Test nomi',
      'add_question': 'Savol qo\'shish',
      'import_txt': 'Fayldan import',
      'theme': 'Mavzu',
      'language': 'Til',
      'light': 'Yorug\'',
      'dark': 'To\'q',
      'deep': 'Tungi',
    },
    'ru': {
      'app_title': 'Тестируй знания',
      'sections': 'Разделы',
      'add_section': 'Добавить раздел',
      'add_test': 'Добавить тест',
      'edit_test': 'Редактировать тест',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'questions': 'вопросы',
      'test_name': 'Название теста',
      'add_question': 'Добавить вопрос',
      'import_txt': 'Импорт из файла',
      'theme': 'Тема',
      'language': 'Язык',
      'light': 'Светлая',
      'dark': 'Темная',
      'deep': 'Ночная',
    },
    'en': {
      'app_title': 'Test Your Knowledge',
      'sections': 'Sections',
      'add_section': 'Add Section',
      'add_test': 'Add Test',
      'edit_test': 'Edit Test',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'questions': 'questions',
      'test_name': 'Test title',
      'add_question': 'Add Question',
      'import_txt': 'Import from file',
      'theme': 'Theme',
      'language': 'Language',
      'light': 'Light',
      'dark': 'Dark',
      'deep': 'Midnight',
    },
  };

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  String getText(String key) {
    return _localizedValues[_locale.languageCode]?[key] ?? key;
  }
}
