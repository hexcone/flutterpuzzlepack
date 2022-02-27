import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flutter_application_1/globals.dart' as globals;
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

class NavManager extends StatelessWidget {
  final Widget child;
  const NavManager({required this.child});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          child,
          NavWidget(),
        ],
      ),
    );
  }
}

class NavWidget extends StatefulWidget {
  const NavWidget({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<NavWidget> {
  double DEFAULT_VOLUME = 0.5;
  late AudioPlayer _audioPlayer;

  Artboard? _riveArtboardLogo;
  Artboard? _riveArtboardHome;
  Artboard? _riveArtboardAudio;
  StateMachineController? _audioController;
  SMIInput<bool>? _audioInput;
  SMIInput<bool>? _hoverInput;

  @override
  void initState() {
    super.initState();

    // logo
    rootBundle.load('assets/nav/logo.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = SimpleAnimation('Animation 1');
        if (controller != null) {
          artboard.addController(controller);
        }
        setState(() => _riveArtboardLogo = artboard);
      },
    );

    // home
    rootBundle.load('assets/nav/home.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller;
        artboard.addController(controller = SimpleAnimation('idle'));
        setState(() => _riveArtboardHome = artboard);
      },
    );

    globals.audioEnabled = false;
    if(!kIsWeb) {
      globals.audioEnabled = true;
    }
    _initAudioPlayer();

    // handle audio
    rootBundle.load('assets/nav/audio.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller =
        StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
          _audioInput = controller.findInput('audio');
          _hoverInput = controller.findInput('hover');
        }
        if (globals.audioEnabled) {
          _audioInput?.value = true;
        } else {
          _audioInput?.value = false;
        }
        setState(() => _riveArtboardAudio = artboard);
      },
    );

  }

  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setAsset("assets/audio/NatureSample.mp3");
    await _audioPlayer.setLoopMode(LoopMode.all);
    if(globals.audioEnabled) {
      _audioPlayer.play();
    }
  }

  String getCreditsString() {
    List<String> credits = [];
    credits.add("Developers");
    credits.add("--------------------------------------");
    credits.add("Juliana Seng (Hexcone)");
    credits.add("Brandon Tan (BrandonTJS)");
    credits.add("\n");
    credits.add("Resources");
    credits.add("--------------------------------------");
    credits.add("Background Music: AShamaluevMusic - https://www.ashamaluevmusic.com/");
    credits.add("Tile Sound Effects: \"Extra bonus in a video game\" - https://mixkit.co/");

    String ret = "";
    for(int i=0;i<credits.length;i++){
      ret += credits[i] + "\n";
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    var controller;
    //return audio button here to overlay unto screen
    return
      Container(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              child: 
              GestureDetector(
                onTapDown: (_) {
                  Get.defaultDialog(
                    title: "Credits",
                    middleText: getCreditsString(),
                    //backgroundColor: Colors.green,
                    //titleStyle: TextStyle(color: Colors.white),
                    //middleTextStyle: TextStyle(color: Colors.white),

                  );
                },
                child: _riveArtboardLogo == null
                        ? const SizedBox()
                        : Container(
                      child: Rive(
                        fit: BoxFit.contain,
                        artboard: _riveArtboardLogo!,
                      ),
                    ),
              ),
            ),
            _riveArtboardHome == null
                ? const SizedBox()
                : MouseRegion(
              onEnter: (_) {
                _riveArtboardHome!.addController(controller = SimpleAnimation('active'));
              },
              onExit: (_) {
                _riveArtboardHome!.addController(controller = SimpleAnimation('idle'));
              },
              child: GestureDetector(
                onTapDown: (_) {
                  Get.toNamed("/");
                },
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Rive(
                    artboard: _riveArtboardHome!,
                  ),
                ),
              ),
            ),
            _riveArtboardAudio == null
                ? const SizedBox()
                : MouseRegion(
              onEnter: (_) {
                _hoverInput?.value = true;
              },
              onExit: (_) {
                _hoverInput?.value = false;
              },
              child: GestureDetector(
                onTapDown: (_) {
                  globals.audioEnabled = !globals.audioEnabled;
                  _hoverInput?.value = false;
                  _audioInput?.value = globals.audioEnabled;
                  if (globals.audioEnabled) {
                    if(!_audioPlayer.playing)
                      _audioPlayer.play();
                    _audioPlayer.setVolume(DEFAULT_VOLUME);
                  } else{
                    _audioPlayer.setVolume(0);
                  }
                },
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: Rive(
                    artboard: _riveArtboardAudio!,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}