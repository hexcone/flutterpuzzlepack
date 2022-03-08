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
      home: const ExampleStateMachine(title: 'Flutter Demo Home Page'),
      builder: (context, child) => NavManager(child: child!),
      navigatorKey: Get.key,
      initialRoute: "/",
    );
  }
}


/// An example showing how to drive two boolean state machine inputs.
class ExampleStateMachine extends StatefulWidget {
  //const ExampleStateMachine({Key? key}) : super(key: key);
  const ExampleStateMachine({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ExampleStateMachineState createState() => _ExampleStateMachineState();
}

class _ExampleStateMachineState extends State<ExampleStateMachine> {
  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  bool isDarkMode = globals.darkModeEnabled;

  Artboard? _riveArtboardMenu;
  Artboard? _riveArtboardBackground;
  StateMachineController? _controller;
  SMIInput<double>? _actionInput;
  SMIInput<double>? _darkModeInput;

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

    // Load the animation file from the bundle, note that you could also
    // download this. The RiveFile just expects a list of bytes.
    rootBundle.load('assets/menu.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
        if (controller != null) {
          artboard.addController(controller);
          _actionInput = controller.findInput('action');
        }
        setState(() => _riveArtboardMenu = artboard);
      },
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
  }

  Widget buildMenuGraphics(double dimension) {
    int extraTopPadding = !kIsWeb ? 100 : 0;
    return Padding(
        padding: EdgeInsets.only(left: 0, top: dimension * 0.1 + extraTopPadding.toDouble(), bottom: 0, right: 0),
        child: Container(
                  height: dimension,
                  width: dimension,
                  child: Rive(
                    artboard: _riveArtboardMenu!,
                  )
        )
    );
  }

  Widget buildMenuGesture(double screenDimension) {
    int extraTopPadding = !kIsWeb ? 100 : 0;
    List<Widget> stackLayers = List<Widget>.generate(3, (index) {
      return Padding(
        padding: EdgeInsets.only(left: screenDimension * 0.29,
            top: index * screenDimension * 0.19 + screenDimension * 0.32 + extraTopPadding,
            bottom: 0,
            right: 0),
        child:
        MouseRegion(
          onEnter: (_) {
            _actionInput?.value = index + 1;
          },
          onExit: (_) {
            _actionInput?.value = 0;
          },
          child:
          GestureDetector(
            onTapDown: (_) {
              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Puzzle(lang: 'ar')),
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Puzzle(lang: 'cn')),
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Puzzle(lang: 'hi')),
                );
              }
            },
            onTapCancel: () {
            },
            onTapUp: (_) {
            },
            child:
            Opacity(
              opacity: 0,
              child: Container(
                height: screenDimension * 0.12,
                width: screenDimension * 0.42,
                color: Colors.pink,
              ),
            ),
          ),
        ),
      );
    });

    return Stack(children:stackLayers);
  }

  Widget buildMenu(double width, double height){
    //Calculate tile dimensions
    double dimensionLimit = min(width, height);

    return Stack(children:
    [
      buildMenuGraphics(dimensionLimit),
      buildMenuGesture(dimensionLimit),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int extraTopPadding = !kIsWeb ? 100 : 0;

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
                      'Count to 15 in another language!',
                      style: globals.darkModeEnabled ? GoogleFonts.pacifico(color: Colors.white) : GoogleFonts.pacifico(color: Colors.black),
                    ),
                  )
                )
              ],
            ),
            Center(
              child: _riveArtboardMenu == null
                  ? const SizedBox()
                  : Column(
                children: [
                  Expanded(
                    child: buildMenu(screenWidth, screenHeight),
                  ),
                ],
              ),
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