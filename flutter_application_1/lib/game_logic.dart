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
  Timer? _timer;
  double _start = -100;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 5000), vsync: this);

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
      }
    );

    soundEffectPlayer.setAsset("assets/audio/ClickSample.wav");
    
    const boardBorderAsset = "assets/border.riv";

    rootBundle.load(boardBorderAsset).then(
      (data) async{
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;
        setState(() => _boardBorder = artboard);
      }
    );

    rootBundle.load('assets/background.riv').then(
          (data) async {
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
      },
    );

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

    var controller;

    for(int i = 0; i < assets.length; i++) {
      // Load the animation file from the bundle, note that you could also
      // download this. The RiveFile just expects a list of bytes.
      rootBundle.load("assets/" + widget.lang + assets[i]).then(
        (data) async {
          // Load the RiveFile from the binary data.
          final file = RiveFile.import(data);

          // The artboard is the root of the animation and gets drawn in the
          // Rive widget.
          final artboard = file.mainArtboard;
          controller = StateMachineController.fromArtboard(
            artboard,
            'State Machine 1',
            onStateChange: _onStateChange,
          );
          if (controller != null) {
            artboard.addController(controller);
            for (int k = 0 ; k<controller.inputs.length; k++) {
              if(controller.inputs[k].name == "move") {
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
        },
      );

      

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
    if (_riveArtboard?.length != 15){
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
      buildAnimationLayer(screenWidth, screenHeight),
      Padding(
        padding: EdgeInsets.only(left: 0, top: extraTopPadding.toDouble(), bottom: 0, right: 0),
        child: Transform.scale(scale: 0.61, 
          child:
            Stack(children: gestureGrid))
        ),
    ]);
  }

  Widget buildAnimationLayer(double screenWidth, double screenHeight) {
    var rng = Random();

    return StaggerAnimation(controller: _animationController.view, animationAssetIndex: 0, animationPaths: [[0,0], [100, 100], [200,200], [screenHeight, screenWidth]]);
  }

  Widget buildGestureDetectorTile(double tileDimension, int index){
    return 
    Padding(
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
              if (gestureEnabled) {
                if(globals.audioEnabled) {
                  
                  soundEffectPlayer.processingStateStream.listen((value) {
                    print('Value from controller: $value');
                    if (value == ProcessingState.completed) {
                        soundEffectPlayer.stop();
                        soundEffectPlayer.seek(Duration.zero);
                    }
                  });
                  soundEffectPlayer.seek(Duration.zero);
                  soundEffectPlayer.play();
                }
                List<List<int>> animationPlaylist = gs.tap(index);
                print("Click on GestureDetector: " + (index).toString());
                print(animationPlaylist);
                _playAnimation();
                gs.printBoard();
                if(animationPlaylist.length > 0) {
                  gestureEnabled = false;
                }
                for(int i=0;i<animationPlaylist.length;i++) {
                    int affectedTileIndex = animationPlaylist[i][0];

                    // change the z-index
                    int value = 0;
                    (animationPlaylist[i][6] == 1)? value = 5 : value = -5;
                    setState(() {
                      gs.incZIndex(affectedTileIndex, value);
                    });
                    Future.delayed(Duration(milliseconds: 2000), () {
                      setState(() {
                        gs.incZIndex(affectedTileIndex, value);
                      });
                    });

                    _indexes?[affectedTileIndex].value = animationPlaylist[i][1].toDouble();
                    _rows?[affectedTileIndex].value = animationPlaylist[i][2] == 1 ? true : false;
                    _columns?[affectedTileIndex].value = animationPlaylist[i][3] == 1 ? true : false;
                    _moves?[affectedTileIndex].value = animationPlaylist[i][4] == 1 ? true : false;

                    if(gs.findIndexOfTile(affectedTileIndex + 1) == affectedTileIndex) {
                      _riveArtboard![affectedTileIndex].addController(_controller2 = SimpleAnimation('Enter Correct Position'));
                    } else {
                      if(animationPlaylist[i][5] == 1) {
                        _riveArtboard![affectedTileIndex].addController(_controller2 = SimpleAnimation('Exit Correct Position'));
                      }
                    }
                }
                if(gs.isWinningState()) {
                  //Player won
                  //Show loading screen
                  loading = true;
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) =>
                          WinScreen(gs: gs)));
                  
                  int newDifficulty = globals.difficulty+1;
                  StorageManager.saveDifficulty(newDifficulty);
                  setState(() {
                    globals.difficulty = newDifficulty;
                  });   
                }
              }
            },
            child:
            Opacity(
              opacity: 0.3,
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

  Widget buildPlayGrid(double gridWidth, double gridHeight){
    //Calculate tile dimensions
    double dimensionLimit = min(gridWidth, gridHeight);

    return Stack(children: 
    [
      buildTileGrid(dimensionLimit, gridWidth, gridHeight), 
    ]);
  }

  Future<void> _playAnimation() async {
    try {
      await _animationController.forward().orCancel;
      await _animationController.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
      print("cancelled");
    }
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    print("sw:" + screenWidth.toString());
    print("sh:" + screenHeight.toString());

    Future.delayed(Duration.zero, () {
      if(!loading) {
        //Show loading screen
        loading = true;
        Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            LoadingScreen()));
      }
    });

    Future.delayed(Duration(milliseconds: 1000),() {
      if(!shuffled) {
        //some action on complete
        List<List<List<int>>> shuffleAnimationPlaylist = gs.shuffleBoard(globals.difficulty);
        print(shuffleAnimationPlaylist);

        setState(() {
          for(int i=0;i<shuffleAnimationPlaylist[0].length;i++) {
            
              int affectedTileIndex = shuffleAnimationPlaylist[0][i][0];
              _indexes?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][1].toDouble();
              _rows?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][2] == 1 ? true : false;
              _columns?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][3] == 1 ? true : false;
              _moves?[affectedTileIndex].value = shuffleAnimationPlaylist[0][i][4] == 1 ? true : false;
            
          }
          
        });
        Future.delayed(Duration(milliseconds: 2000),() {
          setState(() {
            for(int i=0;i<shuffleAnimationPlaylist[1].length;i++) {
              
                int affectedTileIndex = shuffleAnimationPlaylist[1][i][0];
                _indexes?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][1].toDouble();
                _rows?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][2] == 1 ? true : false;
                _columns?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][3] == 1 ? true : false;
                _moves?[affectedTileIndex].value = shuffleAnimationPlaylist[1][i][4] == 1 ? true : false;
              
            }

            for(int i=0;i<_riveArtboard!.length;i++) {
              if(gs.findIndexOfTile(i + 1) == i) {
                _riveArtboard![i].addController(_controller2 = SimpleAnimation('Enter Correct Position'));
              }
            }
            
            Timer(Duration(seconds: 1), () { Navigator.pop(context); });
          });

          
         });
        shuffled = true;
      }
    });

    return WillPopScope(
            onWillPop: () => showExitPopup(context),
            child: Scaffold(
              backgroundColor: Colors.white,
              /*
              appBar: AppBar(
                title: const Text('Puzzle'),
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
          );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer!.cancel();
    super.dispose();
  }

}