import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class WinScreen extends StatefulWidget {
  const WinScreen({Key? key}) : super(key: key);

  @override
  State<WinScreen> createState() => _WinScreenState();
}


class _WinScreenState extends State<WinScreen> {

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {

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
                        child: Text.rich(
                            TextSpan(
                              children: <TextSpan>[
                                TextSpan(text: 'You Won!', style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))),
                              ],
                            ),
                          )
                        ),
                      ),
              )
          )
      );
  }
}