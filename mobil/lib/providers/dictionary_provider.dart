import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:easy_debounce/easy_debounce.dart';
import '../models/word.dart';

class DictionaryProvider with ChangeNotifier {
  static const String baseUrl =
      "http://10.0.2.2:8000"; // Android Emulator için backend URL
  List<Word> _words = [];
  List<Word> _userWords = [];
  List<Word> _filteredWords = [];
  List<Word> _mistakenWords = []; // Track mistakes
  bool _isLoading = true;

  List<Word> get words => _filteredWords.isEmpty && !_isLoading
      ? (_userWords + _words)
      : _filteredWords;
  List<Word> get allWordsForQuiz => _userWords + _words;
  List<Word> get mistakenWords => _mistakenWords;
  bool get isLoading => _isLoading;

  DictionaryProvider() {
    loadWords();
  }

  void addMistake(Word word) {
    if (!_mistakenWords.contains(word)) {
      _mistakenWords.add(word);
      notifyListeners();
    }
  }

  void clearMistakes() {
    _mistakenWords.clear();
    notifyListeners();
  }

  void removeMistake(Word word) {
    if (_mistakenWords.contains(word)) {
      _mistakenWords.remove(word);
      notifyListeners();
    }
  }

  Future<void> loadWords() async {
    try {
      // 1. Backenddan yuklashni harakat qilish
      try {
        final response = await http
            .get(Uri.parse("$baseUrl/words?limit=1000"))
            .timeout(const Duration(seconds: 3));
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List;
          _words = data.map((e) => Word.fromJson(e)).toList();
          debugPrint("Loaded ${(_words).length} words from backend.");
        }
      } catch (e) {
        debugPrint("Backend ulanishda xato: $e. Lokal fayldan yuklanmoqda.");
        final String localResponse = await rootBundle.loadString(
          'assets/data/words.json',
        );
        final localData = await json.decode(localResponse) as List;
        _words = localData.map((e) => Word.fromJson(e)).toList();
      }

      // 2. Lokal xotiradan (user qo'shgan so'zlar) yuklash
      final prefs = await SharedPreferences.getInstance();
      final String? userWordsJson = prefs.getString('user_words');
      if (userWordsJson != null) {
        final userWordsData = json.decode(userWordsJson) as List;
        _userWords = userWordsData.map((e) => Word.fromJson(e)).toList();
      }

      _filteredWords = _userWords + _words;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint("Kutilmagan xato: $e");
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWord(String uz, String en, String ru) async {
    final newWord = Word(uz: uz, en: en, ru: ru);

    // 1. Backendga yuborish
    try {
      await http
          .post(
            Uri.parse("$baseUrl/words"),
            headers: {"Content-Type": "application/json"},
            body: json.encode({'uz': uz, 'en': en, 'ru': ru}),
          )
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint("Backendga saqlashda xato: $e");
    }

    // 2. Lokal saqlash (Offline bo'lganda ham yo'qolmasligi uchun)
    _userWords.add(newWord);
    final prefs = await SharedPreferences.getInstance();
    final String userWordsJson = json.encode(
      _userWords.map((e) => {'uz': e.uz, 'en': e.en, 'ru': e.ru}).toList(),
    );
    await prefs.setString('user_words', userWordsJson);

    _filteredWords = _userWords + _words;
    notifyListeners();
  }

  void search(String query) async {
    if (query.isEmpty) {
      _filteredWords = _userWords + _words;
      notifyListeners();
      return;
    }

    EasyDebounce.debounce(
      'search_debounce',
      const Duration(milliseconds: 500),
      () async {
        // 1. Backenddan qidirib ko'rish
        try {
          final response = await http
              .get(Uri.parse("$baseUrl/search?q=$query"))
              .timeout(const Duration(seconds: 2));
          if (response.statusCode == 200) {
            final data = json.decode(response.body) as List;
            _filteredWords = data.map((e) => Word.fromJson(e)).toList();
            notifyListeners();
            return;
          }
        } catch (e) {
          debugPrint(
            "Backend qidiruvda xato: $e. Lokal qidiruv ishlatilmoqda.",
          );
        }

        // 2. Lokal qidiruv (Backend ishlamasa)
        final combined = _userWords + _words;
        _filteredWords = combined.where((word) {
          return word.uz.toLowerCase().contains(query.toLowerCase()) ||
              word.en.toLowerCase().contains(query.toLowerCase()) ||
              word.ru.toLowerCase().contains(query.toLowerCase());
        }).toList();
        notifyListeners();
      },
    );
  }
}
