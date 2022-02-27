import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/game_state.dart';
import 'package:rive/rive.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const Puzzle(lang: 'ar'),
    );
  }
}

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

class _PuzzleState extends State<Puzzle> {

  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  /// Message that displays when state has changed
  String stateChangeMessage = '';

  List<Artboard>? _riveArtboard = [];
  StateMachineController? _controller;
  RiveAnimationController? _controller2;
  List<SMIInput<bool>>? _moves = [], _rows = [], _columns = [];
  List<SMIInput<double>>? _indexes = [];

  GameState gs = GameState();

  bool gestureEnabled = true;
  bool shuffled = false;

  @override
  void initState() {
    print("wtf");
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      print("WidgetsBinding");
    });

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      print("SchedulerBinding");
      
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

    var controller;

    for(int i = 0; i < assets.length; i++) {
      // Load the animation file from the bundle, note that you could also
      // download this. The RiveFile just expects a list of bytes.
      rootBundle.load("assets/" + widget.lang + assets[i]).then(
        (data) {
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
            print("biibi" + (_indexes?.length).toString());
          }
          print("dump");
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

  Widget buildTileGrid(double tileDimension) {
    if (_riveArtboard?.length == 0){
      return SizedBox();
    }
    final items = [
      Rive(artboard: _riveArtboard![12],), 
      Rive(artboard: _riveArtboard![13],),
      Rive(artboard: _riveArtboard![14],),
      Rive(artboard: _riveArtboard![8],),
      Rive(artboard: _riveArtboard![9],),
      Rive(artboard: _riveArtboard![10],),
      Rive(artboard: _riveArtboard![11],),
      Rive(artboard: _riveArtboard![4],), 
      Rive(artboard: _riveArtboard![5],),
      Rive(artboard: _riveArtboard![6],),
      Rive(artboard: _riveArtboard![7],),
      Rive(artboard: _riveArtboard![0],),
      Rive(artboard: _riveArtboard![1],),
      Rive(artboard: _riveArtboard![2],),
      Rive(artboard: _riveArtboard![3],),
    ];

    List<Widget> stackLayers = List<Widget>.generate(items.length, (index) {
      return Padding(
        //padding: EdgeInsets.only(left: index%4 * tileDimension, top: index~/4 * tileDimension, bottom: 0, right: 0),
        padding: EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 0),
        child: 
          Container(
            height: tileDimension,
            width: tileDimension,
            child: items[index]
          ),
      );
    });

    return Stack(children: stackLayers);
  }

  Widget buildGestureGrid(double screenDimension, double tileDimension) { 

    double tileDimension = screenDimension * 0.62 / 4;
    var rng = Random();
    print("wah" + rng.nextInt(100).toString());
    List<Widget> stackLayers = List<Widget>.generate(16, (index) {
      return Padding(
        padding: EdgeInsets.only(left: index%4 * tileDimension + screenDimension * 0.20, top: index~/4 * tileDimension + screenDimension * 0.18, bottom: 0, right: 0),
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
                List<List<int>> animationPlaylist = gs.tap(index);
                print("Click on GestureDetector: " + (index).toString());
                print(animationPlaylist);
                gs.printBoard();
                if(animationPlaylist.length > 0) {
                  gestureEnabled = false;
                }
                for(int i=0;i<animationPlaylist.length;i++) {
                    int affectedTileIndex = animationPlaylist[i][0];
                    _indexes?[affectedTileIndex].value = animationPlaylist[i][1].toDouble();
                    print("yo" + (_indexes?[i].value).toString());
                    _rows?[affectedTileIndex].value = animationPlaylist[i][2] == 1 ? true : false;
                    _columns?[affectedTileIndex].value = animationPlaylist[i][3] == 1 ? true : false;
                    _moves?[affectedTileIndex].value = animationPlaylist[i][4] == 1 ? true : false;

                    if(gs.findIndexOfTile(affectedTileIndex + 1) == affectedTileIndex) {
                      _riveArtboard![affectedTileIndex].addController(_controller2 = SimpleAnimation('Enter Correct Position'));
                    } else {
                      _riveArtboard![affectedTileIndex].addController(_controller2 = SimpleAnimation('Exit Correct Position'));
                    }
                }
              }
            },
            child:
            Opacity(
              opacity: 0,
              child: Container(
                height: tileDimension,
                width: tileDimension,
                color: Colors.pink,
              )
            ),
          ),
        ),
      );
    });

    return Stack(children: stackLayers);
  } 

  Widget buildPlayGrid(double gridWidth, double gridHeight){
    //Calculate tile dimensions
    double dimensionLimit = min(gridWidth, gridHeight);
    double tileDimension = dimensionLimit /4;

    return Stack(children: 
    [
      buildTileGrid(dimensionLimit), 
      buildGestureGrid(dimensionLimit, tileDimension),
    ]);
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    print("sw:" + screenWidth.toString());
    print("sh:" + screenHeight.toString());

    Future.delayed(Duration(milliseconds: 1000),() {
      if(!shuffled) {
        //some action on complete
        List<List<List<int>>> shuffleAnimationPlaylist = gs.shuffleBoard(100);
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
            } else {
              _riveArtboard![i].addController(_controller2 = SimpleAnimation('Exit Correct Position'));
            }
          }
        });
         });
        shuffled = true;
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      /*
      appBar: AppBar(
        title: const Text('Puzzle'),
      ),
      */
      body: Center(
        child: _riveArtboard == null
            ? const SizedBox()
            :  Column(
          children: [
            Expanded(
              child: buildPlayGrid(screenWidth, screenHeight),
            ),
          ],
        ),
      ),
    );
  }
}