import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_profile.dart';
import '../maintenance/platform_notifications.dart' as reminders;

class AuthService {
  // Shared across service instances; initialise the native SDK only once.
  static Future<void>? _googleInitialization;
  static final googleSignInInProgress = ValueNotifier<bool>(false);

  Future<UserCredential?> signInWithGoogle() async {
    if (googleSignInInProgress.value) return null;
    googleSignInInProgress.value = true;
    UserCredential? result;
    try {
      if (kIsWeb) {
        // Start immediately from the click, without an await before the popup.
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        result = await _auth.signInWithPopup(provider);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        await (_googleInitialization ??= GoogleSignIn.instance.initialize());
        final account = await GoogleSignIn.instance.authenticate();
        final token = account.authentication.idToken;
        if (token == null) {
          throw FirebaseAuthException(code: 'missing-google-id-token');
        }
        result = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: token),
        );
      } else {
        throw FirebaseAuthException(code: 'unsupported-google-platform');
      }
      final user = result.user!;
      await ensureGoogleProfile(
        _firestore,
        uid: user.uid,
        name: user.displayName,
        email: user.email,
      );
      return result;
    } catch (error) {
      // Do not leave a partially initialised account in the app after a
      // profile write fails. The auth route stays open until this completes.
      if (result != null) await signOut();
      if (isGoogleSignInCancelled(error)) return null;
      rethrow;
    } finally {
      googleSignInInProgress.value = false;
    }
  }

  static bool isGoogleSignInCancelled(Object error) =>
      (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.canceled) ||
      (error is FirebaseAuthException &&
          [
            'popup-closed-by-user',
            'cancelled-popup-request',
            'web-context-cancelled',
          ].contains(error.code));

  static String googleSignInErrorMessage(Object error) {
    if (error is GoogleSignInException) {
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        return 'Google sign-in is not configured for this app yet. Please use email sign-in for now.';
      }
      return 'Google sign-in could not finish. Please try again.';
    }
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'popup-blocked' =>
          'Your browser blocked the Google window. Allow popups for this site and try again.',
        'unauthorized-domain' ||
        'operation-not-allowed' ||
        'configuration-not-found' =>
          'Google sign-in is not configured for this app yet. Please use email sign-in for now.',
        'account-exists-with-different-credential' =>
          'This email already uses another sign-in method. Sign in using that method first.',
        'network-request-failed' =>
          'Check your internet connection and try again.',
        'user-disabled' => 'This account is disabled. Please contact support.',
        'too-many-requests' =>
          'Too many attempts. Please wait a little and try again.',
        'unsupported-google-platform' =>
          'Google sign-in is available on Android and web.',
        _ => 'Google sign-in could not finish. Please try again.',
      };
    }
    if (error is FirebaseException && error.plugin == 'cloud_firestore') {
      return 'We could not prepare your account. Check your connection and try again.';
    }
    return 'Google sign-in could not finish. Please try again.';
  }

  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign in
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //sign up
  Future<UserCredential> signUpWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      //add user to firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'photoBase64': '', // empty until user uploads a photo
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  /// Change password in-app.
  /// Re-authenticates with [currentPassword], then updates to [newPassword].
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user signed in');
    }

    // Re-authenticate first (required by Firebase for sensitive operations)
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);

    // Now update the password
    await user.updatePassword(newPassword);
  }

  /// Current user's email (for sending reset link from settings).
  String? get currentUserEmail => _auth.currentUser?.email;

  //sign out
  Future<void> signOut() async {
    try {
      await reminders.clearNotifications();
    } catch (_) {
      /* Sign-out must remain available without platform plugins. */
    }
    await _auth.signOut();
    if (!kIsWeb && _googleInitialization != null) {
      try {
        await _googleInitialization;
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Firebase is already signed out, even if native cleanup fails.
      }
    }
  }

  //errors
}
