import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dictionary_screen.dart';
import 'translator_screen.dart';
import 'quiz_screen.dart';
import 'add_word_screen.dart';
import 'settings_screen.dart';
import '../providers/locale_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DictionaryScreen(),
    const TranslatorScreen(),
    const QuizScreen(),
    const AddWordScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localeProvider.getText('app_title'),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.indigo),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF1A237E),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Text('🤔', style: TextStyle(fontSize: 24)),
              activeIcon: const Text('🤔', style: TextStyle(fontSize: 24)),
              label: localeProvider.getText('tab_dictionary'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.translate_outlined),
              activeIcon: const Icon(Icons.translate),
              label: localeProvider.getText('tab_translator'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.quiz_outlined),
              activeIcon: const Icon(Icons.quiz),
              label: localeProvider.getText('tab_quiz'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_circle_outline),
              activeIcon: const Icon(Icons.add_circle),
              label: localeProvider.getText('tab_add'),
            ),
          ],
        ),
      ),
    );
  }
}
