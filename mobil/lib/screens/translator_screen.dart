
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../providers/locale_provider.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final GoogleTranslator _translator = GoogleTranslator();
  final TextEditingController _controller = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  String _translatedText = "";
  bool _isListening = false;
  String _sourceLang = 'uz';
  String _targetLang = 'en';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    await Permission.microphone.request();
    await _speech.initialize();
  }

  void _translate() async {
    if (_controller.text.isEmpty) return;
    
    try {
      final translation = await _translator.translate(
        _controller.text,
        from: _sourceLang,
        to: _targetLang,
      );
      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedText = "Error: $e";
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_controller.text.isNotEmpty) _translate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLangDropdown(_sourceLang, (v) => setState(() => _sourceLang = v!), localeProvider),
                  const Icon(Icons.swap_horiz, color: Colors.indigo, size: 30),
                  _buildLangDropdown(_targetLang, (v) => setState(() => _targetLang = v!), localeProvider),
                ],
              ),
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _controller,
              maxLines: 6,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: localeProvider.getText('speech_hint'),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton(
                    mini: true,
                    onPressed: _listen,
                    backgroundColor: _isListening ? Colors.red : Colors.indigo,
                    elevation: 0,
                    child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _translate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.translate),
                  const SizedBox(width: 10),
                  Text(localeProvider.getText('translate_button'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            if (_translatedText.isNotEmpty) ...[
              const Align(
                child: Divider(),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.indigo.withOpacity(0.1)),
                ),
                child: Text(
                  _translatedText,
                  style: const TextStyle(fontSize: 20, color: Colors.indigo, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLangDropdown(String value, Function(String?) onChanged, LocaleProvider lp) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.indigo),
      items: [
        DropdownMenuItem(value: 'uz', child: Text(lp.getText('uzbek'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
        DropdownMenuItem(value: 'en', child: Text(lp.getText('english'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
        DropdownMenuItem(value: 'ru', child: Text(lp.getText('russian'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo))),
      ],
      onChanged: onChanged,
    );
  }
}
