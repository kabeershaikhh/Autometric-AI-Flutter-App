# Google sign-in setup (Android + web)

The login and registration Google buttons share one Firebase authentication flow.
Web uses Firebase's Google popup; Android uses the official Google Sign-In SDK
and exchanges its ID token with Firebase. No paid backend or new Firestore
collections are required. Existing profile edits and saved records are preserved.

## Required Firebase setup

1. Open the **autometric-ai** Firebase project → Authentication → Sign-in method.
   Enable **Google**, choose the project's support email, and save.
2. Project settings → Android app **com.example.autometric_ai**: register the
   SHA-1 and SHA-256 fingerprints of the certificate signing your APK.
   For local testing, use the debug certificate. For distribution, also register
   the actual release/Play App Signing certificate. Do not ship with debug signing.
   `android/app/build.gradle.kts` currently signs release builds with the debug key.
3. Download the updated **google-services.json** and replace
   `android/app/google-services.json`. The current file has an empty `oauth_client`
   array and cannot configure Android Google sign-in. The updated file should
   include the web OAuth client (`client_type: 3`) and Android OAuth registration.
   Do not invent or manually copy a client ID from another project.
4. Authentication → Settings → Authorized domains: add your deployed web hostname
   and **localhost** for local Chrome testing. Use HTTPS in production. If using
   **127.0.0.1**, authorise that host too, or open the app through localhost.
5. Stop the app and rebuild after replacing Android configuration. Hot reload is
   not enough to register the native plugin/configuration.

To print local debug certificate fingerprints in PowerShell (with Java installed):

```powershell
keytool -list -v -alias androiddebugkey -keystore "$env:USERPROFILE\.android\debug.keystore" -storepass android -keypass android
```

Verified fingerprints for this computer's current debug certificate:

```text
SHA-1:   FC:F8:CC:57:B9:82:65:3C:E2:15:3F:E5:EF:8A:5F:94:10:49:7B:8C
SHA-256: 31:93:B3:4D:6E:C3:60:30:BF:C4:F0:65:4F:A2:29:D1:47:84:5E:6F:F1:84:19:01:5A:D1:4F:D3:F1:4E:65:F7
```

These identify only local debug builds. Recheck if the keystore changes.

## Verify with real accounts

- Android: test on a physical device/emulator with Google Play services.
- Web: allow popups, click Google directly, select an account, and check home opens.
- First sign-in should create `users/{uid}` with name, email and empty photoBase64.
- Repeat sign-in should preserve edited name/photo, evaluations and maintenance.
- Cancel the chooser/popup: remain on login without an error or stuck spinner.
- Log out and sign in using another Google account: verify account selection.
- Try an existing email/password account: verify Firebase's same-email behaviour;
  if it returns an account conflict, the app requests the original sign-in method.
  Credentials are not automatically linked without proving ownership.
- Check blocked popups, offline sign-in, and disabled Google provider errors.

The Google profile photo is not downloaded or stored; the existing profile-photo
feature remains independent. No extra Google API scopes are requested.

References:
- https://firebase.google.com/docs/auth/flutter/federated-auth
- https://pub.dev/packages/google_sign_in_android
