import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sound_slice/screens/output_screen.dart';

class MyFiles extends StatefulWidget {
  const MyFiles({Key? key}) : super(key: key);

  @override
  _MyFilesState createState() => _MyFilesState();
}

class _MyFilesState extends State<MyFiles> {
  late Future<List<String>> _uploadedFiles;

  @override
  void initState() {
    super.initState();
    _fetchFiles();
  }

  Future<void> _fetchFiles() async {
    setState(() {
      _uploadedFiles = fetchUploadedFiles();
    });
  }

  Future<List<String>> fetchUploadedFiles() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final List<String> fileNames = [];

      // Reference to the user's audio folder
      Reference audioRef =
          FirebaseStorage.instance.ref().child('users/$userId/audio');

      // List all items (files) in the audio folder
      ListResult result = await audioRef.listAll();

      // Iterate over each item (file) and add its name to the list
      result.items.forEach((Reference ref) {
        fileNames.add(ref.name);
      });

      return fileNames;
    } catch (e) {
      print('Error fetching uploaded files: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Files'),
        actions: [
          IconButton(
            onPressed: _fetchFiles,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _uploadedFiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final files = snapshot.data ?? [];
            if (files.isEmpty) {
            return Center(child: Text('No files yet'));
          }
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final songName = files[index];
                return ListTile(
                  title: Text(songName),
                  onTap: () {
                    // Navigate to SeparatedTracksPage when a song is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SeparatedTracksPage(songName: songName),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
