import 'package:flutter/material.dart';
import 'package:sound_slice/screens/files.dart';
import 'package:sound_slice/screens/home_screen.dart';
import 'package:sound_slice/screens/profile.dart';

const webscreenSize = 600;


List<Widget> homeScreenItems = [
  const Upload(),
  const MyFiles(),
  ProfilePage(),
];