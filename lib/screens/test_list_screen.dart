import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz_models.dart';
import '../services/storage_service.dart';
import '../providers/locale_provider.dart';
import 'quiz_screen.dart';
import 'add_test_screen.dart';

class TestListScreen extends StatefulWidget {
  final TestCategory category;
  const TestListScreen({super.key, required this.category});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final StorageService _storage = StorageService();
  late List<QuizSet> _tests;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tests = widget.category.tests;
    _loadTests();
  }

  Future<void> _loadTests() async {
    setState(() => _isLoading = true);
    final tests = await _storage.getTestsInCategory(widget.category.name);
    setState(() {
      _tests = tests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tests.isEmpty
          ? _buildEmptyState(lp)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tests.length,
              itemBuilder: (context, index) {
                final test = _tests[index];
                return _buildTestCard(test, lp);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddTestScreen(categoryName: widget.category.name),
            ),
          ).then((_) => _loadTests());
        },
        label: Text(lp.getText('add_test')),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(LocaleProvider lp) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${lp.getText('app_title')} yo\'q', // Simple fallback or add more keys
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCard(QuizSet test, LocaleProvider lp) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          test.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${test.questions.length} ${lp.getText('questions')}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.green,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(quizSet: test),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTestScreen(
                      categoryName: widget.category.name,
                      initialQuizSet: test,
                    ),
                  ),
                ).then((_) => _loadTests());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () => _confirmDelete(test, lp),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(QuizSet test, LocaleProvider lp) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lp.getText('delete')),
        content: Text('"${test.title}" o\'chib ketadi. Ishonchingiz komilmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lp.getText('cancel')),
          ),
          TextButton(
            onPressed: () async {
              await _storage.deleteTest(widget.category.name, test.id);
              _loadTests();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              lp.getText('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
