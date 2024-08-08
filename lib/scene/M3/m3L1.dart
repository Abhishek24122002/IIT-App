import 'dart:async';
import 'dart:math';
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
  late Timer signalTimer;
  int signalTimerCounter = 10;
  bool isSignalRed = true;
  int points = 0;
  String warningMessage = '';
  List<double> crossedSignals = [];
  List<Widget> trees = [];
  double previousYPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      double maxDimension = max(screenWidth, screenHeight);
      setState(() {
        characterPosition = Offset(screenWidth / 2, maxDimension * 4 - 100);
        previousYPosition = characterPosition.dy;
      });

      startSignalTimer();
      generateTrees(maxDimension);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToCharacterPosition(characterPosition);
      });
    });
  }

  @override
  void dispose() {
    signalTimer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void startSignalTimer() {
    signalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (signalTimerCounter > 0) {
          signalTimerCounter--;
        } else {
          isSignalRed = !isSignalRed;
          signalTimerCounter = 10;
        }
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
      checkSignalCrossing(newPosition);
    }
  }

  void checkSignalCrossing(Offset newPosition) {
    List<double> signalPositions = getSignalYPositions();

    for (double signalYPosition in signalPositions) {
      if ((newPosition.dy - signalYPosition).abs() < 10 &&
          !crossedSignals.contains(signalYPosition)) {
        if (!isSignalRed && newPosition.dy < previousYPosition) {
          setState(() {
            points += 1;
            warningMessage = 'Crossed on Green Signal: +1 Point';
            crossedSignals.add(signalYPosition); // Mark this signal as crossed
          });
        }
      }
    }

    previousYPosition = newPosition.dy;
  }

  List<double> getSignalYPositions() {
    double maxDimension = max(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    double signalSpacing = 500.0;
    List<double> signalPositions = [];

    for (double y = maxDimension * 4 - 100; y > 0; y -= signalSpacing) {
      if (y == maxDimension * 4 - 100) continue;
      signalPositions.add(y - 15);
    }

    return signalPositions;
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
    double pathWidth = 100.0;
    double centerX = MediaQuery.of(context).size.width / 2;
    double minX = centerX - pathWidth / 2;
    double maxX = centerX + pathWidth / 2;
    double maxDimension = max(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);

    return position.dx >= minX &&
        position.dx <= maxX &&
        position.dy >= 80 &&
        position.dy <= maxDimension * 4 - 100;
  }

  List<Widget> buildSignals(double maxDimension) {
    List<Widget> signals = [];
    double signalSpacing = 500.0;
    double signalX = MediaQuery.of(context).size.width / 2 - 80;

    for (double y = maxDimension * 4 - 100; y > 0; y -= signalSpacing) {
      if (y == maxDimension * 4 - 100) continue;
      signals.add(Positioned(
        left: signalX,
        top: y - 15,
        child: Image.asset(
          isSignalRed ? 'assets/red.png' : 'assets/green.png',
          width: 30,
          height: 100,
        ),
      ));
    }

    return signals;
  }

  void generateTrees(double maxDimension) {
    List<String> treeImages = [
      'assets/tree.png',
      'assets/tree2.png',
      'assets/tree3.png'
    ];
    double treeSpacing = 200.0;
    double roadCenterX = MediaQuery.of(context).size.width / 2;
    double roadWidth = 100.0;
    double leftTreeX = roadCenterX - roadWidth / 2 - 80; // Updated
    double rightTreeX = roadCenterX + roadWidth / 2 + 50; // Updated
    List<double> signalPositions = getSignalYPositions();

    for (double y = maxDimension * 4 - 150; y > 50; y -= treeSpacing) {
      // Ensure the tree is not placed horizontally aligned with any signal
      if (signalPositions.any((signalY) => (y - signalY).abs() < 80)) {
        continue;
      }

      String treeImage = treeImages[Random().nextInt(treeImages.length)];
      bool placeOnLeft = Random().nextBool();

      trees.add(Positioned(
        left: placeOnLeft ? leftTreeX : rightTreeX,
        top: y,
        child: Image.asset(
          treeImage,
          width: 50,
          height: 50,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double maxDimension = max(MediaQuery.of(context).size.width, screenHeight);

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: maxDimension * 4,
              color: Color.fromARGB(255, 167, 216, 97),
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(double.infinity, maxDimension * 4),
                    painter: PathPainter(
                      startY: maxDimension * 4 - 100,
                      signalYPositions: getSignalYPositions(),
                    ),
                  ),
                  ...buildSignals(maxDimension),
                  ...trees,
                  Positioned(
                    left: characterPosition.dx - 12.5,
                    top: characterPosition.dy - 30,
                    child: Image.asset('assets/old_circle.png',
                        width: 30, height: 30),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Points: $points',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    )),
                SizedBox(height: 10),
                Text('Signal Timer: $signalTimerCounter',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    )),
                SizedBox(height: 10),
                if (warningMessage.isNotEmpty)
                  Text(warningMessage,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.red,
                      )),
              ],
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
  final List<double> signalYPositions;

  PathPainter({required this.startY, required this.signalYPositions});

  @override
  void paint(Canvas canvas, Size size) {
    Paint pathPaint = Paint()
      ..color = Color.fromARGB(255, 70, 77, 85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 100.0;

    Paint centerLinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path verticalPath = Path();
    verticalPath.moveTo(size.width / 2, startY);
    verticalPath.lineTo(size.width / 2, 0);

    canvas.drawPath(verticalPath, pathPaint);
    canvas.drawPath(verticalPath, centerLinePaint);

    for (double y in signalYPositions) {
      Path horizontalPath = Path();
      horizontalPath.moveTo(0, y);
      horizontalPath.lineTo(size.width, y);

      canvas.drawPath(horizontalPath, pathPaint);
      canvas.drawPath(horizontalPath, centerLinePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
