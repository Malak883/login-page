import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;

  const CustomNavbar({
    super.key,
    required this.currentPage,
    this.onThemeToggle,
    this.isDarkMode = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    return AppBar(
      elevation: 0,
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.security,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'SecureAuth',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      actions: [
        // Navigation items for non-authenticated users
        if (!isLoggedIn) ...[
          _buildNavItem(context, 'Home', '/', currentPage == 'home'),
          _buildNavItem(context, 'About', '/about', currentPage == 'about'),
          _buildNavItem(context, 'Contact', '/contact', currentPage == 'contact'),
          const SizedBox(width: 16),
        ],
        
        // Theme toggle
        if (onThemeToggle != null)
          IconButton(
            onPressed: onThemeToggle,
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: isDarkMode ? Colors.white : const Color(0xFF6B7280),
            ),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        
        // User menu for authenticated users
        if (isLoggedIn) ...[
          PopupMenuButton<String>(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF6366F1),
              child: Text(
                user.displayName?.isNotEmpty == true 
                    ? user.displayName![0].toUpperCase()
                    : user.email![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onSelected: (value) {
              switch (value) {
                case 'dashboard':
                  Navigator.pushNamed(context, '/dashboard');
                  break;
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
                case 'logout':
                  _showLogoutDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dashboard',
                child: Row(
                  children: [
                    const Icon(Icons.dashboard, size: 20),
                    const SizedBox(width: 8),
                    Text('Dashboard', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text('Profile', style: GoogleFonts.inter()),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, size: 20, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Logout', style: GoogleFonts.inter(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ] else ...[
          // Login/Register buttons
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Login',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF6366F1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Get Started',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title, String route, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, route),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive 
                ? const Color(0xFF6366F1)
                : (isDarkMode ? Colors.white70 : const Color(0xFF6B7280)),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }
}
