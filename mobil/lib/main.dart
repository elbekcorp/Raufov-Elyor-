import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/dictionary_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: localeProvider.getText('app_title'),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          locale: localeProvider.locale,
          home: const SplashScreen(),
        );
      },
    );
  }
}
