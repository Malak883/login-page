// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/firebase_auth_service.dart';
import 'services/verification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class VerificationWaitingScreen extends StatelessWidget {
  final String verificationId;
  const VerificationWaitingScreen({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    final service = VerificationService();
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your login')),
      body: Center(
        child: StreamBuilder<String>(
          stream: service.watchVerificationStatus(verificationId),
          builder: (context, snapshot) {
            final status = snapshot.data ?? 'pending';
            if (status == 'approved') {
              // Navigate to home
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              });
            } else if (status == 'denied') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              });
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  status == 'pending'
                      ? 'We sent a verification request to your email. Please confirm.'
                      : 'Status: $status',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login/Register',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthGate(),
    );
  }
}

/// Simple auth gate to route signed-in users to Home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>
        (
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (user == null) {
          return const LoginPage();
        }
        return const HomePage();
      },
    );
  }
}

class VerificationWaitingScreen extends StatelessWidget {
  final String verificationId;
  const VerificationWaitingScreen({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    final service = VerificationService();
    return Scaffold(
      appBar: AppBar(title: const Text('Verify your login')),
      body: Center(
        child: StreamBuilder<String>(
          stream: service.watchVerificationStatus(verificationId),
          builder: (context, snapshot) {
            final status = snapshot.data ?? 'pending';
            if (status == 'approved') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
                );
              });
            } else if (status == 'denied') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              });
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  status == 'pending'
                      ? 'We sent a verification request to your email. Please confirm.'
                      : 'Status: $status',
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// =====================
/// Login Page (two-step: email -> password)
/// =====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showPasswordField = false;
  bool _busy = false;
  final _authService = FirebaseAuthService();
  final _verificationService = VerificationService();

  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter your email');
      return;
    }
    setState(() => _busy = true);
    try {
      // Check if an account exists in Firebase Auth by trying sign-in with link? Not available.
      // For UX, reveal password field directly.
      setState(() => _showPasswordField = true);
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loginWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnack('Enter email and password');
      return;
    }
    setState(() => _busy = true);
    try {
      final cred = await _authService.signInWithEmail(email: email, password: password);
      // Simple suspicious-device heuristic: if sign-in just added a new device, ask for verification
      final verificationId = await _verificationService.requestLoginVerification();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationWaitingScreen(verificationId: verificationId)),
      );
    } catch (e) {
      _showSnack('Login failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _busy = true);
    try {
      await _authService.signInWithGoogle();
      final verificationId = await _verificationService.requestLoginVerification();
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => VerificationWaitingScreen(verificationId: verificationId)),
      );
    } catch (e) {
      _showSnack('Google sign-in failed: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const FlutterLogo(size: 72),
              const SizedBox(height: 20),
              Text('Sign in', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              const Text('Enter your email then press Next'),
              const SizedBox(height: 24),

              _buildEmailField(),
              const SizedBox(height: 16),

              if (_showPasswordField) ...[
                _buildPasswordField(),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _busy
                      ? null
                      : (_showPasswordField ? _loginWithEmail : _checkEmail),
                  child: _busy
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_showPasswordField ? 'Login' : 'Next'),
                ),
              ),

              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text('Create account'),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _loginWithGoogle,
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Sign in with Google'),
                ),
              ),

              const SizedBox(height: 18),
              TextButton(
                onPressed: () {
                  // Optional: reset the flow
                  setState(() {
                    _showPasswordField = false;
                    _passwordController.clear();
                  });
                },
                child: const Text('Use a different email'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Register Page
/// =====================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = FirebaseAuthService();

  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _saving = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _displayNameController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registered successfully')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Full name (optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter password' : null,
              ),
              const SizedBox(height: 12),
              // Removed non-essential demo fields
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _registerUser,
                  child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =====================
/// Simple Home Page to navigate after successful login
/// =====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final username = user?.displayName ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Text('Welcome, $username', style: const TextStyle(fontSize: 20)),
           const SizedBox(height: 6),
           Text(email, style: const TextStyle(color: Colors.grey)),
           const SizedBox(height: 24),
           ElevatedButton(
             onPressed: () {
              FirebaseAuth.instance.signOut();
             },
             child: const Text('Logout'),
           )
          ],
        ),
      ),
    );
  }
}
