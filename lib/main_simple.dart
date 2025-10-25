import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'SecureAuth',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureAuth'),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                'Welcome to SecureAuth',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Professional authentication platform with Google-style verification',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Features
              _buildFeature('🔐', 'Secure Authentication', 'Email/Password & Google Sign-In'),
              const SizedBox(height: 16),
              _buildFeature('📧', 'Email Verification', 'Google-style "Was this you?" verification'),
              const SizedBox(height: 16),
              _buildFeature('📱', 'Device Tracking', 'Real-time device monitoring and security'),
              const SizedBox(height: 48),
              
              // Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Firebase Connected Successfully!',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Coming Soon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.construction, color: Colors.blue.shade600, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Full Authentication System',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Coming Soon - Cloud Functions & Complete UI',
                      style: GoogleFonts.inter(
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String emoji, String title, String description) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
