import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/random_animation_manager.dart';
import 'package:flutter_application_1/storage_manager.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/exit_popup.dart';
import 'package:flutter_application_1/game_state.dart';
import 'package:flutter_application_1/loading_screen.dart';
import 'package:flutter_application_1/globals.dart' as globals;
import 'package:flutter_application_1/win_screen.dart';
import 'package:rive/rive.dart';
import 'package:indexed/indexed.dart';

class Puzzle extends StatefulWidget {
  const Puzzle({Key? key, required this.lang}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String lang;

  @override
  State<Puzzle> createState() => _PuzzleState();
}

class _PuzzleState extends State<Puzzle> with TickerProviderStateMixin {

  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  /// Message that displays when state has changed
  String stateChangeMessage = '';

  Artboard? _boardBorder;
  List<Artboard>? _riveArtboard = [];
  Artboard? _riveArtboardBackground;
  Artboard? _riveArtboardParatrooper;
  Artboard? _riveArtboardFishBalloon;
  StateMachineController? _controller;
  RiveAnimationController? _controller2;
  List<SMIInput<bool>>? _moves = [], _rows = [], _columns = [];
  List<SMIInput<double>>? _indexes = [];

  List<Widget> stackLayers = [];

  GameState gs = GameState();

  AudioPlayer soundEffectPlayer = AudioPlayer();

  bool gestureEnabled = true;
  bool shuffled = false;
  bool loading = false;
  bool test = false;

  bool isDarkMode = globals.darkModeEnabled;
  SMIInput<double>? _darkModeInput;
  Timer? _globalTimer;

  late AnimationController _animationController;
  int animationDuration = 10000;
  int animationInterval = 30000;
  int animationRNG = 0;
  Timer? _animationTimer;

  FocusNode focusNode = FocusNode(); 

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: Duration(milliseconds: animationDuration), vsync: this);

    _animationTimer = Timer.periodic(Duration(milliseconds: animationInterval + animationDuration), (timer) {
      setState(() {
          animationRNG = Random().nextInt(7);
          _animationController.reset();
          _playAnimation();
        });
      }
    );

