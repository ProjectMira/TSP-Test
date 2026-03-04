import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'screens/home_screen.dart';
import 'services/app_settings_controller.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('App Starting: TSP Tibetan Test');
  runApp(const PastPapersApp());
}

class PastPapersApp extends StatefulWidget {
  const PastPapersApp({super.key});

  @override
  State<PastPapersApp> createState() => _PastPapersAppState();
}

class _PastPapersAppState extends State<PastPapersApp> {
  late final Future<AppSettingsController> _settingsFuture;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _createSettingsController();
  }

  Future<AppSettingsController> _createSettingsController() async {
    final controller = AppSettingsController(
      preferencesService: PreferencesService(),
      notificationService: NotificationService(),
    );
    try {
      await controller.initialize().timeout(const Duration(seconds: 8));
    } catch (error, stackTrace) {
      developer.log(
        'Settings initialization failed, continuing with defaults',
        name: 'PastPapersApp',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppSettingsController>(
      future: _settingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final settingsController = snapshot.data!;
        return AnimatedBuilder(
          animation: settingsController,
          builder: (context, _) {
            return MaterialApp(
              title: 'TSP Tibetan Test',
              debugShowCheckedModeBanner: false,
              themeMode: settingsController.themeMode,
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              home: HomeScreen(settingsController: settingsController),
            );
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A237E),
      secondary: const Color(0xFF009688),
      error: const Color(0xFFD32F2F),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(fontSize: 16),
        bodyMedium: const TextStyle(fontSize: 14),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF7986CB),
      secondary: const Color(0xFF4DB6AC),
      error: const Color(0xFFEF5350),
      brightness: Brightness.dark,
      surface: const Color(0xFF121212),
      onSurface: const Color(0xFFE8E8E8),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      textTheme: TextTheme(
        displayLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE8E8E8)),
        displayMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE8E8E8)),
        bodyLarge: const TextStyle(fontSize: 16, color: Color(0xFFCCCCCC)),
        bodyMedium: const TextStyle(fontSize: 14, color: Color(0xFFCCCCCC)),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFCCCCCC)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: const Color(0xFF9FA8DA),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9FA8DA),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF1E1E1E),
      ),
      dividerColor: const Color(0xFF2C2C2C),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFF3A3A3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFF3A3A3A)),
        ),
      ),
    );
  }
}
