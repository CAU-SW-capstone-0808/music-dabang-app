// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDu6owOJ3nUxtLNy_LawwlVNVAnJ3czpl8',
    appId: '1:801280844051:web:ecd99ef34ff5e3e069fae6',
    messagingSenderId: '801280844051',
    projectId: 'music-dabang',
    authDomain: 'music-dabang.firebaseapp.com',
    storageBucket: 'music-dabang.appspot.com',
    measurementId: 'G-HLG3QPYSC3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0SItfL4xp9Zn3o_a_qTDjebU_renpeB0',
    appId: '1:801280844051:android:b3ec9abcb45d302569fae6',
    messagingSenderId: '801280844051',
    projectId: 'music-dabang',
    storageBucket: 'music-dabang.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCg4Qm80lMv4oLqKsCqLsIFks00l6q0q80',
    appId: '1:801280844051:ios:bbc5da3ad5e5203a69fae6',
    messagingSenderId: '801280844051',
    projectId: 'music-dabang',
    storageBucket: 'music-dabang.appspot.com',
    iosBundleId: 'com.anarchyadventure.musicDabang',
  );
}