    _globalTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      //force rebuild if not in sync with global values
        if (globals.darkModeEnabled != isDarkMode) {
          isDarkMode = globals.darkModeEnabled;
          if (isDarkMode) {
            _darkModeInput?.value = 1;
          } else {
            _darkModeInput?.value = 0;
          }
          setState(() {});
        }
      }
    );

    soundEffectPlayer.setAsset("assets/audio/ClickSample.wav");

    rootBundle.load('assets/paratrooper.riv').then((data) async {
      // Load the RiveFile from the binary data.
      final file = RiveFile.import(data);

      // The artboard is the root of the animation and gets drawn in the
      // Rive widget.
      final artboard = file.mainArtboard;
      var controller = SimpleAnimation('Animation 1');
      artboard.addController(controller);
      setState(() => _riveArtboardParatrooper = artboard);
    });

    rootBundle.load('assets/fishballoon.riv').then((data) async {
      // Load the RiveFile from the binary data.
      final file = RiveFile.import(data);

      // The artboard is the root of the animation and gets drawn in the
      // Rive widget.
      final artboard = file.mainArtboard;
      var controller = SimpleAnimation('Animation 1');
      artboard.addController(controller);
      setState(() => _riveArtboardFishBalloon = artboard);
    });

    rootBundle.load("assets/border.riv").then((data) async{
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;
      setState(() => _boardBorder = artboard);
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
      if (isDarkMode) {
        _darkModeInput?.value = 1;
      } else {
        _darkModeInput?.value = 0;
      }
      setState(() => _riveArtboardBackground = artboard);
    });

    final assets = [
      '/Tile_01.riv',
      '/Tile_02.riv',
      '/Tile_03.riv',
      '/Tile_04.riv',
      '/Tile_05.riv',
      '/Tile_06.riv',
      '/Tile_07.riv',
      '/Tile_08.riv',
      '/Tile_09.riv',
      '/Tile_10.riv',
      '/Tile_11.riv',
      '/Tile_12.riv',
      '/Tile_13.riv',
      '/Tile_14.riv',
      '/Tile_15.riv',
    ];

    for (int i = 0; i < assets.length; i++) {
      // Load the animation file from the bundle, note that you could also
      // download this. The RiveFile just expects a list of bytes.
      rootBundle.load("assets/" + widget.lang + assets[i]).then((data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        dynamic controller = StateMachineController.fromArtboard(
          artboard,
          'State Machine 1',
          onStateChange: _onStateChange,
        );
        if (controller != null) {
          artboard.addController(controller);
          for (int k = 0 ; k<controller.inputs.length; k++) {
            if (controller.inputs[k].name == "move") {
              _moves?.add(controller.inputs[k]);
            } else if (controller.inputs[k].name == "row") {
              _rows?.add(controller.inputs[k]);
            } else if (controller.inputs[k].name == "column") {
              _columns?.add(controller.inputs[k]);
            } else if (controller.inputs[k].name == "index") {
              _indexes?.add(controller.inputs[k]);
            }
          }
        }
        setState(() => _riveArtboard = [..._riveArtboard!, artboard]);
      });
    }
  }

  /// Do something when the state machine changes state
  void _onStateChange(String stateMachineName, String stateName) => setState(
    () {
      stateChangeMessage = 'State Changed in $stateMachineName to $stateName';
      if (stateName == "Reset") {
        gestureEnabled = true;
      }
    },
  );

  Widget buildTileGrid(double tileDimension, double screenWidth, double screenHeight) {
    if (_riveArtboard?.length != 15) {
      return SizedBox();
    }
    final items = [
      Rive(artboard: _riveArtboard![0],),
      Rive(artboard: _riveArtboard![1],),
      Rive(artboard: _riveArtboard![2],),
      Rive(artboard: _riveArtboard![3],),
      Rive(artboard: _riveArtboard![4],),
      Rive(artboard: _riveArtboard![5],),
      Rive(artboard: _riveArtboard![6],),
      Rive(artboard: _riveArtboard![7],),
      Rive(artboard: _riveArtboard![8],),
      Rive(artboard: _riveArtboard![9],),
      Rive(artboard: _riveArtboard![10],),
      Rive(artboard: _riveArtboard![11],),
      Rive(artboard: _riveArtboard![12],),
      Rive(artboard: _riveArtboard![13],),
      Rive(artboard: _riveArtboard![14],),
      Rive(artboard: _boardBorder!,),
    ];

    int extraTopPadding = !kIsWeb ? Platform.isAndroid || Platform.isIOS ? 100 : 0 : 0;

    List<Widget> gestureGrid= <Widget>[];

    stackLayers = List<Widget>.generate(items.length, (index) {
      gestureGrid.add( buildGestureDetectorTile(tileDimension, index));

      return Indexed(
        key: Key(index.toString()),
        index: index != items.length -1 ? gs.getZIndex()[index] : 999,
        child: Padding(
          padding: EdgeInsets.only(left: 0, top: extraTopPadding.toDouble(), bottom: 0, right: 0),
          child: Container(
            height: tileDimension,
            width: tileDimension,
            child: items[index]
          ),
        ),
      );
    });

    return Stack(children: [
      Indexer(children: stackLayers),
      Padding(
        padding: EdgeInsets.only(left: 0, top: extraTopPadding.toDouble(), bottom: 0, right: 0),
        child: Transform.scale(scale: 0.61, 
          child:
            Stack(children: gestureGrid))
        ),
        
    ]);
  }

  Widget buildAnimationLayer(double screenWidth, double screenHeight) {
    Widget paratroopWidget =
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 100,
          height: 100,
          child: _riveArtboardParatrooper == null ? SizedBox() : Rive(artboard: _riveArtboardParatrooper!)
        )
      );
    var paratrooperPath1 = [[-100.0, 0.0], [screenHeight, 0.0]];
    var paratrooperPath2 = [[-100.0, screenWidth / 4], [screenHeight, screenWidth / 4]];
    var paratrooperPath3 = [[-100.0, screenWidth / 1.5], [screenHeight, screenWidth / 1.5]];

    Widget fishBalloonWidget =
      Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 100,
          height: 100,
          child: _riveArtboardFishBalloon == null ? SizedBox() : Rive(artboard: _riveArtboardFishBalloon!)
        )
      );
    var fishBaloonPath1 = [[0.0, -100.0], [0.0, screenWidth]];
    var fishBaloonPath2 = [[screenHeight / 4, -100.0], [screenHeight / 4, screenWidth]];
    var fishBaloonPath3 = [[screenHeight / 1.5, -100.0], [screenHeight / 1.5, screenWidth]];

    switch (animationRNG) {
      case 0:
        return StaggerAnimation(controller: _animationController.view, animationWidget:paratroopWidget, animationPaths: paratrooperPath1);
      case 1:
        return StaggerAnimation(controller: _animationController.view, animationWidget:paratroopWidget, animationPaths: paratrooperPath2);
      case 2:
        return StaggerAnimation(controller: _animationController.view, animationWidget:paratroopWidget, animationPaths: paratrooperPath3);
      case 3:
        return StaggerAnimation(controller: _animationController.view, animationWidget:fishBalloonWidget, animationPaths: fishBaloonPath1);
      case 4:
        return StaggerAnimation(controller: _animationController.view, animationWidget:fishBalloonWidget, animationPaths: fishBaloonPath2);
      default:
        return StaggerAnimation(controller: _animationController.view, animationWidget:fishBalloonWidget, animationPaths: fishBaloonPath3);
    }
  }

  void tapLogic(int index) {
    if (gestureEnabled) {
      if (globals.audioEnabled) {
        if (soundEffectPlayer.playing) {
          soundEffectPlayer.pause();
          soundEffectPlayer.seek(Duration.zero);
        }
        soundEffectPlayer.play();
      }
      List<List<int>> animationPlaylist = gs.tap(index);

      if (animationPlaylist.length > 0) {
        gestureEnabled = false;
      }
      for (int i = 0; i < animationPlaylist.length; i++) {
          int affectedTileIndex = animationPlaylist[i][0];

          // change the z-index
          int value = 0;
          (animationPlaylist[i][6] == 1)? value = 5 : value = -5;
          setState(() {
            gs.incZIndex(affectedTileIndex, value);
          });
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                gs.incZIndex(affectedTileIndex, value);
              });
            }
          });

          setState(() {
            _indexes?[affectedTileIndex].value = animationPlaylist[i][1].toDouble();
            _rows?[affectedTileIndex].value = animationPlaylist[i][2] == 1 ? true : false;
            _columns?[affectedTileIndex].value = animationPlaylist[i][3] == 1 ? true : false;
            _moves?[affectedTileIndex].value = animationPlaylist[i][4] == 1 ? true : false;

            if (gs.findIndexOfTile(affectedTileIndex + 1) == affectedTileIndex) {
              _riveArtboard![affectedTileIndex].addController(_controller2 = SimpleAnimation('Enter Correct Position'));
            } else {
              if (animationPlaylist[i][5] == 1) {
                _riveArtboard![affectedTileIndex].addController(_controller2 = SimpleAnimation('Exit Correct Position'));
              }
            }
          });
      }
      if (gs.isWinningState()) {
        //Player won
        //Show loading screen
        loading = true;
        Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) =>
                WinScreen(gs: gs)));
        
        int newDifficulty = globals.difficulty + 1;
        StorageManager.saveDifficulty(newDifficulty);
        setState(() {
          globals.difficulty = newDifficulty;
        });   
      }
    }
  }
 
  Widget buildGestureDetectorTile(double tileDimension, int index) {
    return Padding(
      padding: EdgeInsets.only(left: index%4 * tileDimension/4, top: index~/4 * tileDimension/4, bottom: 0, right: 0),
      child: MouseRegion(
        onEnter: (_) {
          // handle hover animation
          int affectedTileIndex = gs.hover(index);
          if ((shuffled) && (affectedTileIndex > 0) && (affectedTileIndex < 16)) {
            _riveArtboard![affectedTileIndex - 1].addController(_controller2 = SimpleAnimation('Hover'));
          }
        },
        onExit: (_) {
        },
        child:
        GestureDetector(
          onTapDown: (_) {
            tapLogic(index);
          },
          child:
          Opacity(
            opacity: 0.0,
            child: Container(
              height: tileDimension/4,
              width: tileDimension/4,
              color: Colors.pink,
            )
          ),
        ),
      ),
    );
  }

  Widget buildPlayGrid(double gridWidth, double gridHeight) {
    //Calculate tile dimensions
    double dimensionLimit = min(gridWidth, gridHeight);

    return Stack(children: 
    [
      buildTileGrid(dimensionLimit, gridWidth, gridHeight), 
    ]);
  }

  Future<void> _playAnimation() async {
    try {
      await _animationController.forward().orCancel; //play animation forward
      //await _animationController.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    Future.delayed(Duration.zero, () {
      if (!loading) {
        //Show loading screen
        loading = true;
        Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            LoadingScreen()));
      }
    });

    Future.delayed(Duration(milliseconds: 1000),() {
      if (!shuffled && mounted) {
        //some action on complete
        List<List<List<int>>> shuffleAnimationPlaylist = gs.shuffleBoard(globals.difficulty);

        setState(() {
          for (int i = 0; i < shuffleAnimationPlaylist[0].length; i++) {
            
              int affectedTileIndex = shuffleAnimationPlaylist[0][i][0];
              _indexes?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][1].toDouble();
              _rows?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][2] == 1 ? true : false;
              _columns?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][3] == 1 ? true : false;
              _moves?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][4] == 1 ? true : false;
            
          }
          
        });
        Future.delayed(Duration(milliseconds: 2000),() {
          if (mounted) {
            setState(() {
              for (int i = 0; i < shuffleAnimationPlaylist[1].length; i++) {
                
                  int affectedTileIndex = shuffleAnimationPlaylist[1][i][0];
                  _indexes?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][1].toDouble();
                  _rows?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][2] == 1 ? true : false;
                  _columns?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][3] == 1 ? true : false;
                  _moves?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][4] == 1 ? true : false;
                
              }
            });
          }
         });
        Future.delayed(Duration(milliseconds: 3000),() {
          if (mounted) {
            setState(() {

              for (int i = 0; i < _riveArtboard!.length; i++) {
                if (gs.findIndexOfTile(i + 1) == i) {
                  _riveArtboard![i].addController(SimpleAnimation('Enter Correct Position'));
                }
              }
              
              Timer(Duration(seconds: 1), () { Navigator.pop(context); });
            });
          }
         });
        shuffled = true;
      }
    });

    FocusScope.of(context).requestFocus(focusNode);
    return RawKeyboardListener(
          autofocus: true,
          focusNode: focusNode,   // <-- more magic
          onKey: (RawKeyEvent event) {
            if (event.data.logicalKey == LogicalKeyboardKey.arrowDown) {
              int tileAbove = gs.getTileAbove(16);
              if (tileAbove != -1) {
                tapLogic(gs.findIndexOfTile(tileAbove));
              }
            }
            if (event.data.logicalKey == LogicalKeyboardKey.arrowLeft) {
              int tileRight = gs.getTileRight(16);
              if (tileRight != -1) {
                tapLogic(gs.findIndexOfTile(tileRight));
              }
            }
            if (event.data.logicalKey == LogicalKeyboardKey.arrowRight) {
              
              int tileLeft = gs.getTileLeft(16);
              if (tileLeft != -1) {
                tapLogic(gs.findIndexOfTile(tileLeft));
              }
            }
            if (event.data.logicalKey == LogicalKeyboardKey.arrowUp) {
               
              int tileBelow = gs.getTileBelow(16);
              if (tileBelow != -1) {
                tapLogic(gs.findIndexOfTile(tileBelow));
              }
            }
          },
          child: WillPopScope(
            onWillPop: () => showExitPopup(context, false),
            child: Scaffold(
              backgroundColor: Colors.white,
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
                    buildAnimationLayer(screenWidth, screenHeight),
                    Center(
                      child: _riveArtboard == null
                          ? const SizedBox()
                          : Column(
                              children: [
                                Expanded(
                                  child: buildPlayGrid(screenWidth, screenHeight),
                                )
                              ],
                            ),
                    ),
                  ],
                )
            )
          )
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _globalTimer!.cancel();
    _animationTimer!.cancel();
    super.dispose();
  }

}