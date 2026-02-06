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
  bool _practiceMistakesMode = false;

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
    List<Word> sourceWords;

    if (_practiceMistakesMode) {
      sourceWords = provider.mistakenWords;
      if (sourceWords.isEmpty) {
        setState(() => _practiceMistakesMode = false);
        sourceWords = provider.allWordsForQuiz;
      }
    } else {
      sourceWords = provider.allWordsForQuiz;
    }

    if (sourceWords.length < 4 && !_practiceMistakesMode) return;
    // If practice mode has fewer than 4, we might need to pad options from allWords
    final allWords = provider.allWordsForQuiz;

    final random = Random();
    _currentWord = sourceWords[random.nextInt(sourceWords.length)];

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

    // Reset state but keep the previous question visible until Next is clicked?
    // Actually _generateQuestion is called AFTER Next is clicked.
    setState(() {
      _options = options;
      _answered = false;
      _selectedOption = null;
    });
  }

  // Help Guide Dialog
  void _showHelp() {
    final lp = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(lp.getText('quiz_guide_title')),
          ],
        ),
        content: Text(lp.getText('quiz_guide_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
    final provider = context.read<DictionaryProvider>();
    setState(() {
      _answered = true;
      _selectedOption = option;
      _totalQuestions++;
      if (option == _correctAnswer) {
        _score++;
        if (_practiceMistakesMode) {
          provider.removeMistake(_currentWord);
        }
        // Auto-advance if correct
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _generateQuestion();
          }
        });
      } else {
        provider.addMistake(_currentWord);
        // Do nothing, wait for user to click Next
      }
    });
  }

  void _finishSession() {
    final localeProvider = context.read<LocaleProvider>();
    final provider = context.read<DictionaryProvider>();
    int mistakesCount = _totalQuestions - _score;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(localeProvider.getText('finish')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeProvider
                  .getText('quiz_summary')
                  .replaceAll('{total}', _totalQuestions.toString())
                  .replaceAll('{score}', _score.toString())
                  .replaceAll('{mistakes}', mistakesCount.toString()),
            ),
            if (mistakesCount > 0 || provider.mistakenWords.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                localeProvider
                    .getText('practice_mistakes_desc')
                    .replaceAll(
                      '{count}',
                      provider.mistakenWords.length.toString(),
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // User said NO. If they don't practice, mistakes persist because
              // the user asked "hatolar qolib to'grilar o'chmasin"
              // But if we want to CLEAR for a fresh session, we might want to clear.
              // However, user demand "Create new test for mistakes? Yes/No".
              // If No, we just go back to normal.
              setState(() {
                _score = 0;
                _totalQuestions = 0;
                _practiceMistakesMode = false;
              });
              _generateQuestion();
            },
            child: Text(localeProvider.getText('no')),
          ),
          if (mistakesCount > 0 || provider.mistakenWords.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (provider.mistakenWords.isNotEmpty) {
                  setState(() {
                    _score = 0;
                    _totalQuestions = 0;
                    _practiceMistakesMode = true;
                  });
                  _generateQuestion();
                }
              },
              child: Text(localeProvider.getText('yes')),
            ),
        ],
      ),
    );
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
            if (_practiceMistakesMode)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localeProvider.getText('practice_mistakes'),
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
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
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.indigo),
                      onPressed: () {
                        setState(() {
                          _score = 0;
                          _totalQuestions = 0;
                          _practiceMistakesMode = false;
                        });
                        _generateQuestion();
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.indigo),
                      onSelected: (value) {
                        if (value == 'help') {
                          _showHelp();
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'help',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.help_outline,
                                    color: Colors.indigo,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      localeProvider.getText(
                                        'quiz_guide_title',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.done_all, color: Colors.green),
                      onPressed: _finishSession,
                      tooltip: localeProvider.getText('finish'),
                    ),
                  ],
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
            if (_answered) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  localeProvider.getText('next'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
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
