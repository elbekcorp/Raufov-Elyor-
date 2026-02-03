import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  Color _seedColor = Colors.deepPurple;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }

  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
  );

  ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  // Custom deep theme (Midnight Blue)
  ThemeData get deepTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A1A2E), // Custom deep color
      brightness: Brightness.dark,
      primary: const Color(0xFF1A1A2E),
      onPrimary: Colors.white,
      secondary: const Color(0xFF16213E),
      surface: const Color(0xFF0F3460),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF1A1A2E),
    cardTheme: CardThemeData(
      color: const Color(0xFF16213E),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
