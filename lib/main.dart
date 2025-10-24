// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';


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
      title: 'Flutter Login/Register',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
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
  bool _checking = false;

  // Check if email exists in 'users' collection
  Future<void> _checkEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter your email');
      return;
    }

    setState(() => _checking = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() {
          _showPasswordField = true;
        });
      } else {
        _showSnack('Email not found. Please register first.');
      }
    } catch (e) {
      _showSnack('Error checking email: $e');
    } finally {
      setState(() => _checking = false);
    }
  }

  // Verify password for the email
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (password.isEmpty) {
      _showSnack('Please enter your password');
      return;
    }

    setState(() => _checking = true);
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Login success
        _showSnack('Login successful!');
        // Optional: navigate to Home page and pass user data
        final userData = query.docs.first.data();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(userData: userData),
          ),
        );
      } else {
        _showSnack('Incorrect password');
      }
    } catch (e) {
      _showSnack('Login error: $e');
    } finally {
      setState(() => _checking = false);
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
                  onPressed: _checking
                      ? null
                      : (_showPasswordField ? _login : _checkEmail),
                  child: _checking
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

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _gender = 'Male';
  bool _saving = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() => _saving = true);
    try {
      // check if email already exists
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Email already exists')));
        return;
      }

      await FirebaseFirestore.instance.collection('users').add({
        'username': _usernameController.text.trim(),
        'email': email,
        // NOTE: storing plain password is NOT secure for production.
        // For production use Firebase Auth and never store raw passwords.
        'password': _passwordController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'gender': _gender,
        'created_at': FieldValue.serverTimestamp(),
      });

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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
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
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null,
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
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || v.isEmpty) ? 'Enter age' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Gender'),
              ),
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
  final Map<String, dynamic>? userData;
  const HomePage({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final username = userData != null ? (userData!['username'] ?? 'User') : 'User';
    final email = userData != null ? (userData!['email'] ?? '') : '';

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
               // logout: go back to login
               Navigator.of(context).pushAndRemoveUntil(
                 MaterialPageRoute(builder: (_) => const LoginPage()),
                 (route) => false,
               );
             },
             child: const Text('Logout'),
           )
          ],
        ),
      ),
    );
  }
}
