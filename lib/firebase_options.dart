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
    apiKey: 'AIzaSyDCdLYZo_LqNd3IQ893RcytXMXZ1w63OJw',
    appId: '1:214887335570:web:daded4d95f87d93f8ac84b',
    messagingSenderId: '214887335570',
    projectId: 'circle-up-9a9a1',
    authDomain: 'circle-up-9a9a1.firebaseapp.com',
    storageBucket: 'circle-up-9a9a1.firebasestorage.app',
    measurementId: 'G-HM3MGJTQ8P',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARTs5nmiyXlGvqSFAlHgu6EW6Fj8-efXs',
    appId: '1:214887335570:android:13ee37cb9f84bc778ac84b',
    messagingSenderId: '214887335570',
    projectId: 'circle-up-9a9a1',
    storageBucket: 'circle-up-9a9a1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9z4onB_oTeWH5fsvqG212-UBVisNN-iU',
    appId: '1:214887335570:ios:2fc8b4bf35162e998ac84b',
    messagingSenderId: '214887335570',
    projectId: 'circle-up-9a9a1',
    storageBucket: 'circle-up-9a9a1.firebasestorage.app',
    iosBundleId: 'com.example.circleup',
  );
}
