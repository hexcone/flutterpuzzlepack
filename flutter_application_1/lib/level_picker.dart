import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/nav_manager.dart';
import 'package:rive/rive.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/globals.dart' as globals;

import 'game_logic.dart';


class LevelPicker extends StatefulWidget {
  const LevelPicker({Key? key, required this.lang}) : super(key: key);

  final String lang;

  @override
  State<LevelPicker> createState() => _LevelPickerState();
}

class _LevelPickerState extends State<LevelPicker> {
  bool isDarkMode = globals.darkModeEnabled;

  StateMachineController? _controller;
  Artboard? _riveArtboardBackground;
  SMIInput<double>? _darkModeInput;

  var pages;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(new Duration(milliseconds: 500), (timer) {
      //force rebuild if not in sync with global values
      if(globals.darkModeEnabled != isDarkMode){
        isDarkMode = globals.darkModeEnabled;
        if(isDarkMode) {
          _darkModeInput?.value = 1;
        } else {
          _darkModeInput?.value = 0;
        }
        setState(() {});
      }
    });

    rootBundle.load('assets/background.riv').then((data) async {
      // Load the RiveFile from the binary data.
      final file = RiveFile.import(data);

      // The artboard is the root of the animation and gets drawn in the
      // Rive widget.
      final artboard = file.mainArtboard;
      var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
      if (controller != null) {
        artboard.addController(controller);
        _darkModeInput = controller.findInput('Number 1');
      }
      if(isDarkMode) {
        _darkModeInput?.value = 1;
      } else {
        _darkModeInput?.value = 0;
      }
      setState(() => _riveArtboardBackground = artboard);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int extraTopPadding = 0;
    if (defaultTargetPlatform == TargetPlatform.android ||defaultTargetPlatform == TargetPlatform.windows) {
      extraTopPadding = 100;
    }
    else if (defaultTargetPlatform == TargetPlatform.linux || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.iOS) {
      extraTopPadding = 0;
    }
    else {
      extraTopPadding = 0;
    }

    var container_width = min(screenWidth, screenHeight) * 0.2;
    var container_padding_right = min(screenWidth, screenHeight) * 0.05;
    var container_padding_top = min(screenWidth, screenHeight) * 0.3 + extraTopPadding;

    return Scaffold(

        backgroundColor: Colors.white,
        /*
      appBar: AppBar(
        title: const Text('Button State Machine'),
      ),
      */
        body: Stack(
          children: [
            _riveArtboardBackground == null
                ? const SizedBox()
                : Container(
              child: Rive(
                fit: BoxFit.cover,
                artboard: _riveArtboardBackground!,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container (
                    width: min(screenWidth, screenHeight) * 0.6,
                    padding: EdgeInsets.only(top: min(screenWidth, screenHeight) * 0.15 + extraTopPadding),
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        'Choose difficulty of game!',
                        style: globals.darkModeEnabled ? GoogleFonts.pacifico(color: Colors.white) : GoogleFonts.pacifico(color: Colors.black),
                      ),
                    )
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MouseRegion(
                  onEnter: (_) {
                  },
                  onExit: (_) {
                  },
                  child: GestureDetector(
                    onTapDown: (_) {
                      globals.difficulty = 2;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Puzzle(lang: widget.lang)),
                      );
                    },
                    child: Padding (
                      padding: EdgeInsets.only(top: container_padding_top),
                      child: Column(
                        children: [
                          Opacity(
                            opacity: 0.3,
                            child: Container(
                              alignment: Alignment.center,
                              height: container_width,
                              width: container_width,
                              color: Colors.green,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  'Easy',
                                  style: globals.darkModeEnabled ? GoogleFonts.pacifico(color: Colors.white) : GoogleFonts.pacifico(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: container_padding_right),
                ),
                MouseRegion(
                  onEnter: (_) {
                  },
                  onExit: (_) {
                  },
                  child: GestureDetector(
                    onTapDown: (_) {
                      globals.difficulty = 20;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Puzzle(lang: widget.lang)),
                      );
                    },
                    child: Padding (
                      padding: EdgeInsets.only(top: container_padding_top),
                      child: Column(
                        children: [
                          Opacity(
                            opacity: 0.3,
                            child: Container(
                              alignment: Alignment.center,
                              height: container_width,
                              width: container_width,
                              color: Colors.yellow,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  'Medium',
                                  style: globals.darkModeEnabled ? GoogleFonts.pacifico(color: Colors.white) : GoogleFonts.pacifico(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: container_padding_right),
                ),
                MouseRegion(
                  onEnter: (_) {
                  },
                  onExit: (_) {
                  },
                  child: GestureDetector(
                    onTapDown: (_) {
                      globals.difficulty = 100;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Puzzle(lang: widget.lang)),
                      );
                    },
                    child: Padding (
                      padding: EdgeInsets.only(top: container_padding_top),
                      child: Column(
                        children: [
                          Opacity(
                            opacity: 0.3,
                            child: Container(
                              alignment: Alignment.center,
                              height: container_width,
                              width: container_width,
                              color: Colors.orange,
                              child: FittedBox(
                                fit: BoxFit.fitWidth,
                                child: Text(
                                  'Hard',
                                  style: globals.darkModeEnabled ? GoogleFonts.pacifico(color: Colors.white) : GoogleFonts.pacifico(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
    );
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
}