import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Consistent background
      appBar: AppBar(
        title: Text(
          localeProvider.getText('settings') == 'settings'
              ? 'Sozlamalar'
              : localeProvider.getText('settings'), // Fallback if key missing
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.indigo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(localeProvider, 'Language'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _buildLanguageItem(context, localeProvider, 'uz', "O'zbekcha"),
                const Divider(height: 1),
                _buildLanguageItem(context, localeProvider, 'en', "English"),
                const Divider(height: 1),
                _buildLanguageItem(context, localeProvider, 'ru', "Русский"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(localeProvider, 'Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.indigo),
              title: Text(localeProvider.getText('info_title')),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: () => _showInfoDialog(context, localeProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(LocaleProvider lp, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title, // Simplified, ideally localized too if keys exist
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    LocaleProvider lp,
    String code,
    String name,
  ) {
    final isSelected = lp.locale.languageCode == code;
    return ListTile(
      leading: Text(_getFlag(code), style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.indigo : Colors.black87,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.indigo)
          : null,
      onTap: () => lp.setLocale(Locale(code)),
    );
  }

  String _getFlag(String code) {
    switch (code) {
      case 'uz':
        return '🇺🇿';
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      default:
        return '🏳️';
    }
  }

  void _showInfoDialog(BuildContext context, LocaleProvider lp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.indigo),
            const SizedBox(width: 10),
            Text(lp.getText('info_title')),
          ],
        ),
        content: SingleChildScrollView(child: Text(lp.getText('add_info'))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
