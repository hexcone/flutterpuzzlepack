import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/storage_manager.dart';
import 'package:google_fonts/google_fonts.dart';
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
  Artboard? _riveArtboardDarkMode;
  StateMachineController? _audioController;
  SMIInput<bool>? _darkModeInput;
  SMIInput<bool>? _audioInput;
  SMIInput<bool>? _hoverInput;
  SMIInput<bool>? _darkModeInput_Audio;

  int currentDifficulty = globals.difficulty;
  bool isDarkMode = globals.darkModeEnabled;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(new Duration(milliseconds: 500), (timer) {
        if(globals.difficulty != currentDifficulty || globals.darkModeEnabled != isDarkMode){
          setState(() {
            /*force re-build if globals not in sync*/
            currentDifficulty = globals.difficulty;
            isDarkMode = globals.darkModeEnabled;
          });
        }
      }
    );

    //difficulty
    StorageManager.readDifficulty().then((value) => globals.difficulty = value);

    // logo
    rootBundle.load('assets/nav/logo.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = globals.darkModeEnabled ?
          SimpleAnimation('Animation 1_dark') :
          SimpleAnimation('Animation 1');
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
        artboard.addController(globals.darkModeEnabled ?
          SimpleAnimation('idle_dark') :
          SimpleAnimation('idle'));
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
          _darkModeInput_Audio = controller.findInput('dark');
        }
        if (globals.audioEnabled) {
          _audioInput?.value = true;
        } else {
          _audioInput?.value = false;
        }
        _hoverInput?.value = false;
        if (globals.darkModeEnabled) {
          _darkModeInput_Audio?.value = true;
        } else {
          _darkModeInput_Audio?.value = false;
        }
        setState(() => _riveArtboardAudio = artboard);
      },
    );

    // handle dark mode
    rootBundle.load('assets/dark_light_mode.riv').then(
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
          _darkModeInput = controller.findInput('dark_mode');
        }
        if (globals.darkModeEnabled) {
          _darkModeInput?.value = true;
        } else {
          _darkModeInput?.value = false;
        }
        setState(() => _riveArtboardDarkMode = artboard);
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
    credits.add("Nav icons - https://rive.app/community/1298-2487-animated-icon-set-1-color/");
    credits.add("Dark/ light mode icon - https://rive.app/community/858-1665-switch-for-dark-and-light-mode-transitions/");
    credits.add("Background - https://rive.app/community/1178-2268-fishbaloony/");
    credits.add("Menu - https://rive.app/community/317-615-interaction-menu-example/");
    credits.add("Loader - https://rive.app/community/425-786-circular-progress-indicator/");
    credits.add("Paratrooper - https://rive.app/community/1738-3431-raster-graphics-example/");
    credits.add("Fish Balloon - https://rive.app/community/1178-2268-fishbaloony/");

    String ret = "";
    for(int i=0;i<credits.length;i++){
      ret += credits[i] + "\n";
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {

    Widget navbarContainer = Container(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                      globals.darkModeEnabled ?
                        _riveArtboardHome!.addController(SimpleAnimation('active_dark')) :
                        _riveArtboardHome!.addController(SimpleAnimation('active'));
                    },
                    onExit: (_) {
                      globals.darkModeEnabled ?
                        _riveArtboardHome!.addController(SimpleAnimation('idle_dark')) :
                        _riveArtboardHome!.addController(SimpleAnimation('idle'));
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
                        globals.darkModeEnabled ?
                          _darkModeInput_Audio?.value = true :
                          _darkModeInput_Audio?.value = false;

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
            Row(
              children: [
                _riveArtboardDarkMode == null
                    ? const SizedBox()
                    : MouseRegion(
                  child: GestureDetector(
                    onTapDown: (_) {
                      globals.darkModeEnabled = !globals.darkModeEnabled;
                      _darkModeInput?.value = globals.darkModeEnabled;

                      _riveArtboardLogo?.addController(globals.darkModeEnabled ?
                      SimpleAnimation('Animation 1_dark') :
                      SimpleAnimation('Animation 1'));

                      _riveArtboardHome?.addController(globals.darkModeEnabled ?
                      SimpleAnimation('idle_dark') :
                      SimpleAnimation('idle'));

                      globals.darkModeEnabled ?
                      _darkModeInput_Audio?.value = true :
                      _darkModeInput_Audio?.value = false;
                    },
                    child: SizedBox(
                      width: 96,
                      height: 64,
                      child: Rive(
                        artboard: _riveArtboardDarkMode!,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    
    double screenWidth = MediaQuery.of(context).size.width;

    if(screenWidth < 455.0) {
      return FittedBox(
        fit: BoxFit.contain,
        child: navbarContainer,
      );
    }

    return navbarContainer;
      
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
}