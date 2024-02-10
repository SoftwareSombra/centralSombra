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
    apiKey: 'AIzaSyDir6pzZi6Kr5504YEOgCLsb-mgQ3kL1wE',
    appId: '1:194427576619:web:5f60071d3993090b37a56e',
    messagingSenderId: '194427576619',
    projectId: 'sombratestes',
    authDomain: 'sombratestes.firebaseapp.com',
    storageBucket: 'sombratestes.appspot.com',
    measurementId: 'G-YZP0TT3JPQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIfc0TzkMF1BnQJ4xuCgOwyClOD6cKIME',
    appId: '1:194427576619:android:db125b3f5df8fe0437a56e',
    messagingSenderId: '194427576619',
    projectId: 'sombratestes',
    storageBucket: 'sombratestes.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_70a7gTPxk2u2Rz6mFnXdbKRWG8ar8g4',
    appId: '1:194427576619:ios:0659b3b00a6cfc6a37a56e',
    messagingSenderId: '194427576619',
    projectId: 'sombratestes',
    storageBucket: 'sombratestes.appspot.com',
    iosBundleId: 'com.example.sombraTestes',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD_70a7gTPxk2u2Rz6mFnXdbKRWG8ar8g4',
    appId: '1:194427576619:ios:f3c7c059db7484f737a56e',
    messagingSenderId: '194427576619',
    projectId: 'sombratestes',
    storageBucket: 'sombratestes.appspot.com',
    iosBundleId: 'com.example.sombraTestes.RunnerTests',
  );
}