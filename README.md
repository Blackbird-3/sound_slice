# Sound Slice

Sound Slice is a Flutter application that allows users to upload audio files, process them using an external API, and store the separated audio tracks in Firebase Storage. The app also provides user authentication and displays notifications when processing is complete.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Firebase Setup](#firebase-setup)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Features

- User authentication with Firebase Auth
- Upload audio files and process them using an external API
- Store separated audio tracks in Firebase Storage
- Display notifications to users when processing is complete
- Responsive design for mobile devices

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Firebase account: [Create a Firebase account](https://firebase.google.com/)
- API access to the external audio processing service (Replicate API)

### Installation

1. Clone the repository:

    ```sh
    git clone https://github.com/your-username/sound-slice.git
    cd sound-slice
    ```

2. Install the dependencies:

    ```sh
    flutter pub get
    ```

### Firebase Setup

1. Create a new project in the [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app to your Firebase project and download the `google-services.json` file. Place this file in the `android/app` directory.
3. Add an iOS app to your Firebase project and download the `GoogleService-Info.plist` file. Place this file in the `ios/Runner` directory.
4. Enable the following Firebase services:
   - Authentication
   - Firestore
   - Storage

5. Update the Firebase configuration in your `pubspec.yaml`:

    ```yaml
    dependencies:
      firebase_core: latest_version
      firebase_auth: latest_version
      cloud_firestore: latest_version
      firebase_storage: latest_version
      firebase_messaging: latest_version
    ```

### Replicate API Setup

1. Sign up for the [Replicate API](https://replicate.com/).
2. Generate an API token.
3. Update the API token in your code:

    ```dart
    const String replicateApiToken = 'your_replicate_api_token';
    ```

## Usage

1. Run the app on an emulator or connected device:

    ```sh
    flutter run
    ```

2. Sign up or log in using the Firebase authentication system.
3. Upload an audio file to be processed.
4. Wait for the processing to complete. Once done, the separated audio tracks will be stored in Firebase Storage, and a notification will be displayed.

## Contributing

Contributions are welcome! Please read the [contributing guidelines](CONTRIBUTING.md) for more details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

