import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/google_auth_service.dart';
import '../widgets/custom_button.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureAuth - Google Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const GoogleLoginScreen(),
    );
  }
}

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  final GoogleAuthService _googleAuth = GoogleAuthService();
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Connecting to Google...';
    });

    try {
      final result = await _googleAuth.signInWithGoogle();
      
      if (result['success']) {
        final user = result['user'] as User;
        final isNewUser = result['isNewUser'] as bool;
        final needsVerification = result['needsVerification'] as bool;
        
        if (needsVerification) {
          // Send verification email
          final deviceInfo = await _googleAuth.deviceService.getDeviceInfo();
          await _googleAuth.sendVerificationEmail(
            email: user.email!,
            name: user.displayName ?? 'User',
            deviceInfo: deviceInfo.toString(),
            isNewUser: isNewUser,
          );
          
          setState(() {
            _statusMessage = isNewUser 
                ? 'Welcome! We\'ve sent a verification email to ${user.email}'
                : 'We\'ve sent a verification email to ${user.email} for security';
          });
          
          _showVerificationDialog(user, isNewUser);
        } else {
          setState(() {
            _statusMessage = 'Welcome back, ${user.displayName ?? user.email}!';
          });
          
          _showSuccessDialog(user);
        }
      } else {
        setState(() {
          _statusMessage = result['message'] as String;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showVerificationDialog(User user, bool isNewUser) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.email, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Check Your Email', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNewUser 
                  ? 'Welcome to SecureAuth! We\'ve created your account and sent a verification email.'
                  : 'For security, we\'ve sent a verification email to confirm this login.',
              style: GoogleFonts.inter(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.blue.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.email!,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please check your email and click the verification link to complete the process.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _googleAuth.signOut();
            },
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you'd navigate to a verification waiting screen
            },
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('Login Successful!', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: user.photoURL != null 
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null 
                  ? Text(
                      user.displayName?.isNotEmpty == true 
                          ? user.displayName![0].toUpperCase()
                          : user.email![0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome back, ${user.displayName ?? user.email}!',
              style: GoogleFonts.inter(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you'd navigate to the dashboard
            },
            child: Text('Continue', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureAuth'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Sign in with Google',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'We\'ll verify your account and send a confirmation email',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
                      foregroundColor: isDark ? Colors.white : const Color(0xFF1F2937),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google logo
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      'https://developers.google.com/identity/images/g-logo.png',
                                    ),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Status message
                if (_statusMessage.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _statusMessage.contains('Error') 
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _statusMessage.contains('Error') 
                            ? Colors.red.shade200
                            : Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusMessage.contains('Error') 
                              ? Icons.error
                              : Icons.info,
                          color: _statusMessage.contains('Error') 
                              ? Colors.red.shade600
                              : Colors.blue.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _statusMessage,
                            style: GoogleFonts.inter(
                              color: _statusMessage.contains('Error') 
                                  ? Colors.red.shade800
                                  : Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Features
                Text(
                  'What happens next?',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildFeature('1', 'Sign in with Google', 'We verify your Google account'),
                _buildFeature('2', 'Check your email', 'We send a verification email'),
                _buildFeature('3', 'Confirm access', 'Click the link to complete login'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF6366F1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
