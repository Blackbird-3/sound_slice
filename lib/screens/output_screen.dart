import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sound_slice/util/utils.dart';

class SeparatedTracksPage extends StatefulWidget {
  final String songName;

  const SeparatedTracksPage({Key? key, required this.songName})
      : super(key: key);

  @override
  _SeparatedTracksPageState createState() => _SeparatedTracksPageState();
}

class _SeparatedTracksPageState extends State<SeparatedTracksPage> {
  late List<AudioPlayer> _audioPlayers;
  late List<String> _trackUrls;
  late List<double> _volumeValues = List.filled(4, 1.0);

  @override
  void initState() {
    super.initState();
    _initTracks();
    _initPlayers();
  }

  void _initTracks() {
    // Initialize track URLs based on the song name
    String userId = FirebaseAuth.instance.currentUser!.uid;
    String songName = widget.songName;

    _trackUrls = [
      'https://firebasestorage.googleapis.com/v0/b/sound-slice.appspot.com/o/users%2F$userId%2Faudio%2F$songName%2Fbass.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/sound-slice.appspot.com/o/users%2F$userId%2Faudio%2F$songName%2Fdrums.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/sound-slice.appspot.com/o/users%2F$userId%2Faudio%2F$songName%2Fother.mp3?alt=media',
      'https://firebasestorage.googleapis.com/v0/b/sound-slice.appspot.com/o/users%2F$userId%2Faudio%2F$songName%2Fvocals.mp3?alt=media',
    ];
  }

  void _initPlayers() {
    _audioPlayers = List.generate(
      _trackUrls.length,
      (index) => AudioPlayer(),
    );

    // Load and play each track
    for (int i = 0; i < _trackUrls.length; i++) {
      _audioPlayers[i].setUrl(_trackUrls[i], initialPosition: Duration.zero);
      _audioPlayers[i].setVolume(_volumeValues[i]);
      _audioPlayers[i].play();
    }
  }

  Future<void> _downloadTrack(String url) async {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final bytes = await consolidateHttpClientResponseBytes(response);

    final directory =
        await getExternalStorageDirectory(); // Use getExternalStorageDirectory for Android
    final file = File('${directory!.path}/track.mp3');
    print(file);
    await file.writeAsBytes(bytes);

    httpClient.close();
    showSnackBar('Track downloaded successfully!', context);
  }

  @override
  void dispose() {
    for (final player in _audioPlayers) {
      player.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.songName),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Volume bars
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildVolumeBar('Bass', 0),
                _buildVolumeBar('Drums', 1),
                _buildVolumeBar('Others', 2),
                _buildVolumeBar('Vocals', 3),
              ],
            ),
          ),
          // Playback controls

          // Seek bar
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(111, 37, 156, 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                StreamBuilder<Duration?>(
                  stream: _audioPlayers[0].durationStream,
                  builder: (context, snapshot) {
                    final duration = snapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration>(
                      stream: _audioPlayers[0].positionStream,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        return Slider(
                          value: position.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            // Pause all players
                            for (final player in _audioPlayers) {
                              player.pause();
                            }
                            // Seek all players to the selected position
                            for (final player in _audioPlayers) {
                              player
                                  .seek(Duration(milliseconds: value.toInt()));
                            }
                            // Resume playback for all players
                            for (final player in _audioPlayers) {
                              player.play();
                            }
                          },
                          min: 0,
                          max: duration.inMilliseconds.toDouble(),
                          activeColor: Colors.white, // Color of the thumb
                          inactiveColor: Colors.white30, // Color of the track
                        );
                      },
                    );
                  },
                ),
                IconButton(
                  onPressed: () async {
                    bool anyPlayerPlaying = _audioPlayers.any((player) => player
                        .playing); // Check if any player is already playing
                    if (anyPlayerPlaying) {
                      for (final player in _audioPlayers) {
                        await player.pause();
                      }
                    } else {
                      for (final player in _audioPlayers) {
                        await player.play();
                      }
                    }
                  },
                  icon: StreamBuilder<PlayerState>(
                    stream: _audioPlayers[0].playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        size: 36,
                        color: Colors.white,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeBar(String trackName, int index) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 2, 18, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trackName),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () async {
                  await _downloadTrack(_trackUrls[index]);
                },
                icon: const Icon(
                  Icons.download,
                ),
              ),
            ],
          ),
        ),
        Slider(
          value: _volumeValues[index],
          onChanged: (value) {
            setState(() {
              _volumeValues[index] = value;
            });
            _audioPlayers[index].setVolume(value);
          },
          min: 0,
          max: 1.0,
          divisions: 10,
        ),
      ],
    );
  }
}
