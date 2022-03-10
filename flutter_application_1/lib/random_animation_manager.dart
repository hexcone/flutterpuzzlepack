import 'package:flutter/material.dart';

class StaggerAnimation extends StatelessWidget {

  StaggerAnimation({Key? key, required this.controller, required this.animationAssetIndex, required this.animationPaths})
      :
        paddingAnimationSequence = TweenSequence<EdgeInsets>(
          List<TweenSequenceItem<EdgeInsets>>.generate(animationPaths.length - 1, (i) {
            return 
              TweenSequenceItem<EdgeInsets>(
                tween: EdgeInsetsTween(
                  begin: EdgeInsets.only(top: animationPaths[i][0], left: animationPaths[i][1]),
                  end: EdgeInsets.only(top: animationPaths[i+1][0], left: animationPaths[i+1][1]),
                ).chain(CurveTween(curve: Curves.ease)),
                weight: 1.0/(animationPaths.length - 1)
              );
          })
        ).animate(controller),
        super(key: key);

  final Animation<double> controller;
  final Animation<EdgeInsets> paddingAnimationSequence;
  final int animationAssetIndex;
  final List<List<double>> animationPaths;

  // This function is called each time the controller "ticks" a new frame.
  // When it runs, all of the animation's values will have been
  // updated to reflect the controller's current value.
  Widget _buildAnimation(BuildContext context, Widget? child) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    print("da: " + paddingAnimationSequence.value.top.toString());
        return 
          Opacity(
              opacity: 0.3,
              child: 
                Container(
                  padding: paddingAnimationSequence.value,
                  width: screenWidth,
                  height: screenHeight,
                  color: Colors.blue,
                  child: Text("bobo", style: TextStyle(fontSize: 50, color: Colors.black)),
                )
          );

  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}