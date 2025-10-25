// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/about_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/terms_screen.dart';
import 'widgets/custom_navbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureAuth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AppWrapper(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/about': (context) => const AboutScreen(),
        '/contact': (context) => const ContactScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/terms': (context) => const TermsScreen(),
      },
    );
  }
}

class AppWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AppWrapper({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomNavbar(
        currentPage: 'home',
        onThemeToggle: toggleTheme,
        isDarkMode: isDarkMode,
      ),
      body: const HomeScreen(),
    );
  }
}

