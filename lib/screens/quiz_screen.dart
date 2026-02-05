import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../providers/locale_provider.dart';

class QuizScreen extends StatefulWidget {
  final QuizSet quizSet;
  final bool isPracticeMode;

  const QuizScreen({
    super.key,
    required this.quizSet,
    this.isPracticeMode = false,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _isAnswered = false;
  int? _selectedAnswerIndex;

  late List<String> _shuffledOptions;
  late int _shuffledCorrectIndex;

  final List<QuizQuestion> _mistakenQuestions = [];

  @override
  void initState() {
    super.initState();
    _setupQuestion();
  }

  void _setupQuestion() {
    final question = widget.quizSet.questions[_currentQuestionIndex];
    final originalOptions = List<String>.from(question.options);
    final correctAnswer = originalOptions[question.correctAnswerIndex];

    _shuffledOptions = List<String>.from(originalOptions)..shuffle();
    _shuffledCorrectIndex = _shuffledOptions.indexOf(correctAnswer);
  }

  void _answerQuestion(int index) {
    if (_isAnswered) return;

    setState(() {
      _isAnswered = true;
      _selectedAnswerIndex = index;
      if (index == _shuffledCorrectIndex) {
        _score++;
        // If in practice mode and answered correctly, we don't add to mistakes.
        // If we want to remove from future practice, we just don't add it to a new list.

        // Auto Advance if correct (User request: "to'g'ri javobda to'g'ridan to'g'ri keyingi testga o'tsin")
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _nextQuestion();
        });
      } else {
        // Wrong answer, track mistake
        _mistakenQuestions.add(widget.quizSet.questions[_currentQuestionIndex]);
        // Do nothing, wait for user to click Next
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quizSet.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _setupQuestion();
        _isAnswered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      _showResults();
    }
  }

  void _showHelp() {
    final lp = context.read<LocaleProvider>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(
              lp.getText('quiz_guide_title'),
            ), // Ensure this key exists or use fallback
          ],
        ),
        // Use a generic text if key doesn't exist, or ensure key is added to LocaleProvider
        content: Text(
          lp.getText('quiz_guide_content') == 'quiz_guide_content'
              ? "Test qo'shish uchun 'So'z qo'shish' bo'limiga o'ting va yangi so'zlarni kiriting. Ular avtomatik ravishda testga tushadi."
              : lp.getText('quiz_guide_content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResults() {
    final lp = context.read<LocaleProvider>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Natija'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To\'g\'ri javoblar: $_score / ${widget.quizSet.questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Foiz: ${((_score / widget.quizSet.questions.length) * 100).toStringAsFixed(1)}%',
            ),
            if (_mistakenQuestions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Xatolar soni: ${_mistakenQuestions.length}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
              const Text('Xatolar ustida ishlashni xohlaysizmi?'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: Text(lp.getText('cancel')), // Or "Yo'q"
          ),
          if (_mistakenQuestions.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                // Start Practice Mode with mistakes
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      quizSet: QuizSet(
                        id: 'mistakes',
                        title: 'Xatolar ustida ishlash',
                        questions: _mistakenQuestions,
                      ),
                      isPracticeMode: true,
                    ),
                  ),
                );
              },
              child: const Text('Ha, ishlash'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    final question = widget.quizSet.questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quizSet.title),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'help') _showHelp();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'help',
                child: Row(
                  children: [
                    const Icon(Icons.help_outline, color: Colors.indigo),
                    const SizedBox(width: 8),
                    const Text("Test qo'shish yo'riqnomasi"),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value:
                (_currentQuestionIndex + 1) / widget.quizSet.questions.length,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${lp.getText('questions')} ${_currentQuestionIndex + 1}/${widget.quizSet.questions.length}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              question.question,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ..._shuffledOptions.asMap().entries.map((entry) {
              int idx = entry.key;
              String text = entry.value;

              Color? btnColor;
              if (_isAnswered) {
                if (idx == _shuffledCorrectIndex) {
                  btnColor = Colors.green.withOpacity(0.3);
                } else if (idx == _selectedAnswerIndex) {
                  btnColor = Colors.red.withOpacity(0.3);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () => _answerQuestion(idx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color,
                    side: BorderSide(
                      color: _isAnswered && idx == _shuffledCorrectIndex
                          ? Colors.green
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(text, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
            if (_isAnswered)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    lp.getText('next') == 'next'
                        ? 'Keyingisi'
                        : lp.getText('next'),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
