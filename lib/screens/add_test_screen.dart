import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import '../models/quiz_models.dart';
import '../services/storage_service.dart';
import '../services/txt_parser.dart';

class AddTestScreen extends StatefulWidget {
  final String categoryName;
  final QuizSet? initialQuizSet;
  const AddTestScreen({
    super.key,
    required this.categoryName,
    this.initialQuizSet,
  });

  @override
  State<AddTestScreen> createState() => _AddTestScreenState();
}

class _AddTestScreenState extends State<AddTestScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late List<QuizQuestion> _questions;
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialQuizSet?.title ?? '',
    );
    _questions = widget.initialQuizSet != null
        ? List<QuizQuestion>.from(widget.initialQuizSet!.questions)
        : [];
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuizQuestion(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: '',
          options: ['', '', '', ''],
          correctAnswerIndex: 0,
        ),
      );
    });
  }

  Future<void> _importFromTxt() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'docx'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      String content = '';
      final extension = result.files.single.extension?.toLowerCase();

      try {
        if (extension == 'pdf') {
          final PdfDocument document = PdfDocument(
            inputBytes: await file.readAsBytes(),
          );
          content = PdfTextExtractor(document).extractText();
          document.dispose();
        } else if (extension == 'docx') {
          final bytes = await file.readAsBytes();
          content = docxToText(bytes);
        } else {
          content = await file.readAsString();
        }

        final newQuestions = TxtParser.parse(content);
        if (newQuestions.isNotEmpty) {
          setState(() {
            _questions.addAll(newQuestions);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${newQuestions.length} ta savol qo\'shildi'),
              ),
            );
          }
        } else {
          throw Exception('Savollar topilmadi');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xato: ${e.toString().split(':').last.trim()}'),
            ),
          );
        }
      }
    }
  }

  Future<void> _saveTest() async {
    if (_formKey.currentState!.validate() && _questions.isNotEmpty) {
      final quizSet = QuizSet(
        id:
            widget.initialQuizSet?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        questions: _questions,
      );
      await _storage.saveTest(widget.categoryName, quizSet);
      if (mounted) Navigator.pop(context);
    } else if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamida bitta savol qo\'shing')),
      );
    }
  }

  void _showGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test qo\'shish bo\'yicha yo\'riqnoma'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Qo\'lda kiritish:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Pastdagi "Savol qo\'shish" tugmasini bosing, savol matni va '
                'variantlarni kiriting. To\'g\'ri javobni radio-tugma orqali tanlang.',
              ),
              const SizedBox(height: 12),
              const Text(
                '2. TXT fayldan import qilish:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('Fayl quyidagi formatda bo\'lishi kerak:'),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[200],
                child: const Text(
                  'Savol matni?\n#To\'g\'ri javob\nNoto\'g\'ri javob 1\nNoto\'g\'ri javob 2',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Har bir savol "?" bilan tugashi kerak. To\'g\'ri javob '
                'oldidan "#" belgisini qo\'ying.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tushunarli'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialQuizSet != null
              ? 'Testni Tahrirlash'
              : 'Yangi Test Yaratish',
        ),
        actions: [
          IconButton(
            onPressed: _showGuide,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Yo\'riqnoma',
          ),
          IconButton(
            onPressed: _importFromTxt,
            icon: const Icon(Icons.file_upload),
            tooltip: 'TXT dan import qilish',
          ),
          IconButton(onPressed: _saveTest, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Test nomi',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Nom kiriting' : null,
            ),
            const SizedBox(height: 20),
            ..._questions.asMap().entries.map((entry) {
              int idx = entry.key;
              QuizQuestion q = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Savol ${idx + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                setState(() => _questions.removeAt(idx)),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: q.question,
                        onChanged: (v) => _questions[idx] = QuizQuestion(
                          id: q.id,
                          question: v,
                          options: q.options,
                          correctAnswerIndex: q.correctAnswerIndex,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Savol matni',
                        ),
                        validator: (v) => v!.isEmpty ? 'Savol kiriting' : null,
                      ),
                      const SizedBox(height: 10),
                      ...q.options.asMap().entries.map((optEntry) {
                        int optIdx = optEntry.key;
                        return RadioListTile<int>(
                          title: TextFormField(
                            initialValue: q.options[optIdx],
                            onChanged: (v) {
                              q.options[optIdx] = v;
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              hintText: '${optIdx + 1}-variant',
                            ),
                            validator: (v) =>
                                v!.isEmpty ? 'Variant kiriting' : null,
                          ),
                          value: optIdx,
                          groupValue: q.correctAnswerIndex,
                          onChanged: (v) => setState(
                            () => _questions[idx] = QuizQuestion(
                              id: q.id,
                              question: q.question,
                              options: q.options,
                              correctAnswerIndex: v!,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Savol qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }
}
