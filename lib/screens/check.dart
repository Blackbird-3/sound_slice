import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sound_slice/responsive/mobile_screen.dart';
import 'package:sound_slice/responsive/responsive_layout_screen.dart';
import 'package:sound_slice/responsive/web_screen.dart';
import 'package:sound_slice/screens/signup_screen.dart';




class Check extends StatelessWidget {
  const Check({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context , snapshot){
        if(snapshot.hasData){
          return const ResponsiveLayout(
            mobileScreenLayout: MobileScreenLayout(),
            webScreenLayout: WebScreenLayout(),
          );
        }
        else{
          return SignUpScreen();
        }
      },),
    );
  }
}