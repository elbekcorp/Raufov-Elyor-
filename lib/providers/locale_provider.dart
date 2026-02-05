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
      'quiz_guide_title': 'Test qo\'shish yo\'riqnomasi',
      'quiz_guide_content':
          '1. Qo\'lda kiritish: "Savol qo\'shish" tugmasini bosing va ma\'lumotlarni to\'ldiring. To\'g\'ri javobni radio-tugma orqali tanlang.\n\n2. Fayldan import: Fayl .txt formatida bo\'lishi kerak. Har bir savol "?" bilan tugashi shart. To\'g\'ri javob varianti oldidan "#" belgisi qo\'yilishi kerak. Masalan:\n\nSavol matni?\n#To\'g\'ri javob\nNoto\'g\'ri javob 1\nNoto\'g\'ri javob 2',
      'next': 'Keyingisi',
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
      'quiz_guide_title': 'Инструкция по добавлению теста',
      'quiz_guide_content':
          'Чтобы добавить тест, нажмите "Добавить раздел" и создайте новый раздел. Затем войдите в раздел и добавьте вопросы через "Добавить тест". Также доступен импорт из файлов.',
      'next': 'Следующий',
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
      'quiz_guide_title': 'Guide to Adding Tests',
      'quiz_guide_content':
          'To add a test, click "Add Section" to create a new section. Then enter the section and use "Add Test" to add your questions. Import from file is also available.',
      'next': 'Next',
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
