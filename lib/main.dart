import 'package:flutter/material.dart';
import 'package:sound_slice/responsive/mobile_screen.dart';
import 'package:sound_slice/responsive/responsive_layout_screen.dart';
import 'package:sound_slice/responsive/web_screen.dart';

void main() {
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
      home: const ResponsiveLayout(
        mobileScreenLayout: MobileScreenLayout(),
        webScreenLayout: WebScreenLayout(),
      ),
    );
  }
}
