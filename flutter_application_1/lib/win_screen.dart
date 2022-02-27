import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/game_state.dart';
import 'package:rive/rive.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({Key? key, required this.gs}) : super(key: key);

  final GameState gs;

  @override
  State<WinScreen> createState() => _WinScreenState(gs);
}


class _WinScreenState extends State<WinScreen> {
  GameState? gs;
  Artboard? _riveArtboardWinningStar;

  _WinScreenState(GameState gs){
    this.gs = gs;
  }

  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/winningstar.riv').then(
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
        setState(() => _riveArtboardWinningStar = artboard);
      },
    );
  }

  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return 
      WillPopScope(
        onWillPop: () { 
          return Future.value(false); 
        },
        child: 
          GestureDetector(
            onTapDown: (_) {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child:
              Scaffold(
                backgroundColor: Colors.black.withOpacity(0.5), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
                body: 
                  Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: 
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _riveArtboardWinningStar == null
                                ? const SizedBox()
                                : SizedBox(
                                    height: screenHeight * 0.3,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Rive(
                                        artboard: _riveArtboardWinningStar!,
                                      ),
                                    ),
                                  ),
                                Text.rich(TextSpan(text: 'You Won!', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255), fontSize: 50))),
                                Text.rich(TextSpan(text: 'Time Taken: ' + gs!.getTimeTakenString(), style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)))),
                                Text.rich(TextSpan(text: 'Number of Moves: ' + gs!.getNumMoves(), style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)))),
                              ],
                            ),
                          )
                        ),
                      ),
              )
      );
  }
}