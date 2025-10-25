import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'device_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final DeviceService _deviceService = DeviceService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await _updateUserLastLogin(credential.user!.uid);
        await _checkAndHandleDeviceVerification(credential.user!);
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmail(
    String email, 
    String password, 
    Map<String, dynamic> extraData
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name if provided
        if (extraData['username'] != null) {
          await credential.user!.updateDisplayName(extraData['username']);
        }

        // Create user document in Firestore
        await _createUserDocument(credential.user!, extraData);
        await _checkAndHandleDeviceVerification(credential.user!);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Check if this is a new user
        final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        
        if (isNewUser) {
          // Create user document for new Google users
          await _createUserDocument(userCredential.user!, {
            'username': userCredential.user!.displayName ?? 'User',
            'email': userCredential.user!.email,
            'photoURL': userCredential.user!.photoURL,
          });
        } else {
          await _updateUserLastLogin(userCredential.user!.uid);
        }
        
        await _checkAndHandleDeviceVerification(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
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
      throw Exception('Sign out failed: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, Map<String, dynamic> extraData) async {
    final deviceId = await _deviceService.getDeviceId();
    
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'username': extraData['username'] ?? user.displayName ?? 'User',
      'photoURL': extraData['photoURL'] ?? user.photoURL,
      'created_at': FieldValue.serverTimestamp(),
      'last_login': FieldValue.serverTimestamp(),
      'last_device_id': deviceId,
      'devices': [deviceId],
      'is_verified': false,
      'login_count': 1,
    }, SetOptions(merge: true));
  }

  // Update user's last login
  Future<void> _updateUserLastLogin(String uid) async {
    final deviceId = await _deviceService.getDeviceId();
    
    await _firestore.collection('users').doc(uid).update({
      'last_login': FieldValue.serverTimestamp(),
      'last_device_id': deviceId,
      'login_count': FieldValue.increment(1),
    });
  }

  // Check if device needs verification and handle accordingly
  Future<void> _checkAndHandleDeviceVerification(User user) async {
    final deviceId = await _deviceService.getDeviceId();
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final knownDevices = List<String>.from(userData['devices'] ?? []);
      
      if (!knownDevices.contains(deviceId)) {
        // New device - needs verification
        // This will be handled by the verification service
        // For now, we'll just add the device to the list after verification
      }
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Add device to user's known devices
  Future<void> addKnownDevice(String uid, String deviceId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'devices': FieldValue.arrayUnion([deviceId]),
        'last_device_id': deviceId,
      });
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }
}
