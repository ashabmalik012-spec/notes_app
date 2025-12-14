import 'package:flutter/material.dart';
import 'package:notes_app/screens/HomeNoteScreen.dart';
import 'package:notes_app/theme/theme_management.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme color before running the app
  final prefs = await SharedPreferences.getInstance();
  int? colorValue = prefs.getInt("theme_color");

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(
        initialColor: colorValue != null ? Color(colorValue) : Colors.amber,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Notes App",
      theme: ThemeData(
        primarySwatch: createMaterialColor(themeProvider.primaryColor),
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.black,
        ),
      ),
      home: const HomeNoteScreen(),
    );
  }
}

// helper to create MaterialColor from any Color
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
