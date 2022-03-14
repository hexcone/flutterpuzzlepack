import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class StaggerAnimation extends StatelessWidget {

  StaggerAnimation({Key? key, required this.controller, required this.animationWidget, required this.animationPaths})
      :
        topAnimationSequence = TweenSequence<double>(
          List<TweenSequenceItem<double>>.generate(animationPaths.length - 1, (i) {
            return 
              TweenSequenceItem<double>(
                tween: Tween(
                  begin: animationPaths[i][0],
                  end: animationPaths[i+1][0],
                ).chain(CurveTween(curve: Curves.ease)),
                weight: 1.0/(animationPaths.length - 1)
              );
          })
        ).animate(controller),
        leftAnimationSequence = TweenSequence<double>(
          List<TweenSequenceItem<double>>.generate(animationPaths.length - 1, (i) {
            return 
              TweenSequenceItem<double>(
                tween: Tween(
                  begin: animationPaths[i][1],
                  end: animationPaths[i+1][1],
                ).chain(CurveTween(curve: Curves.linear)),
                weight: 1.0/(animationPaths.length - 1)
              );
          })
        ).animate(controller),
        super(key: key);

  final Animation<double> controller;
  final Animation<double> topAnimationSequence;
  final Animation<double> leftAnimationSequence;
  final Widget animationWidget;
  final List<List<double>> animationPaths;

  // This function is called each time the controller "ticks" a new frame.
  // When it runs, all of the animation's values will have been
  // updated to reflect the controller's current value.
  Widget _buildAnimation(BuildContext context, Widget? child) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
        return 
          Positioned(
            top: topAnimationSequence.value,
            left: leftAnimationSequence.value,
            child: 
              Opacity(
                opacity: 0.7,
                child: Container(
                  width: screenWidth,
                  height: screenHeight,
                  //color: Colors.blue,
                  //child: Text("bobo", style: TextStyle(fontSize: 50, color: Colors.black)),
                  child: animationWidget
                ),
              ),
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