import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart' as gsi;

import 'device_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Email/password registration using Firebase Auth.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (displayName != null && displayName.isNotEmpty) {
      await cred.user?.updateDisplayName(displayName);
    }

    // Create a user profile doc
    await _db.collection('users').doc(cred.user!.uid).set({
      'email': email,
      'displayName': displayName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
      'devices': [],
      'isVerified': true, // Email-based account considered verified for demo
      'provider': 'password',
    });

    return cred;
  }

  /// Email/password login
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _updateLoginMetadata(cred.user!);
    return cred;
  }

  /// Google Sign-In (web friendly). For web, uses google_sign_in; for others, same flow.
  Future<UserCredential> signInWithGoogle() async {
    if (!kIsWeb) {
      final googleSignIn = gsi.GoogleSignIn();
      final account = await googleSignIn.signIn();
      if (account == null) throw Exception('Google sign-in aborted');
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final cred = await _auth.signInWithCredential(credential);
      await _ensureUserDoc(cred.user!, provider: 'google');
      await _updateLoginMetadata(cred.user!);
      return cred;
    }

    // Web popup
    final provider = GoogleAuthProvider();
    final cred = await _auth.signInWithPopup(provider);
    await _ensureUserDoc(cred.user!, provider: 'google');
    await _updateLoginMetadata(cred.user!);
    return cred;
  }

  Future<void> _ensureUserDoc(User user, {required String provider}) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'email': user.email,
        'displayName': user.displayName ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'devices': [],
        'isVerified': user.emailVerified,
        'provider': provider,
      });
    }
  }

  Future<void> _updateLoginMetadata(User user) async {
    final ref = _db.collection('users').doc(user.uid);
    final deviceId = await DeviceService.getOrCreateDeviceId();
    await ref.set({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'devices': FieldValue.arrayUnion([deviceId]),
    }, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
