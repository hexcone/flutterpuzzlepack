import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}


class _LoadingScreenState extends State<LoadingScreen> {

  Artboard? _riveArtboardLoader;

  @override
  void initState() {
    super.initState();
    rootBundle.load('assets/loader.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = SimpleAnimation('infinite 2');
        if (controller != null) {
          artboard.addController(controller);
        }
        setState(() => _riveArtboardLoader = artboard);
      },
    );
  }

  Widget build(BuildContext context) {

    return 
    WillPopScope(
      onWillPop: () { 
        return Future.value(false); 
      },
      child: Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: 
      _riveArtboardLoader == null
      ? const SizedBox()
      : Container(
          child: Align(
            alignment: Alignment.center,
            child: Rive(
              fit: BoxFit.scaleDown,
              artboard: _riveArtboardLoader!,
            ),
          ),
        )
      )
    );
  }
}