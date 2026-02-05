import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localeProvider.getText('settings') == 'settings'
              ? 'Sozlamalar'
              : localeProvider.getText('settings'),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(localeProvider.getText('language')),
            trailing: DropdownButton<String>(
              value: localeProvider.locale.languageCode,
              underline: Container(),
              items: const [
                DropdownMenuItem(value: 'uz', child: Text('O\'zbek')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) localeProvider.setLocale(Locale(val));
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(localeProvider.getText('theme')),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.wb_sunny,
                    color: themeProvider.themeMode == ThemeMode.light
                        ? Colors.orange
                        : Colors.grey,
                  ),
                  onPressed: () => themeProvider.setThemeMode(ThemeMode.light),
                ),
                IconButton(
                  icon: Icon(
                    Icons.nightlight_round,
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.blue
                        : Colors.grey,
                  ),
                  onPressed: () => themeProvider.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.indigo),
            title: Text(localeProvider.getText('quiz_guide_title')),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      const Icon(Icons.help_outline, color: Colors.indigo),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(localeProvider.getText('quiz_guide_title')),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Text(localeProvider.getText('quiz_guide_content')),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(localeProvider.getText('save')),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
