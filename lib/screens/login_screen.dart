import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_navbar.dart';
import '../services/firebase_auth_service.dart';
import '../services/verification_service.dart';
import '../services/device_service.dart';
import '../services/google_account_verification_service.dart';
import 'dashboard_screen.dart';
import 'verification_waiting_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final VerificationService _verificationService = VerificationService();
  final DeviceService _deviceService = DeviceService();
  final GoogleAccountVerificationService _googleAccountVerificationService =
      GoogleAccountVerificationService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First check if this is a valid Google account if it's a Gmail address
      final isGoogleAccount = await _googleAccountVerificationService
          .isGoogleAccount(_emailController.text.trim());

      // If it's supposed to be a Google account but isn't verified, show error
      // For this implementation, we'll allow login but show a warning for non-Google accounts
      // In a stricter implementation, you might block login entirely

      final credential = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (credential?.user != null) {
        await _handleSuccessfulLogin(credential!.user!);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      final credential = await _authService.signInWithGoogle();

      if (credential?.user != null) {
        await _handleSuccessfulLogin(credential!.user!);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleSuccessfulLogin(User user) async {
    try {
      // Check if device needs verification
      final needsVerification =
          await _verificationService.needsVerification(user.uid);

      if (needsVerification) {
        // Get device info for verification
        final deviceInfo = await _deviceService.getDeviceInfo();

        // Request verification
        final verificationId = await _verificationService.requestVerification(
          uid: user.uid,
          deviceId: deviceInfo['device_id'],
          context: deviceInfo,
        );

        // Log successful login attempt
        await _verificationService.logLoginAttempt(
          uid: user.uid,
          status: 'success',
          deviceInfo: deviceInfo,
        );

        // Navigate to verification waiting screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationWaitingScreen(
                verificationId: verificationId,
                user: user,
              ),
            ),
          );
        }
      } else {
        // Device is known, proceed to dashboard
        await _verificationService.logLoginAttempt(
          uid: user.uid,
          status: 'success',
          deviceInfo: await _deviceService.getDeviceInfo(),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(),
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Login verification failed: $e');
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('Please enter your email address first');
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);
      _showSuccessSnackBar('Password reset email sent to $email');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomNavbar(
        currentPage: 'login',
        isDarkMode: isDark,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and title
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Welcome Back',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Sign in to your account to continue',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 48),

                // Login form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      EmailField(
                        controller: _emailController,
                      ),
                      const SizedBox(height: 24),

                      PasswordField(
                        controller: _passwordController,
                      ),
                      const SizedBox(height: 16),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _sendPasswordReset,
                          child: Text(
                            'Forgot Password?',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF6366F1),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign in button
                      CustomButton(
                        text: 'Sign In',
                        isLoading: _isLoading,
                        onPressed: _signInWithEmail,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(
                        child: Divider(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: GoogleFonts.inter(
                          color:
                              isDark ? Colors.white54 : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Divider(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 32),

                // Google Sign-In button
                GoogleSignInButton(
                  isLoading: _isGoogleLoading,
                  onPressed: _signInWithGoogle,
                ),

                const SizedBox(height: 48),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.inter(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
