import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class M3L1 extends StatefulWidget {
  @override
  _M3L1State createState() => _M3L1State();
}

class _M3L1State extends State<M3L1> {
  late Offset characterPosition;
  final double speed = 6.0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Set initial character position and scroll to it after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        characterPosition = Offset(screenWidth / 2, screenHeight * 2 - 100);
      });
      
      // Use a post-frame callback to ensure the scroll happens after the widget is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToCharacterPosition(characterPosition);
      });
    });
  }

  void onJoystickUpdate(double x, double y) {
    double distance = sqrt(x * x + y * y) * speed;
    double angle = atan2(y, x);

    Offset newPosition = Offset(
      characterPosition.dx + distance * cos(angle),
      characterPosition.dy + distance * sin(angle),
    );

    if (isOnPath(newPosition)) {
      setState(() {
        characterPosition = newPosition;
      });
      scrollToPosition(-y);
    }
  }

  void scrollToPosition(double joystickY) {
    double scrollAmount = joystickY * speed;
    double newScrollPosition = _scrollController.position.pixels - scrollAmount;

    if (newScrollPosition < 0) {
      newScrollPosition = 0;
    } else if (newScrollPosition > _scrollController.position.maxScrollExtent) {
      newScrollPosition = _scrollController.position.maxScrollExtent;
    }

    _scrollController.jumpTo(newScrollPosition);
  }

  void scrollToCharacterPosition(Offset position) {
    double screenHeight = MediaQuery.of(context).size.height;
    double newScrollPosition = position.dy - screenHeight / 2;

    if (newScrollPosition < 0) {
      newScrollPosition = 0;
    } else if (newScrollPosition > _scrollController.position.maxScrollExtent) {
      newScrollPosition = _scrollController.position.maxScrollExtent;
    }

    _scrollController.jumpTo(newScrollPosition);
  }

  bool isOnPath(Offset position) {
    double pathWidth = 100.0; // Adjust the path width
    double centerX = MediaQuery.of(context).size.width / 2;
    double minX = centerX - pathWidth / 2;
    double maxX = centerX + pathWidth / 2;

    return position.dx >= minX &&
        position.dx <= maxX &&
        position.dy >= 80 &&
        position.dy <= MediaQuery.of(context).size.height * 2 - 100; // Allow for a longer path
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 2, // Double the height for a longer path
              color: Color.fromARGB(255, 167, 216, 97),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(double.infinity, MediaQuery.of(context).size.height * 2),
                    painter: PathPainter(
                      startY: MediaQuery.of(context).size.height * 2 - 100,
                    ),
                  ),
                  Positioned(
                    left: characterPosition.dx - 12.5,
                    top: characterPosition.dy - 30,
                    child: Image.asset('assets/old_circle.png', width: 30, height: 30),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Joystick(
              base: JoystickBase(
                size: 160,
                withBorderCircle: false,
              ),
              mode: JoystickMode.all,
              listener: (details) {
                onJoystickUpdate(details.x, details.y);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final double startY;

  PathPainter({required this.startY});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 70, 77, 85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 100.0;
      // Paint for the white center line
    Paint centerLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.50; // Width of the white line

    Path path = Path();
    path.moveTo(size.width / 2, startY);
    path.lineTo(size.width / 2, 0);

    canvas.drawPath(path, paint);
    // Draw the white center line on top of the path
    Path centerLine = Path();
    centerLine.moveTo(size.width / 2, startY);
    centerLine.lineTo(size.width / 2, 0);
    canvas.drawPath(centerLine, centerLinePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
