import 'dart:html' as html;
import 'dart:js' as js;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'device_service.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceService _deviceService = DeviceService();
  
  // Getter for device service
  DeviceService get deviceService => _deviceService;
  
  // Google Sign-In configuration for web
  static const String _webClientId = '139315326805-dcd3fb9d5cbf63be41c9dc.apps.googleusercontent.com';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: ['email', 'profile'],
  );

  // Check if user exists in our system
  Future<bool> checkUserExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Sign in with Google and handle verification
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {
          'success': false,
          'message': 'User cancelled sign-in',
          'needsVerification': false,
        };
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      
      // Check if this is a new user
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      final userExists = await checkUserExists(user.email!);
      
      if (isNewUser || !userExists) {
        // New user - create account and send verification
        await _createNewUser(user);
        return {
          'success': true,
          'message': 'New user created',
          'needsVerification': true,
          'user': user,
          'isNewUser': true,
        };
      } else {
        // Existing user - check device and send verification if needed
        final needsVerification = await _checkDeviceVerification(user);
        return {
          'success': true,
          'message': 'Existing user',
          'needsVerification': needsVerification,
          'user': user,
          'isNewUser': false,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Google Sign-In failed: $e',
        'needsVerification': false,
      };
    }
  }

  // Create new user in Firestore
  Future<void> _createNewUser(User user) async {
    final deviceInfo = await _deviceService.getDeviceInfo();
    
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
      'photoURL': user.photoURL,
      'created_at': FieldValue.serverTimestamp(),
      'last_login': FieldValue.serverTimestamp(),
      'devices': [deviceInfo['device_id']],
      'last_device_id': deviceInfo['device_id'],
      'is_verified': false,
      'login_count': 1,
      'provider': 'google',
    });
  }

  // Check if device needs verification
  Future<bool> _checkDeviceVerification(User user) async {
    try {
      final deviceInfo = await _deviceService.getDeviceInfo();
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final knownDevices = List<String>.from(userData['devices'] ?? []);
        
        // Update last login
        await _firestore.collection('users').doc(user.uid).update({
          'last_login': FieldValue.serverTimestamp(),
          'login_count': FieldValue.increment(1),
        });
        
        return !knownDevices.contains(deviceInfo['device_id']);
      }
      
      return true; // If user doc doesn't exist, needs verification
    } catch (e) {
      print('Error checking device verification: $e');
      return true; // Default to needing verification for security
    }
  }

  // Send verification email (placeholder - will be replaced with Cloud Function)
  Future<void> sendVerificationEmail({
    required String email,
    required String name,
    required String deviceInfo,
    required bool isNewUser,
  }) async {
    try {
      // For now, we'll create a verification document
      // In production, this will call a Cloud Function
      final verificationId = 'verify_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore.collection('verifications').doc(verificationId).set({
        'email': email,
        'name': name,
        'device_info': deviceInfo,
        'is_new_user': isNewUser,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'expires_at': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      });
      
      // TODO: Call Cloud Function to send actual email
      print('Verification email should be sent to: $email');
      print('Verification ID: $verificationId');
      
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
