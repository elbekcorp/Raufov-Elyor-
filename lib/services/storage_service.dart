import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/quiz_models.dart';

class StorageService {
  static const String _baseDirName = 'quiz_data';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> get _baseDir async {
    final path = await _localPath;
    final dir = Directory('$path/$_baseDirName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<TestCategory>> getCategories() async {
    final baseDir = await _baseDir;
    final List<TestCategory> categories = [];

    final List<FileSystemEntity> entities = await baseDir.list().toList();
    for (var entity in entities) {
      if (entity is Directory) {
        final categoryName = entity.path.split(Platform.pathSeparator).last;
        final tests = await getTestsInCategory(categoryName);
        categories.add(TestCategory(name: categoryName, tests: tests));
      }
    }
    return categories;
  }

  Future<void> createCategory(String name) async {
    final baseDir = await _baseDir;
    final dir = Directory('${baseDir.path}/$name');
    if (!await dir.exists()) {
      await dir.create();
    }
  }

  Future<void> deleteCategory(String name) async {
    final baseDir = await _baseDir;
    final dir = Directory('${baseDir.path}/$name');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<List<QuizSet>> getTestsInCategory(String categoryName) async {
    final baseDir = await _baseDir;
    final categoryDir = Directory('${baseDir.path}/$categoryName');
    if (!await categoryDir.exists()) return [];

    final List<QuizSet> tests = [];
    final List<FileSystemEntity> entities = await categoryDir.list().toList();
    for (var entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        final content = await entity.readAsString();
        tests.add(QuizSet.fromJson(jsonDecode(content)));
      }
    }
    return tests;
  }

  Future<void> saveTest(String categoryName, QuizSet quizSet) async {
    final baseDir = await _baseDir;
    final file = File('${baseDir.path}/$categoryName/${quizSet.id}.json');
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(quizSet.toJson()));
  }

  Future<void> deleteTest(String categoryName, String testId) async {
    final baseDir = await _baseDir;
    final file = File('${baseDir.path}/$categoryName/$testId.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> initializeDefaults() async {
    final categories = await getCategories();
    if (categories.isNotEmpty) return;

    // Create default categories
    final defaultCategories = ['Matematika', 'Tarix', 'Ona tili'];
    for (var cat in defaultCategories) {
      await createCategory(cat);
    }

    // Add sample test to Matematika
    await saveTest(
      'Matematika',
      QuizSet(
        id: 'sample_math_1',
        title: 'Oddiy arifmetika',
        questions: [
          QuizQuestion(
            id: 'q1',
            question: '2 + 2 nechaga teng?',
            options: ['3', '4', '5', '6'],
            correctAnswerIndex: 1,
          ),
          QuizQuestion(
            id: 'q2',
            question: '10 * 10 nechaga teng?',
            options: ['10', '100', '1000', '20'],
            correctAnswerIndex: 1,
          ),
        ],
      ),
    );

    // Add sample test to Tarix
    await saveTest(
      'Tarix',
      QuizSet(
        id: 'sample_history_1',
        title: 'O\'zbekiston tarixi (Qisqa)',
        questions: [
          QuizQuestion(
            id: 'h1',
            question: 'Amir Temur qachon tavallud topgan?',
            options: ['1336-yil', '1340-yil', '1405-yil', '1299-yil'],
            correctAnswerIndex: 0,
          ),
        ],
      ),
    );

    // Add sample test to Ona tili
    await saveTest(
      'Ona tili',
      QuizSet(
        id: 'sample_lang_1',
        title: 'Imlo qoidalari',
        questions: [
          QuizQuestion(
            id: 'l1',
            question: 'Qaysi so\'z to\'g\'ri yozilgan?',
            options: ['Mashina', 'Moshina', 'Mashyna', 'Moshyna'],
            correctAnswerIndex: 0,
          ),
        ],
      ),
    );
  }
}
