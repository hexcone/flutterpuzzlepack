import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/level_picker.dart';
import 'package:flutter_application_1/nav_manager.dart';
import 'package:rive/rive.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_application_1/globals.dart' as globals;

import 'game_logic.dart';

final languages = [
  "ar",
  "cn",
  "hi"
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    

    return MaterialApp(
      title: 'Language Tiles - Learn to count to 15 in different languages!',
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
      home: const LanguageTilesStateMachine(title: 'Language Tiles - Learn to count to 15 in different languages!'),
      builder: (context, child) => NavManager(child: child!),
      navigatorKey: Get.key,
      initialRoute: "/",
    );
  }
}


/// An example showing how to drive two boolean state machine inputs.
class LanguageTilesStateMachine extends StatefulWidget {
  //const ExampleStateMachine({Key? key}) : super(key: key);
  const LanguageTilesStateMachine({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LanguageTilesStateMachineState createState() => _LanguageTilesStateMachineState();
}

class _LanguageTilesStateMachineState extends State<LanguageTilesStateMachine> {
  /// Tracks if the animation is playing by whether controller is running.
  bool get isPlaying => _controller?.isActive ?? false;

  bool isDarkMode = globals.darkModeEnabled;

  List<Artboard>? _riveArtboardMenu = [];
  Artboard? _riveArtboardBackground;
  StateMachineController? _controller;
  SMIInput<double>? _actionInput;
  SMIInput<double>? _darkModeInput;

  Timer? _timer;
  var pages;

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

    for (int i = 0; i < languages.length; i++) {
      String lang = languages[i];
      rootBundle.load('assets/menu/' + lang + '.riv').then((data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = SimpleAnimation('idle');
        artboard.addController(controller);
        setState(() => _riveArtboardMenu = [..._riveArtboardMenu!, artboard]);
      });
    }

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

  final page_controller = PageController(
    viewportFraction: 0.8,
    keepPage: true,
    initialPage: 0,
  );

  bool pageIsScrolling = false;

  void _onScroll(double offset) {
    if (pageIsScrolling == false) {
      pageIsScrolling = true;
      if (offset > 0) {
        page_controller
            .nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut)
            .then((value) => pageIsScrolling = false);

        _riveArtboardMenu![(page_controller.page! % pages.length).toInt()]
            .addController(SimpleAnimation('idle'));
        _riveArtboardMenu![((page_controller.page! + 1) % pages.length).toInt()]
            .addController(SimpleAnimation('hover'));
      } else {
        page_controller
            .previousPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut)
            .then((value) => pageIsScrolling = false);

        _riveArtboardMenu![(page_controller.page! % pages.length).toInt()]
            .addController(SimpleAnimation('idle'));
        _riveArtboardMenu![((page_controller.page! - 1) % pages.length).toInt()]
            .addController(SimpleAnimation('hover'));
      }
    }
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

    pages = List.generate(languages.length, (index) =>
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white30,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Container(
          height: 280,
          child: Center(
            child: (_riveArtboardMenu!.length != languages.length) ?
            SizedBox() :
            Rive(artboard: _riveArtboardMenu![index]),
          ),
        ),
      ),
    );

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
                  ),
                ),
              ],
            ),

            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: min(screenWidth, screenHeight) * 0.25 + extraTopPadding),
                  ),
                                    MouseRegion(
                    onEnter: (_) {
                      _riveArtboardMenu![(page_controller.page! % pages.length).toInt()].addController(SimpleAnimation('hover'));
                    },
                    onExit: (_) {
                      _riveArtboardMenu![(page_controller.page! % pages.length).toInt()].addController(SimpleAnimation('idle'));
                    },
                    child: GestureDetector(
                      // to detect swipe
                      onPanUpdate: (details) {
                        _onScroll(details.delta.dy * -1);
                      },
                      onTapDown: (_) {
                        // chooose level
                        int index = (page_controller.page! % pages.length).toInt();

                        if (index == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LevelPicker(lang: 'ar')),
                          );
                        } else if (index == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LevelPicker(lang: 'cn')),
                          );
                        } else if (index == 2) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LevelPicker(lang: 'hi')),
                          );
                        }
                       },
                      child: Listener(
                        // to detect scroll
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            _onScroll(pointerSignal.scrollDelta.dy);
                          }
                        },
                        child: SizedBox(
                          height: min(screenWidth, screenHeight) * 0.6,
                          child: PageView.builder(
                            controller: page_controller,
                            // itemCount: pages.length,
                            itemBuilder: (_, index) {
                              return pages[index % pages.length];
                            },
                            physics: NeverScrollableScrollPhysics(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                  ),
                  SmoothPageIndicator(
                    controller: page_controller,
                    count: pages.length,
                    effect: ScrollingDotsEffect(
                      activeStrokeWidth: 2.6,
                      activeDotScale: 1.3,
                      maxVisibleDots: 5,
                      radius: 8,
                      spacing: 10,
                      dotHeight: 12,
                      dotWidth: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }
}