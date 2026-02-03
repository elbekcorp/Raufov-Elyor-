class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correctAnswerIndex': correctAnswerIndex,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'],
    question: json['question'],
    options: List<String>.from(json['options']),
    correctAnswerIndex: json['correctAnswerIndex'],
  );
}

class QuizSet {
  final String id;
  final String title;
  final List<QuizQuestion> questions;

  QuizSet({required this.id, required this.title, required this.questions});

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'questions': questions.map((q) => q.toJson()).toList(),
  };

  factory QuizSet.fromJson(Map<String, dynamic> json) => QuizSet(
    id: json['id'],
    title: json['title'],
    questions: (json['questions'] as List)
        .map((q) => QuizQuestion.fromJson(q))
        .toList(),
  );
}

class TestCategory {
  final String name;
  final List<QuizSet> tests;

  TestCategory({required this.name, this.tests = const []});
}
