import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/locale_provider.dart';
import '../models/word.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Word _currentWord;
  late List<String> _options;
  late String _correctAnswer;
  int _score = 0;
  int _totalQuestions = 0;
  bool _answered = false;
  String? _selectedOption;

  String _fromLang = 'uz';
  String _toLang = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    final provider = context.read<DictionaryProvider>();
    final allWords = provider.allWordsForQuiz;
    if (allWords.length < 4) return;

    final random = Random();
    _currentWord = allWords[random.nextInt(allWords.length)];

    _correctAnswer = _getWordTranslation(_currentWord, _toLang);

    List<String> options = [_correctAnswer];
    while (options.length < 4) {
      Word randomWord = allWords[random.nextInt(allWords.length)];
      String randomOption = _getWordTranslation(randomWord, _toLang);
      if (!options.contains(randomOption) && randomOption.isNotEmpty) {
        options.add(randomOption);
      }
    }
    options.shuffle();

    setState(() {
      _options = options;
      _answered = false;
      _selectedOption = null;
    });
  }

  String _getWordTranslation(Word word, String lang) {
    switch (lang) {
      case 'uz':
        return word.uz;
      case 'en':
        return word.en;
      case 'ru':
        return word.ru;
      default:
        return word.en;
    }
  }

  void _checkAnswer(String option) {
    if (_answered) return;
    setState(() {
      _answered = true;
      _selectedOption = option;
      _totalQuestions++;
      if (option == _correctAnswer) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final dictionaryProvider = context.watch<DictionaryProvider>();

    if (dictionaryProvider.allWordsForQuiz.length < 4) {
      return Scaffold(
        body: Center(child: Text(localeProvider.getText('quiz_min_words'))),
      );
    }

    if (_totalQuestions == 0 &&
        _selectedOption == null &&
        !instanceOfWordDefined()) {
      _generateQuestion();
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${localeProvider.getText('quiz_score')}: $_score/$_totalQuestions",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.indigo),
                  onPressed: () {
                    setState(() {
                      _score = 0;
                      _totalQuestions = 0;
                    });
                    _generateQuestion();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLangDropdown(_fromLang, (val) {
                          setState(() => _fromLang = val!);
                          _generateQuestion();
                        }, localeProvider),
                        const Icon(Icons.arrow_forward, color: Colors.indigo),
                        _buildLangDropdown(_toLang, (val) {
                          setState(() => _toLang = val!);
                          _generateQuestion();
                        }, localeProvider),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              localeProvider.getText('quiz_question'),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _getWordTranslation(_currentWord, _fromLang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 40),
            ..._options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _answered
                        ? (option == _correctAnswer
                              ? Colors.green
                              : (option == _selectedOption
                                    ? Colors.red
                                    : Colors.white))
                        : Colors.white,
                    foregroundColor:
                        _answered &&
                            (option == _correctAnswer ||
                                option == _selectedOption)
                        ? Colors.white
                        : Colors.black87,
                    minimumSize: const Size.fromHeight(60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    elevation: 2,
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool instanceOfWordDefined() {
    try {
      _currentWord;
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildLangDropdown(
    String value,
    Function(String?) onChanged,
    LocaleProvider lp,
  ) {
    return DropdownButton<String>(
      value: value,
      underline: Container(),
      onChanged: onChanged,
      items: [
        DropdownMenuItem(value: 'uz', child: Text(lp.getText('uzbek'))),
        DropdownMenuItem(value: 'en', child: Text(lp.getText('english'))),
        DropdownMenuItem(value: 'ru', child: Text(lp.getText('russian'))),
      ],
    );
  }
}
