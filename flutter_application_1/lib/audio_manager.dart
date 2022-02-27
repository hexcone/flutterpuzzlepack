import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/globals.dart' as globals;

class AudioManager extends StatelessWidget {
  final Widget child;
  const AudioManager({required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          AudioPlayerWidget(),
        ],
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  const AudioPlayerWidget({Key? key}) : super(key: key);

  @override
  _AudioPlayerState createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayerWidget> {
  AudioPlayer? advancedPlayer;
  AudioCache? player;
  double DEFAULT_VOLUME = 0.5;

  @override
  void initState() {
    super.initState();
    globals.audioEnabled = true;
    print("play bg music");
    advancedPlayer = AudioPlayer();
    player = AudioCache(fixedPlayer: advancedPlayer);
    player!.loop("audio/NatureSample.mp3"); //https://www.ashamaluevmusic.com/ambient-music
    advancedPlayer!.setVolume(DEFAULT_VOLUME);
  }

  Widget buildAudioButton() {
    if(globals.audioEnabled) {
      advancedPlayer!.setVolume(DEFAULT_VOLUME);
      return Container(
            height: 50,
            width: 50,
            color: Color.fromARGB(255, 75, 6, 236),
          );
    } else{
      advancedPlayer!.setVolume(0);
      return Container(
            height: 50,
            width: 50,
            color: Color.fromARGB(255, 1, 0, 2),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    //return audio button here to overlay unto screen
    return 
      GestureDetector(
        onTapDown: (_) {
          setState(() {
            globals.audioEnabled = !globals.audioEnabled;
          });
        },
        child: buildAudioButton(),
          
      );
    
  }
}