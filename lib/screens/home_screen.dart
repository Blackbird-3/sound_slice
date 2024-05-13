import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sound_slice/model/api.dart';
import 'package:sound_slice/util/colors.dart';
import 'package:sound_slice/util/utils.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  State<Upload> createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  String name = "";
  String uid = "";
  final AudioPlayer _player = AudioPlayer();
  PlatformFile? file;

  void getName() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    setState(() {
      name = (snap.data() as Map<String, dynamic>)['name'];
      uid = FirebaseAuth.instance.currentUser!.uid;
    });
  }

  String? selectedSongName;
  late String selectedSongPath;

  Future<void> pickAudio() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null) {
        PlatformFile selectedFile = result.files.first;
        // You can now use the selected file
        print('File path: ${selectedFile.path}');
        print('File name: ${selectedFile.name}');
        print('File size: ${selectedFile.size}');

        setState(() {
          file = selectedFile;
          selectedSongName = selectedFile.name;
          selectedSongPath = selectedFile.path!;

          print('File saved now');
        });

        await _player.setFilePath((file!.path).toString());
        _player.play();
        // Handle the file as needed, such as uploading it to a server or processing it
      } else {
        // User canceled the file picker
      }
    } catch (e) {
      // Handle any exceptions
      print('Error picking file: $e');
    }
  }

  void saveToCloud() async {
    try {
      if (file != null) {
        // Get the currently authenticated user's UID
        String uid = FirebaseAuth.instance.currentUser!.uid;

        // Define the file path using the user's UID and the file name
        String filePath = 'users/$uid/audio/$selectedSongName';

        // Upload the file to Firebase Storage
        Reference ref = FirebaseStorage.instance.ref().child(filePath);
        UploadTask uploadTask = ref.putFile(File(selectedSongPath));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        // Get the download URL of the uploaded file
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Print or use the download URL as needed
        print('File uploaded successfully. Download URL: $downloadUrl');
        showSnackBar('Song uploaded succesfully', context);

        // Call the function to send the file URL to the API
        // await sendFileToApi(downloadUrl);
        try {
          // Call the function to send the file URL to the API
          processAudio(downloadUrl , selectedSongName!);

          // Now you can use the separatedTracks data as needed, such as updating the UI
          // print('Separated tracks: $separatedTracksId');

          // Navigate to the page where you can see the separated tracks
          // (Assuming you have a function to navigate to that page)
          // navigateToSeparatedTracksPage();
        } catch (e) {
          print('Error saving to cloud: $e');
        }
      } else {
        // Handle the case where no file is selected
        print('No file selected.');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  void dispose() {
    super.dispose();
    _player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Hello, $name.',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: pickAudio,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color.fromRGBO(111, 37, 156, 1),
                        Color.fromARGB(255, 172, 128, 214),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        '''Upload your
      Audio''',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10.0),
                      Icon(
                        Icons.upload_file,
                        color: Colors.white,
                        size: 40,
                      ),
                      SizedBox(width: 10.0),
                      Image.asset(
                        'assets/upload_icon.png',
                        height: 140,
                        width: 140,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            if (selectedSongName != null)
              Text(
                'Selected Song: $selectedSongName',
                style: TextStyle(fontSize: 16.0),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _player.duration ?? Duration.zero;
                  return ProgressBar(
                    progress: position,
                    total: duration,
                    onSeek: (duration) {
                      _player.seek(duration);
                    },
                  );
                },
              ),
            ),
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final playing = playbackState?.playing ?? false;
                return ElevatedButton(
                  onPressed: () async {
                    if (playing) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                  },
                  child: Icon(
                    playing ? Icons.pause : Icons.play_arrow,
                    size: 36,
                    color: secondaryColor,
                  ),
                );
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                saveToCloud();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor, // Background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Rounded corners
                ),
                // shadowColor: Colors.grey[500],
                
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Save and Separate',
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





// class Upload extends StatefulWidget {
//   const Upload({Key? key});

//   @override
//   State<Upload> createState() => _UploadState();
// }

// class _UploadState extends State<Upload> {
//   String? selectedSongName;
//   final AudioPlayer _player = AudioPlayer();

//   Future<void> pickAudio() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.audio,
//         allowMultiple:
//             false, // Set to true if you want to allow multiple file selection
//       );
//       if (result != null) {
//         PlatformFile? file = result.files.firstOrNull;
//         if (file != null) {
//           // You can now use the selected file
//           print('File path: ${file.path}');
//           print('File name: ${file.name}');
//           print('File size: ${file.size}');

//           setState(() {
//             selectedSongName = file.name;
//           });

//           // Load and play the selected audio file
//           await _player.setFilePath((file.path).toString());
//           _player.play();
//         }
//       } else {
//         // User canceled the file picker
//       }
//     } catch (e) {
//       // Handle any exceptions
//       print('Error picking file: $e');
//     }
//   }
// @override
// void dispose() {
//   super.dispose();
//   _player.dispose();
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GestureDetector(
//                 onTap: pickAudio,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.centerLeft,
//                       end: Alignment.centerRight,
//                       colors: [
//                         const Color.fromRGBO(111, 37, 156, 1),
//                         Color.fromARGB(255, 172, 128, 214),
//                       ],
//                     ),
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 20.0, vertical: 10.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Text(
//                         'Upload your Audio',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(width: 10.0),
//                       Icon(
//                         Icons.upload_file,
//                         color: Colors.white,
//                         size: 40,
//                       ),
//                       SizedBox(width: 10.0),
//                       Image.asset(
//                         'assets/upload_icon.png',
//                         height: 140,
//                         width: 140,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             // ElevatedButton(
//             //   onPressed: () {
//             //     pickAudio();
//             //   },
//             //   child: Text('Select Song'),
//             // ),
//             SizedBox(height: 20.0),
//             if (selectedSongName != null)
//               Text(
//                 'Selected Song: $selectedSongName',
//                 style: TextStyle(fontSize: 16.0),
//               ),
//             const SizedBox(height: 20.0),
//             ElevatedButton(
//               onPressed: () {
//                 // Implement functionality to save to cloud
//               },
//               child: Text('Save to Cloud'),
//             ),
//              StreamBuilder<Duration>(
//               stream: _player.positionStream,
//               builder: (context, snapshot) {
//                 final position = snapshot.data ?? Duration.zero;
//                 final duration = _player.duration ?? Duration.zero;
//                 return ProgressBar(
//                   progress: position,
//                   total: duration,
//                   onSeek: (duration) {
//                     _player.seek(duration);
//                   },
//                 );
//               },
//             ),
//             StreamBuilder<PlayerState>(
//               stream: _player.playerStateStream,
//               builder: (context, snapshot) {
//                 final playbackState = snapshot.data;
//                 final playing = playbackState?.playing ?? false;
//                 return ElevatedButton(
//                   onPressed: () async {
//                     if (playing) {
//                       await _player.pause();
//                     } else {
//                       await _player.play();
//                     }
//                   },
//                   child: Text(playing ? 'Pause' : 'Play'),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
