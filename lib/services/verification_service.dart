import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'device_service.dart';

class VerificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Initiate a verification request when login looks suspicious or new device.
  /// Returns the verification document ID that can be polled.
  Future<String> requestLoginVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final deviceId = await DeviceService.getOrCreateDeviceId();

    final docRef = await _db.collection('verifications').add({
      'userId': user.uid,
      'email': user.email,
      'deviceId': deviceId,
      'status': 'pending', // pending | approved | denied
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Trigger email via Cloud Function
    final callable = _functions.httpsCallable('sendVerificationEmail');
    await callable.call(<String, dynamic>{
      'verificationId': docRef.id,
      'email': user.email,
    });

    return docRef.id;
  }

  /// Stream the verification document status to update UI in real-time.
  Stream<String> watchVerificationStatus(String verificationId) {
    return _db.collection('verifications').doc(verificationId).snapshots().map(
      (snap) {
        final data = snap.data();
        if (data == null) return 'pending';
        return (data['status'] as String?) ?? 'pending';
      },
    );
  }
}
