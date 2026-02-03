
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_provider.dart';
import '../providers/locale_provider.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _uzController = TextEditingController();
  final _enController = TextEditingController();
  final _ruController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _save(LocaleProvider lp) async {
    if (_formKey.currentState!.validate()) {
      await context.read<DictionaryProvider>().addWord(
        _uzController.text,
        _enController.text,
        _ruController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lp.locale.languageCode == 'uz' 
                ? "So'z muvaffaqiyatli qo'shildi!" 
                : (lp.locale.languageCode == 'ru' ? "Слово успешно добавлено!" : "Word added successfully!")), 
            backgroundColor: Colors.green
          ),
        );
        _uzController.clear();
        _enController.clear();
        _ruController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_uzController, localeProvider.getText('uzbek'), Icons.language),
              const SizedBox(height: 15),
              _buildTextField(_enController, localeProvider.getText('english'), Icons.translate),
              const SizedBox(height: 15),
              _buildTextField(_ruController, localeProvider.getText('russian'), Icons.translate),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _save(localeProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                ),
                child: Text(localeProvider.getText('save'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.indigo, width: 2),
        ),
      ),
      validator: (value) => value!.isEmpty ? "..." : null,
    );
  }
}
