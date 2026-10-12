import 'dart:async';

import 'package:autometric_ai/auth/auth_service.dart';
import 'package:autometric_ai/auth/google_profile.dart';
import 'package:autometric_ai/components/account_dialog.dart';
import 'package:autometric_ai/components/google_sign_in_button.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  test(
    'New Google profiles use the existing rules-compatible schema',
    () async {
      final db = FakeFirebaseFirestore();
      await ensureGoogleProfile(
        db,
        uid: 'new',
        name: '  Ali  ',
        email: 'ali@example.com',
      );
      expect((await db.collection('users').doc('new').get()).data(), {
        'name': 'Ali',
        'email': 'ali@example.com',
        'photoBase64': '',
      });
    },
  );

  test('Repeat sign-in preserves profile and maintenance data', () async {
    final db = FakeFirebaseFirestore();
    final profile = db.collection('users').doc('existing');
    final data = {
      'name': 'Edited name',
      'email': 'ali@example.com',
      'photoBase64': 'saved-photo',
      'maintenanceVehicleCount': 2,
    };
    await profile.set(data);
    await profile.collection('evaluations').doc('prediction').set({
      'price': 100,
    });
    await ensureGoogleProfile(
      db,
      uid: 'existing',
      name: 'Google name',
      email: 'new@example.com',
    );
    expect((await profile.get()).data(), data);
    expect(
      (await profile.collection('evaluations').doc('prediction').get()).exists,
      isTrue,
    );
  });

  test(
    'Missing fields are repaired without overwriting existing fields',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('partial').set({'name': 'Keep me'});
      await ensureGoogleProfile(
        db,
        uid: 'partial',
        name: null,
        email: 'ali@example.com',
      );
      expect((await db.collection('users').doc('partial').get()).data(), {
        'name': 'Keep me',
        'email': 'ali@example.com',
        'photoBase64': '',
      });
    },
  );

  test('Cancellation and configuration errors are handled explicitly', () {
    expect(
      AuthService.isGoogleSignInCancelled(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      ),
      isTrue,
    );
    expect(
      AuthService.isGoogleSignInCancelled(
        FirebaseAuthException(code: 'popup-closed-by-user'),
      ),
      isTrue,
    );
    expect(
      AuthService.googleSignInErrorMessage(
        FirebaseAuthException(code: 'popup-blocked'),
      ),
      contains('Allow popups'),
    );
    expect(
      AuthService.googleSignInErrorMessage(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      ),
      contains('not configured'),
    );
    expect(
      AuthService.googleSignInErrorMessage(
        FirebaseAuthException(code: 'account-exists-with-different-credential'),
      ),
      contains('another sign-in method'),
    );
  });

  testWidgets('Google action shows progress and prevents duplicate requests', (
    tester,
  ) async {
    final completion = Completer<void>();
    final busy = <bool>[];
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoogleSignInButton(
            enabled: true,
            onBusyChanged: busy.add,
            authenticate: () {
              calls++;
              return completion.future;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('Continue with Google'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Signing in…'));
    expect(calls, 1);
    completion.complete();
    await tester.pumpAndSettle();
    expect(busy, [true, false]);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('Cancel is quiet, failures use the consistent account dialog', (
    tester,
  ) async {
    Future<void> pumpFailure(Object error) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GoogleSignInButton(
              key: UniqueKey(),
              enabled: true,
              onBusyChanged: (_) {},
              authenticate: () async => throw error,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Continue with Google'));
      await tester.pumpAndSettle();
    }

    await pumpFailure(FirebaseAuthException(code: 'popup-closed-by-user'));
    expect(find.byType(AccountDialog), findsNothing);
    await pumpFailure(FirebaseAuthException(code: 'popup-blocked'));
    expect(find.byType(AccountDialog), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
