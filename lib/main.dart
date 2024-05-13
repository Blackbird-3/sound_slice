import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sound_slice/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBfxMEtwXZUdDOx4Qot6LAIe8Zb-l2GvtE",
          appId: "1:853700695890:web:0935c7585411478a4a8c8b",
          messagingSenderId: "853700695890",
          projectId: "sound-slice",
          storageBucket: 'sound-slice.appspot.com'),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sound Slice',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: SplashScreen(),
    );
  }
}
