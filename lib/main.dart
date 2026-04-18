import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_budget_tracker/screens.dart/homescreen.dart';
import 'package:personal_budget_tracker/screens.dart/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isFirstLaunch = true;
  String _selectedCurrency = 'USD';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('first_launch_completed') != true;
      final savedCurrency = prefs.getString('selected_currency') ?? 'USD';
      final savedThemeMode = prefs.getString('theme_mode');
      final legacyDarkFlag = prefs.getBool('dark_mode');

      ThemeMode resolvedThemeMode;
      if (savedThemeMode == 'dark') {
        resolvedThemeMode = ThemeMode.dark;
      } else if (savedThemeMode == 'light') {
        resolvedThemeMode = ThemeMode.light;
      } else {
        // Backward compatibility for older versions that used dark_mode bool.
        resolvedThemeMode = (legacyDarkFlag ?? false)
            ? ThemeMode.dark
            : ThemeMode.light;
      }

      if (mounted) {
        setState(() {
          _isFirstLaunch = isFirstLaunch;
          _selectedCurrency = savedCurrency;
          _themeMode = resolvedThemeMode;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleTheme() {
    final nextThemeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    setState(() {
      _themeMode = nextThemeMode;
    });

    SharedPreferences.getInstance().then((prefs) {
      final isDark = nextThemeMode == ThemeMode.dark;
      prefs.setString('theme_mode', isDark ? 'dark' : 'light');
      // Keep legacy flag in sync for compatibility.
      prefs.setBool('dark_mode', isDark);
    });
  }

  void _handleCurrencySelected(String currency) {
    setState(() {
      _selectedCurrency = currency;
      _isFirstLaunch = false;
    });
  }

  Future<void> _handleCurrencyChanged(String currency) async {
    setState(() {
      _selectedCurrency = currency;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', currency);
  }

  ThemeData _lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2B6EF7),
      brightness: Brightness.light,
    );
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4F7FF),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );
  }

  ThemeData _darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00E4FF),
      brightness: Brightness.dark,
    );
    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF070A17),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFEAF8FF),
        displayColor: const Color(0xFFEAF8FF),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111A32),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF101936),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2848),
        contentTextStyle: const TextStyle(color: Color(0xFFEAF8FF)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  const Color(0xFF2B6EF7),
                  const Color(0xFF00E4FF),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartBudget',
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: _themeMode,
      home: _isFirstLaunch
          ? WelcomeScreen(
              onCurrencySelected: _handleCurrencySelected,
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            )
          : HomeScreen(
              key: ValueKey<String>(_themeMode.name),
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
              onCurrencyChanged: _handleCurrencyChanged,
              selectedCurrency: _selectedCurrency,
            ),
    );
  }
}
