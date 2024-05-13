import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sound_slice/screens/login_screen.dart';
import 'package:sound_slice/util/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageeState();
}

class _ProfilePageeState extends State<ProfilePage> {
  late String name = "";
  late String email = "";

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> getName() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['name'];
      email = FirebaseAuth.instance.currentUser!.email!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display user's name
            Text(
              'Hello, $name!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            // Display user's email
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 150),
            // Add more widgets to display other user information

            // Logout button
            ElevatedButton(
              onPressed: () {
                // Sign out the user
                FirebaseAuth.instance.signOut();

                // Navigate back to the login page
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Rounded corners
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
