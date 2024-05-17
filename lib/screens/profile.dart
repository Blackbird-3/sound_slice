import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sound_slice/responsive/mobile_screen.dart';
import 'package:sound_slice/screens/login_screen.dart';
import 'package:sound_slice/util/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String name = "";
  late String email = "";
  DateTime? _selectedDate;

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
        centerTitle: true, // Center the title in the app bar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MobileScreenLayout(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display profile picture
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/prof.jpg'),
              ),

              SizedBox(height: 20),
              // Display user's name
              _buildProfileField(
                label: 'Name',
                value: name,
                onTap: () {
                  // Add functionality to set date of birth
                },
              ),
              SizedBox(height: 10),
              // Display user's email
              _buildProfileField(
                label: 'Email',
                value: email,
                onTap: () {
                  // Add functionality to set date of birth
                },
              ),
              SizedBox(height: 20),
              // Display date of birth
              _buildProfileField(
                label: 'Date of Birth',
                // ignore: unnecessary_null_comparison
                value: _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : 'Tap to set',
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),

              SizedBox(height: 10),
              // Display skills
              _buildProfileField(
                label: 'Skills',
                value: 'Tap to add skills',
                onTap: () async {
                  final selectedSkills = await showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      List<String> selectedSkills = [];
                      return SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildSkillTile('Guitar', selectedSkills),
                            _buildSkillTile('Drums', selectedSkills),
                            _buildSkillTile('Vocals', selectedSkills),
                            _buildSkillTile('Turntable', selectedSkills),
                            _buildSkillTile('Keys', selectedSkills),
                            // Add more skill options as needed
                          ],
                        ),
                      );
                    },
                  );

                  // Handle selected skills here
                  if (selectedSkills != null) {
                    print('Selected Skills: $selectedSkills');
                    // Add code to handle selected skills here
                  }
                },
              ),
              SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(value),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTile(String skill, List<String> selectedSkills) {
    final isSelected = selectedSkills.contains(skill);
    return ListTile(
      title: Text(skill, textAlign: TextAlign.center,),
      onTap: () {
        print('$skill selected');
        setState(() {
          if (isSelected) {
            selectedSkills.remove(skill);
          } else {
            selectedSkills.add(skill);
            print(selectedSkills);
          }
        });
      },
      tileColor: isSelected ? Colors.blue.withOpacity(0.5) : null,
    );
  }
}
