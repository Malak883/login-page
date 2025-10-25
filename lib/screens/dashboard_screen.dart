import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_navbar.dart';
import '../services/firebase_auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomNavbar(
        currentPage: 'dashboard',
        isDarkMode: isDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            Text(
              'Welcome back, ${_user?.displayName ?? 'User'}!',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening with your account',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 32),

            // Dashboard cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildDashboardCard(
                  'Account Status',
                  'Verified',
                  Icons.verified,
                  Colors.green,
                  isDark,
                ),
                _buildDashboardCard(
                  'Last Login',
                  'Just now',
                  Icons.access_time,
                  Colors.blue,
                  isDark,
                ),
                _buildDashboardCard(
                  'Devices',
                  '1 Active',
                  Icons.devices,
                  Colors.orange,
                  isDark,
                ),
                _buildDashboardCard(
                  'Security',
                  'High',
                  Icons.security,
                  Colors.purple,
                  isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
