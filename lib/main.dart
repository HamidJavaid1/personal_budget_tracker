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
  bool _isDark = false;
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

      if (mounted) {
        setState(() {
          _isFirstLaunch = isFirstLaunch;
          _selectedCurrency = savedCurrency;
          _isDark = prefs.getBool('dark_mode') ?? false;
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
    setState(() {
      _isDark = !_isDark;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('dark_mode', _isDark);
    });
  }

  void _handleCurrencySelected(String currency) {
    setState(() {
      _selectedCurrency = currency;
      _isFirstLaunch = false;
    });
  }

  ThemeData _lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2B6EF7),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF4F7FF),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  ThemeData _darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00E4FF),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF070A17),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFEAF8FF),
        displayColor: const Color(0xFFEAF8FF),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: _isFirstLaunch
          ? WelcomeScreen(onCurrencySelected: _handleCurrencySelected)
          : HomeScreen(
              isDarkMode: _isDark,
              onToggleTheme: _toggleTheme,
              selectedCurrency: _selectedCurrency,
            ),
    );
  }
}
