import 'package:cloud_firestore/cloud_firestore.dart';

/// Initialise only missing fields; never replace an owner's edited profile.
Future<void> ensureGoogleProfile(
  FirebaseFirestore firestore, {
  required String uid,
  required String? name,
  required String? email,
}) async {
  final reference = firestore.collection('users').doc(uid);
  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(reference);
    final existing = snapshot.data() ?? <String, dynamic>{};
    final defaults = <String, dynamic>{
      'name': (name?.trim().isNotEmpty ?? false) ? name!.trim() : 'User',
      'email': email ?? '',
      'photoBase64': '',
    };
    defaults.removeWhere((key, value) => existing.containsKey(key));
    if (defaults.isNotEmpty) {
      if (snapshot.exists) {
        transaction.update(reference, defaults);
      } else {
        transaction.set(reference, defaults);
      }
    }
  });
}
