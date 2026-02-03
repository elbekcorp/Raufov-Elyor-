import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../providers/locale_provider.dart';

class QuizScreen extends StatefulWidget {
  final QuizSet quizSet;
  const QuizScreen({super.key, required this.quizSet});

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
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
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
    });
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
          children: [
            Text(
              'To\'g\'ri javoblar: $_score / ${widget.quizSet.questions.length}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Foiz: ${((_score / widget.quizSet.questions.length) * 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(lp.getText('cancel')),
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
          ],
        ),
      ),
    );
  }
}
