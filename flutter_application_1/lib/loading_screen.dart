import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}


class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {

    return 
    WillPopScope(
      onWillPop: () { 
        return Future.value(false); 
      },
      child: Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // this is the main reason of transparency at next screen. I am ignoring rest implementation but what i have achieved is you can see.
      body: 
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Align(
            alignment: Alignment.center,
            child: FlutterLogo(
              size: 120,
            ),
          ),
        )
      )
    );
  }
}