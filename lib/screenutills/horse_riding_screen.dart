import 'package:flutter/material.dart';
import 'horse_riding_widget.dart';



class HorseRidingScreen extends StatefulWidget {
  @override
  _HorseRidingScreenState createState() => _HorseRidingScreenState();
}

class _HorseRidingScreenState extends State<HorseRidingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // infinite loop
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: HorseRidingPainter(_controller.value),
              size: const Size(300, 300),
            );
          },
        ),
      ),
    );
  }
}
