import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M2L5 extends StatefulWidget {
  @override
  _M2L5State createState() => _M2L5State();
}

class _M2L5State extends State<M2L5>with SingleTickerProviderStateMixin {
  Offset characterPosition = Offset(50, 350);
  final double speed = 10.0; // Speed factor to increase movement speed
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start a timer to show hint button after 30 seconds

  }

  void onButtonPress(double dx, double dy) {
    Offset newPosition = Offset(
      characterPosition.dx + dx * speed,
      characterPosition.dy + dy * speed,
    );

    if (isOnPath(newPosition)) {
      setState(() {
        characterPosition = newPosition;
      });
    }
  }

  bool isOnPath(Offset position) {
    // Define the curved path
    Path path = Path();
    path.moveTo(50, 350);
    path.quadraticBezierTo(100, -100, 300, 300);

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric metric in pathMetrics) {
      for (double i = 0; i < metric.length; i += 1.0) {
        Tangent? tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          Offset point = tangent.position;
          if ((position - point).distance <= 15) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void moveContinuously(Function moveFunction) {
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      moveFunction();
      if (_controller!.isAnimating) {
        timer.cancel();
      }
    });
  }

  void stopMovement() {
    _controller?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: PathPainter(),
          ),
          Positioned(
            left: characterPosition.dx - 10,
            top: characterPosition.dy - 10,
            child: Icon(Icons.circle, color: Colors.red, size: 25),
          ),
          Positioned(
            bottom: 65,
            right: 90,
            child: GestureDetector(
              onLongPressStart: (_) => onButtonPress(-1, 0),
              onLongPressEnd: (_) => stopMovement(),
              child: FloatingActionButton(
                onPressed: () => onButtonPress(-1, 0),
                child: Icon(Icons.arrow_left),
                backgroundColor: Colors.lightBlueAccent,
                elevation: 5,
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: 85,
            child: GestureDetector(
              onLongPressStart: (_) => onButtonPress(0, -1),
              onLongPressEnd: (_) => stopMovement(),
              child: FloatingActionButton(
                onPressed: () => onButtonPress(0, -1),
                child: Icon(Icons.arrow_upward),
                backgroundColor: Colors.lightBlueAccent,
                elevation: 5,
              ),
            ),
          ),
          Positioned(
            bottom: 65,
            right: 10,
            child: GestureDetector(
              onLongPressStart: (_) => onButtonPress(1, 0),
              onLongPressEnd: (_) => stopMovement(),
              child: FloatingActionButton(
                onPressed: () => onButtonPress(1, 0),
                child: Icon(Icons.arrow_right),
                backgroundColor: Colors.lightBlueAccent,
                elevation: 5,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 85,
            child: GestureDetector(
              onLongPressStart: (_) => onButtonPress(0, 1),
              onLongPressEnd: (_) => stopMovement(),
              child: FloatingActionButton(
                onPressed: () => onButtonPress(0, 1),
                child: Icon(Icons.arrow_downward),
                backgroundColor: Colors.lightBlueAccent,
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25.0;

    Path path = Path();
    path.moveTo(50, 350);
    path.quadraticBezierTo(100, -100, 300, 300);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
