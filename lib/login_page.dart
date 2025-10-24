import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool showPasswordField = false;

  Future<void> _checkEmail() async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        showPasswordField = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email not found')),
      );
    }
  }

  Future<void> _login() async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .where('password', isEqualTo: _passwordController.text)
        .get();

    if (query.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
      // هنا ممكن تضيفي صفحة رئيسية بعد تسجيل الدخول
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wrong password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text('Sign in',
                    style: GoogleFonts.poppins(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Use your Email',
                    style: GoogleFonts.poppins(
                        fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (showPasswordField) ...[
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: showPasswordField ? _login : _checkEmail,
                    child: Text(showPasswordField ? 'Login' : 'Next',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()));
                  },
                  child: Text('Create account',
                      style: GoogleFonts.poppins(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
