import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_navbar.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomNavbar(
        currentPage: 'privacy',
        isDarkMode: isDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.inter(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your privacy is important to us.',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
