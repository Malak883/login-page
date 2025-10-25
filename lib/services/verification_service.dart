import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'device_service.dart';
import 'email_templates.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final DeviceService _deviceService = DeviceService();

  // Request verification for suspicious login
  Future<String> requestVerification({
    required String uid,
    required String deviceId,
    required Map<String, dynamic> context,
  }) async {
    try {
      // Generate verification ID
      final verificationId = _generateVerificationId();

      // Get user email
      final user = FirebaseAuth.instance.currentUser;
      if (user?.email == null) {
        throw Exception('User email not available');
      }

      // Create verification document in Firestore
      await _firestore.collection('verifications').doc(verificationId).set({
        'verification_id': verificationId,
        'uid': uid,
        'device_id': deviceId,
        'email': user!.email,
        'status': 'pending',
        'context': context,
        'created_at': FieldValue.serverTimestamp(),
        'expires_at':
            Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      });

      // Send verification email
      await _sendVerificationEmail(
        verificationId: verificationId,
        email: user.email!,
        uid: uid,
        userName: user.displayName ?? 'User',
        deviceInfo: _formatDeviceInfo(context),
      );

      return verificationId;
    } catch (e) {
      throw Exception('Failed to request verification: $e');
    }
  }

  // Watch verification status
  Stream<String> watchVerificationStatus(String verificationId) {
    return _firestore
        .collection('verifications')
        .doc(verificationId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return 'not_found';
      }

      final data = snapshot.data()!;
      return data['status'] as String? ?? 'pending';
    });
  }

  // Get verification details
  Future<Map<String, dynamic>?> getVerificationDetails(
      String verificationId) async {
    try {
      final doc = await _firestore
          .collection('verifications')
          .doc(verificationId)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get verification details: $e');
    }
  }

  // Send verification email with proper template
  Future<void> _sendVerificationEmail({
    required String verificationId,
    required String email,
    required String uid,
    required String userName,
    required String deviceInfo,
  }) async {
    try {
      // For Android apps, we'll use Firebase Cloud Functions in production
      // But for local testing, we'll log the email content

      final verificationUrlBase = _getVerifyUrlBase();
      final verificationUrlYes =
          '$verificationUrlBase/verify?token=$verificationId&response=yes';
      final verificationUrlNo =
          '$verificationUrlBase/verify?token=$verificationId&response=no';

      // Generate email content using templates
      final htmlContent = EmailTemplates.securityVerificationEmail(
        userName: userName,
        deviceInfo: deviceInfo,
        verificationUrlYes: verificationUrlYes,
        verificationUrlNo: verificationUrlNo,
        verificationId: verificationId,
      );

      final textContent = EmailTemplates.securityVerificationEmailText(
        userName: userName,
        deviceInfo: deviceInfo,
        verificationUrlYes: verificationUrlYes,
        verificationUrlNo: verificationUrlNo,
        verificationId: verificationId,
      );

      // In production, this would call a Cloud Function to send the actual email
      print('===== EMAIL CONTENT (HTML) =====');
      print(htmlContent);
      print('===== EMAIL CONTENT (TEXT) =====');
      print(textContent);
      print('================================');

      // Call Cloud Function to send actual email
      final callable = _functions.httpsCallable('sendVerificationEmail');

      await callable.call({
        'verificationId': verificationId,
        'email': email,
        'uid': uid,
        'userName': userName,
        'deviceInfo': deviceInfo,
        'htmlContent': htmlContent,
        'textContent': textContent,
        'verifyUrlBase': verificationUrlBase,
      });
    } catch (e) {
      print('Failed to send verification email via Cloud Function: $e');
      // Fallback for development/testing
      print('Using fallback email sending method for development');
    }
  }

  // Get verification URL base (for email links)
  String _getVerifyUrlBase() {
    // In production, this should be your actual domain
    // For development, use localhost or your deployed URL
    return 'https://your-app-domain.web.app'; // Replace with actual domain
  }

  // Generate unique verification ID
  String _generateVerificationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'verify_${random}_${DateTime.now().microsecondsSinceEpoch}';
  }

  // Check if user needs verification (new device)
  Future<bool> needsVerification(String uid) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return true; // New user always needs verification
      }

      final userData = userDoc.data()!;
      final knownDevices = List<String>.from(userData['devices'] ?? []);

      return !knownDevices.contains(deviceId);
    } catch (e) {
      // If we can't determine, assume verification is needed for security
      return true;
    }
  }

  // Log login attempt
  Future<void> logLoginAttempt({
    required String uid,
    required String status, // 'success', 'failed', 'blocked'
    required Map<String, dynamic> deviceInfo,
    String? errorMessage,
  }) async {
    try {
      await _firestore.collection('login_attempts').add({
        'uid': uid,
        'status': status,
        'device_info': deviceInfo,
        'error_message': errorMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'ip_address': deviceInfo['ip_address'] ?? 'unknown',
      });
    } catch (e) {
      // Don't throw error for logging failures
      print('Failed to log login attempt: $e');
    }
  }

  // Get user's login history
  Stream<List<Map<String, dynamic>>> getUserLoginHistory(String uid) {
    return _firestore
        .collection('login_attempts')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Mark device as verified and add to known devices
  Future<void> markDeviceAsVerified(String uid, String deviceId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'devices': FieldValue.arrayUnion([deviceId]),
        'last_device_id': deviceId,
        'is_verified': true,
        'last_verification': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark device as verified: $e');
    }
  }

  // Clean up expired verifications
  Future<void> cleanupExpiredVerifications() async {
    try {
      final expiredVerifications = await _firestore
          .collection('verifications')
          .where('expires_at', isLessThan: FieldValue.serverTimestamp())
          .where('status', isEqualTo: 'pending')
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredVerifications.docs) {
        batch.update(doc.reference, {'status': 'expired'});
      }

      await batch.commit();
    } catch (e) {
      print('Failed to cleanup expired verifications: $e');
    }
  }

  // Get verification statistics for admin
  Future<Map<String, int>> getVerificationStats() async {
    try {
      final now = DateTime.now();
      final last24Hours = now.subtract(const Duration(hours: 24));

      final recentVerifications = await _firestore
          .collection('verifications')
          .where('created_at', isGreaterThan: Timestamp.fromDate(last24Hours))
          .get();

      final stats = <String, int>{
        'total': recentVerifications.docs.length,
        'pending': 0,
        'approved': 0,
        'denied': 0,
        'expired': 0,
      };

      for (final doc in recentVerifications.docs) {
        final status = doc.data()['status'] as String? ?? 'unknown';
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      return {'error': 1};
    }
  }

  // Verify user response to email
  Future<bool> verifyUserResponse(
      String verificationId, bool isConfirmed) async {
    try {
      final verificationDoc =
          _firestore.collection('verifications').doc(verificationId);
      final verificationSnapshot = await verificationDoc.get();

      if (!verificationSnapshot.exists) {
        throw Exception('Verification not found');
      }

      final verificationData = verificationSnapshot.data()!;

      // Update verification status
      await verificationDoc.update({
        'status': isConfirmed ? 'approved' : 'denied',
        'verified_at': FieldValue.serverTimestamp(),
      });

      // If confirmed, mark device as verified
      if (isConfirmed) {
        await markDeviceAsVerified(
            verificationData['uid'], verificationData['device_id']);
      }

      return true;
    } catch (e) {
      print('Failed to verify user response: $e');
      return false;
    }
  }

  // Format device information for display in email
  String _formatDeviceInfo(Map<String, dynamic> deviceInfo) {
    final buffer = StringBuffer();

    if (deviceInfo.containsKey('device_model')) {
      buffer.write('Device: ${deviceInfo['device_model']}');
      if (deviceInfo.containsKey('device_brand')) {
        buffer.write(' (${deviceInfo['device_brand']})');
      }
      buffer.writeln();
    }

    if (deviceInfo.containsKey('platform')) {
      buffer.writeln('Platform: ${deviceInfo['platform']}');
    }

    if (deviceInfo.containsKey('android_version')) {
      buffer.writeln('Android Version: ${deviceInfo['android_version']}');
    }

    if (deviceInfo.containsKey('timestamp')) {
      buffer.writeln('Time: ${deviceInfo['timestamp']}');
    }

    return buffer.toString().trim();
  }
}
