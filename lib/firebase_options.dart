// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAW5qm9ren3OiCe-DwB39xyIASm9Y9O2e8',
    appId: '1:71668901237:web:5aec1727267d30aeb41f3c',
    messagingSenderId: '71668901237',
    projectId: 'cau-appdev',
    authDomain: 'cau-appdev.firebaseapp.com',
    storageBucket: 'cau-appdev.appspot.com',
    measurementId: 'G-71ZMGN84EK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-DbIcr-Q4Gss9Jk2apcqaFgX6hwcqtOs',
    appId: '1:71668901237:android:2e7bbca8adbbde33b41f3c',
    messagingSenderId: '71668901237',
    projectId: 'cau-appdev',
    storageBucket: 'cau-appdev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2db1pcOo6CLvDsLNFl5f3b-7d8giBXT8',
    appId: '1:71668901237:ios:4006b5d2167ce7adb41f3c',
    messagingSenderId: '71668901237',
    projectId: 'cau-appdev',
    storageBucket: 'cau-appdev.appspot.com',
    iosBundleId: 'com.example.mediMinder',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2db1pcOo6CLvDsLNFl5f3b-7d8giBXT8',
    appId: '1:71668901237:ios:b6b76cd9151d078cb41f3c',
    messagingSenderId: '71668901237',
    projectId: 'cau-appdev',
    storageBucket: 'cau-appdev.appspot.com',
    iosBundleId: 'com.example.mediMinder.RunnerTests',
  );
}