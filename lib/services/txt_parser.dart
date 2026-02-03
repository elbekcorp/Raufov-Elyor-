import '../models/quiz_models.dart';

class TxtParser {
  static List<QuizQuestion> parse(String text) {
    final List<QuizQuestion> questions = [];
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String currentQuestion = '';
    List<String> currentOptions = [];
    int correctAnswerIndex = -1;

    for (var line in lines) {
      // Filter out noise like ++++, ====, ----, ****
      if (RegExp(r'^[+=*\-!@#$%^&()_]{3,}$').hasMatch(line)) continue;

      if (line.endsWith('?')) {
        // If we have a pending question, save it before starting a new one
        if (currentQuestion.isNotEmpty &&
            currentOptions.isNotEmpty &&
            correctAnswerIndex != -1) {
          questions.add(
            QuizQuestion(
              id:
                  DateTime.now().millisecondsSinceEpoch.toString() +
                  questions.length.toString(),
              question: currentQuestion,
              options: currentOptions,
              correctAnswerIndex: correctAnswerIndex,
            ),
          );
        }
        // Start new question
        currentQuestion = line;
        currentOptions = [];
        correctAnswerIndex = -1;
      } else if (line.startsWith('#')) {
        correctAnswerIndex = currentOptions.length;
        currentOptions.add(line.substring(1).trim());
      } else if (currentQuestion.isNotEmpty) {
        currentOptions.add(line);
      }
    }

    // Add the last question
    if (currentQuestion.isNotEmpty &&
        currentOptions.isNotEmpty &&
        correctAnswerIndex != -1) {
      questions.add(
        QuizQuestion(
          id:
              DateTime.now().millisecondsSinceEpoch.toString() +
              questions.length.toString(),
          question: currentQuestion,
          options: currentOptions,
          correctAnswerIndex: correctAnswerIndex,
        ),
      );
    }

    return questions;
  }
}
