import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/verification_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/device_service.dart';
import 'dashboard_screen.dart';

class VerificationWaitingScreen extends StatefulWidget {
  final String verificationId;
  final User user;

  const VerificationWaitingScreen({
    super.key,
    required this.verificationId,
    required this.user,
  });

  @override
  State<VerificationWaitingScreen> createState() => _VerificationWaitingScreenState();
}

class _VerificationWaitingScreenState extends State<VerificationWaitingScreen> {
  final VerificationService _verificationService = VerificationService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final DeviceService _deviceService = DeviceService();
  
  String _status = 'pending';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToVerificationStatus();
  }

  void _listenToVerificationStatus() {
    _verificationService.watchVerificationStatus(widget.verificationId).listen(
      (status) {
        setState(() {
          _status = status;
          _isLoading = false;
        });

        if (status == 'approved') {
          _handleApproved();
        } else if (status == 'denied') {
          _handleDenied();
        }
      },
      onError: (error) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Verification error: $error');
      },
    );
  }

  Future<void> _handleApproved() async {
    try {
      // Mark device as verified
      final deviceId = await _deviceService.getDeviceId();
      await _verificationService.markDeviceAsVerified(widget.user.uid, deviceId);
      
      // Navigate to dashboard
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to complete verification: $e');
    }
  }

  void _handleDenied() {
    _showErrorSnackBar('Verification was denied. Please try again.');
    // Sign out and return to login
    _authService.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    size: 60,
                    color: _getStatusColor(),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  _getStatusTitle(),
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  _getStatusDescription(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Loading indicator or status
                if (_isLoading || _status == 'pending') ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Waiting for verification...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                    ),
                  ),
                ] else if (_status == 'approved') ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Verification successful!',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ] else if (_status == 'denied') ...[
                  const Icon(Icons.cancel, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Verification denied',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Action buttons
                if (_status == 'denied') ...[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text('Try Again'),
                  ),
                ] else if (_status == 'pending') ...[
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case 'approved':
        return Colors.green;
      case 'denied':
        return Colors.red;
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getStatusIcon() {
    switch (_status) {
      case 'approved':
        return Icons.check_circle;
      case 'denied':
        return Icons.cancel;
      default:
        return Icons.email;
    }
  }

  String _getStatusTitle() {
    switch (_status) {
      case 'approved':
        return 'Verification Complete!';
      case 'denied':
        return 'Verification Denied';
      default:
        return 'Check Your Email';
    }
  }

  String _getStatusDescription() {
    switch (_status) {
      case 'approved':
        return 'Your device has been verified successfully. You can now access your account.';
      case 'denied':
        return 'The verification request was denied. This could be due to security concerns or an incorrect response.';
      default:
        return 'We\'ve sent a verification request to ${widget.user.email}. Please check your email and click "Yes" to approve this login attempt.';
    }
  }
}
