// File manually updated for Android + Web
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: 'AIzaSyAm1PC-IbPGjOhTuxeO_08qmBYwqfogmfM',
        authDomain: 'teenpay-540cc.firebaseapp.com',
        projectId: 'teenpay-540cc',
        storageBucket: 'teenpay-540cc.appspot.com',
        messagingSenderId: '575284237551',
        appId: '1:575284237551:web:55de4e41d22a07b579b71a', // Web App ID
        measurementId: 'G-TEENPAY123', // Example Measurement ID
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'reconfigure using FlutterFire CLI.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'reconfigure using FlutterFire CLI.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'reconfigure using FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'reconfigure using FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAm1PC-IbPGjOhTuxeO_08qmBYwqfogmfM',
    appId: '1:575284237551:android:55de4e41d22a07b579b71a',
    messagingSenderId: '575284237551',
    projectId: 'teenpay-540cc',
    storageBucket: 'teenpay-540cc.firebasestorage.app',
  );
}
