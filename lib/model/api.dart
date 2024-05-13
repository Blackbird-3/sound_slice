import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://api.replicate.com/v1/predictions';
const String replicateApiToken = 'r8_UOGrwZElTeaG9kL0S40gAuG5ohDS0Ly1OtLzj';


Future<String> fetchSeparatedTracks(String audioUrl, String songName) async {
  final Map<String, dynamic> requestData = {
    "version":
        "25a173108cff36ef9f80f854c162d01df9e6528be175794b81158fa03836d953",
    "input": {
      "audio": audioUrl,
    },
  };

  final http.Response response = await http.post(
    Uri.parse(apiUrl),
    headers: <String, String>{
      'Authorization': 'Bearer $replicateApiToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestData),
  );

  if (response.statusCode == 201) {
    final Map<String, dynamic> responseData = jsonDecode(response.body);
    print(responseData);
    return responseData['id'];
  } else {
    throw Exception('Failed to start processing : ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> checkStatusAndGetResults(
    String predictionId) async {
  final String url = '$apiUrl/$predictionId';
  final response = await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Authorization': 'Bearer $replicateApiToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  } else {
    throw Exception('Failed to get prediction status: ${response.statusCode}');
  }
}

void processAudio(String audioUrl, String songName) async {
  try {
    // Start processing audio and get the prediction ID
    String predictionId = await fetchSeparatedTracks(audioUrl, songName);

    // Check the status periodically until it's 'succeeded' or 'failed'
    String status = 'starting';
    while (status == 'starting' || status == 'processing') {
      // Check status and get results
      Map<String, dynamic> result =
          await checkStatusAndGetResults(predictionId);

      // Update status
      status = result['status'];

      if (status == 'starting' || status == 'processing') {
        // Sleep for some time before checking again (e.g., 5 seconds)
        await Future.delayed(Duration(seconds: 5));
      } else if (status == 'succeeded') {
        // Process succeeded, get separated audio URLs
        Map<String, dynamic> separatedAudioUrls = result['output'];

        // Convert dynamic values to strings
        Map<String, String> separatedAudioUrlsString = {};
        separatedAudioUrls.forEach((key, value) {
          separatedAudioUrlsString[key] = value.toString();
        });

        String uid = FirebaseAuth.instance.currentUser!.uid;
        String filePath = 'users/$uid/audio/$songName';

        storeSeparatedAudioUrlsInFirebase(separatedAudioUrlsString, filePath);
        // Handle the separated audio URLs (e.g., display them in your app)
        print('Separated audio URLs: $separatedAudioUrlsString');
      } else {
        print(status);
        // Process failed
        String errorMessage = result['error'] ?? 'Unknown error';
        print('Processing failed: $errorMessage');
        // You can provide feedback to the user or log additional details here
        // For example: show an error message in your app interface
        break; // Exit the loop if processing fails
      }
    }
  } catch (e) {
    // Handle any errors
    print('Error processing audio: $e');
  }
}


// Function to store the separated audio URLs in Firebase Storage
Future<void> storeSeparatedAudioUrlsInFirebase(Map<String, String?> separatedAudioUrls, String parentFilePath) async {
  try {
    // Extract URLs for bass, drums, other, and vocals
    String? bassUrl = separatedAudioUrls['bass'];
    String? drumsUrl = separatedAudioUrls['drums'];
    String? otherUrl = separatedAudioUrls['other'];
    String? vocalsUrl = separatedAudioUrls['vocals'];

    // Create a list of URLs to process
    List<String?> urlsToProcess = [bassUrl, drumsUrl, otherUrl, vocalsUrl];

    // Iterate over the URLs and store them in Firebase Storage
    await Future.forEach(urlsToProcess.where((url) => url != null), (url) async {
      // Download the audio file
      http.Response response = await http.get(Uri.parse(url!));
      Uint8List bytes = Uint8List.fromList(response.bodyBytes);

      // Extract the filename from the URL
      String filename = url.split('/').last;

      // Construct the file path in Firebase Storage
      String filePath = '$parentFilePath/$filename';

      // Upload the audio file to Firebase Storage
      try {
        Reference ref = FirebaseStorage.instance.ref().child(filePath);
        UploadTask uploadTask = ref.putData(bytes);
        await uploadTask.whenComplete(() => null);

        print('File uploaded successfully to $filePath');
      } catch (e) {
        print('Error uploading file to Firebase Storage: $e');
        // Handle any errors during upload
      }
    });
  } catch (e) {
    print('Error storing separated audio URLs in Firebase Storage: $e');
    // Handle any errors
  }
}


// Usage:
// try {
//   // Output from the API
//   Map<String, String?> separatedAudioUrls = {
//     'bass': 'https://replicate.delivery/pbxt/IqYe9MJsZ5QxAKCVLK9Hr8ygKAWenqbUwfoif45fHbko67aWC/bass.mp3',
//     'drums': 'https://replicate.delivery/pbxt/PbVw5azGetVZCqS6DadBVp0Fao6R4W58tVHUN5ftqmrVfumlA/drums.mp3',
//     'guitar': null,
//     'other': 'https://replicate.delivery/pbxt/vfAmVtZRFayxaqJV66nTfqVyV2GkUsHaLz0Poe2J2oQqedNLB/other.mp3',
//     'piano': null,
//     'vocals': 'https://replicate.delivery/pbxt/f0XTspZRzQ1GFi8QAryORH7wvM43UWVdbTsxRdD0I7UqvrZJA/vocals.mp3'
//   };

//   // Parent file path where the separated audio files will be stored in Firebase Storage
//   String parentFilePath = 'parent/audio/file/path'; // Change this to your desired parent file path

//   // Call the function to store the separated audio URLs in Firebase Storage
//   await storeSeparatedAudioUrlsInFirebase(separatedAudioUrls, parentFilePath);
// } catch (e) {
//   print('Error processing separated audio URLs: $e');
//   // Handle any errors
// }
