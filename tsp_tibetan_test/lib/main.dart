import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PastPapersApp());
}

class PastPapersApp extends StatelessWidget {
  const PastPapersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSP Tibetan Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Deep Blue
          secondary: const Color(0xFF009688), // Teal
          error: const Color(0xFFD32F2F), // Red
          surface: const Color(0xFFF5F5F5),
        ),
        textTheme: TextTheme(
          displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
          displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.inter(fontSize: 16),
          bodyMedium: GoogleFonts.inter(fontSize: 14),
          labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A237E),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A237E),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
