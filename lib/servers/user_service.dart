import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for Firestore user-related operations.
/// Handles user profile data (name, email, photo) and evaluations.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current user's UID, or null if not logged in.
  String? get _uid => _auth.currentUser?.uid;

  // ──────────────────────────────────────────────
  //  USER PROFILE
  // ──────────────────────────────────────────────

  /// Real-time stream of the current user's document.
  /// Emits a new snapshot whenever name, email, or photo changes.
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// One-shot fetch of the current user's data.
  Future<Map<String, dynamic>?> getUserData() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Update the user's display name in Firestore.
  Future<void> updateUserName(String name) async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({'name': name});
  }

  /// Store a profile photo as a base64-encoded string in Firestore.
  /// [imageBytes] — raw bytes of the selected image.
  Future<void> updateProfilePhoto(Uint8List imageBytes) async {
    final uid = _uid;
    if (uid == null) return;
    final base64String = base64Encode(imageBytes);
    await _firestore.collection('users').doc(uid).update({
      'photoBase64': base64String,
    });
  }

  /// Remove the user's profile photo from Firestore.
  Future<void> deleteProfilePhoto() async {
    final uid = _uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'photoBase64': '',
    });
  }

  /// Decode a base64 photo string into bytes for display.
  static Uint8List? decodePhoto(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────
  //  EVALUATIONS
  // ──────────────────────────────────────────────

  /// Real-time stream of the user's recent evaluations.
  /// Stored at: users/{uid}/evaluations
  /// Ordered by `createdAt` descending, limited to 10 most recent.
  Stream<QuerySnapshot<Map<String, dynamic>>> evaluationsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('evaluations')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }
}
