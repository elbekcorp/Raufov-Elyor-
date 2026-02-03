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
}
