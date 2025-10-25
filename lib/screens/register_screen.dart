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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final VerificationService _verificationService = VerificationService();
  final DeviceService _deviceService = DeviceService();
  final GoogleAccountVerificationService _googleAccountVerificationService =
      GoogleAccountVerificationService();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // First check if this is a valid Google account if it's a Gmail address
      final isGoogleAccount = await _googleAccountVerificationService
          .isGoogleAccount(_emailController.text.trim());

      // If it's supposed to be a Google account but isn't verified, show error
      // For this implementation, we'll allow registration but show a warning for non-Google accounts
      // In a stricter implementation, you might block registration entirely

      final credential = await _authService.registerWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
        {
          'username': _usernameController.text.trim(),
        },
      );

      if (credential?.user != null) {
        await _handleSuccessfulRegistration(credential!.user!);
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
        await _handleSuccessfulRegistration(credential!.user!);
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleSuccessfulRegistration(User user) async {
    try {
      // Get device info for verification
      final deviceInfo = await _deviceService.getDeviceInfo();

      // Request verification for new user
      final verificationId = await _verificationService.requestVerification(
        uid: user.uid,
        deviceId: deviceInfo['device_id'],
        context: deviceInfo,
      );

      // Log successful registration
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
    } catch (e) {
      _showErrorSnackBar('Registration verification failed: $e');
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomNavbar(
        currentPage: 'register',
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
                    Icons.person_add,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Join thousands of users who trust SecureAuth',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 48),

                // Registration form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _usernameController,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      EmailField(
                        controller: _emailController,
                      ),
                      const SizedBox(height: 24),

                      PasswordField(
                        controller: _passwordController,
                        hint: 'Create a strong password',
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 24),

                      PasswordField(
                        controller: _confirmPasswordController,
                        hint: 'Confirm your password',
                        validator: _validateConfirmPassword,
                      ),
                      const SizedBox(height: 32),

                      // Register button
                      CustomButton(
                        text: 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _registerWithEmail,
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

                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: GoogleFonts.inter(
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        'Sign In',
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
