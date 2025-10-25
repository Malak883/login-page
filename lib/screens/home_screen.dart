import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark 
                      ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
                      : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                  child: Column(
                    children: [
                      // Main heading
                      Text(
                        'Secure Authentication\nMade Simple',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Subtitle
                      Text(
                        'Enterprise-grade security with Google-style verification,\nreal-time device tracking, and seamless user experience.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // CTA Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomButton(
                            text: 'Get Started',
                            width: 180,
                            onPressed: () => Navigator.pushNamed(context, '/register'),
                          ),
                          const SizedBox(width: 16),
                          CustomButton(
                            text: 'Learn More',
                            width: 180,
                            isSecondary: true,
                            onPressed: () => _scrollToFeatures(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Features Section
            _buildFeaturesSection(context, isDark),

            // Security Section
            _buildSecuritySection(context, isDark),

            // Stats Section
            _buildStatsSection(context, isDark),

            // CTA Section
            _buildCTASection(context, isDark),

            // Footer
            _buildFooter(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Why Choose SecureAuth?',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Built with enterprise security standards and user experience in mind',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 64),
          
          // Features Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isWide ? 3 : 1,
                mainAxisSpacing: 32,
                crossAxisSpacing: 32,
                childAspectRatio: isWide ? 1.2 : 1.5,
                children: [
                  _buildFeatureCard(
                    context,
                    Icons.security,
                    'Advanced Security',
                    'Google-style verification, device tracking, and real-time threat detection',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.speed,
                    'Lightning Fast',
                    'Optimized performance with real-time updates and seamless user experience',
                    isDark,
                  ),
                  _buildFeatureCard(
                    context,
                    Icons.devices,
                    'Cross-Platform',
                    'Works perfectly on web, mobile, and desktop with responsive design',
                    isDark,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    bool isDark,
  ) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF9FAFB),
      child: Column(
        children: [
          Text(
            'Enterprise-Grade Security',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your data is protected with industry-leading security measures',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 64),
          
          // Security features
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Row(
                children: [
                  if (isWide) ...[
                    Expanded(
                      child: _buildSecurityFeature(
                        'Device Verification',
                        'Automatic detection of new devices with email verification',
                        Icons.phone_android,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildSecurityFeature(
                        'Real-time Monitoring',
                        'Track all login attempts and suspicious activities',
                        Icons.monitor_heart,
                        isDark,
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: _buildSecurityFeature(
                        'Encrypted Storage',
                        'All sensitive data is encrypted and securely stored',
                        Icons.lock,
                        isDark,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Column(
                        children: [
                          _buildSecurityFeature(
                            'Device Verification',
                            'Automatic detection of new devices with email verification',
                            Icons.phone_android,
                            isDark,
                          ),
                          const SizedBox(height: 32),
                          _buildSecurityFeature(
                            'Real-time Monitoring',
                            'Track all login attempts and suspicious activities',
                            Icons.monitor_heart,
                            isDark,
                          ),
                          const SizedBox(height: 32),
                          _buildSecurityFeature(
                            'Encrypted Storage',
                            'All sensitive data is encrypted and securely stored',
                            Icons.lock,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(
    String title,
    String description,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 48,
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          Text(
            'Trusted by Thousands',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 64),
          
          // Stats
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStat('10K+', 'Active Users', isDark),
                  if (isWide) const SizedBox(width: 32),
                  _buildStat('99.9%', 'Uptime', isDark),
                  if (isWide) const SizedBox(width: 32),
                  _buildStat('24/7', 'Support', isDark),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String number, String label, bool isDark) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: isDark ? Colors.white70 : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildCTASection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)]
              : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Get Started?',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join thousands of users who trust SecureAuth for their authentication needs',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: 'Create Account',
            width: 200,
            onPressed: () => Navigator.pushNamed(context, '/register'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      color: isDark ? const Color(0xFF0F0F0F) : const Color(0xFF1F2937),
      child: Column(
        children: [
          Text(
            'SecureAuth',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '© 2024 SecureAuth. All rights reserved.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToFeatures(BuildContext context) {
    // Scroll to features section
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
