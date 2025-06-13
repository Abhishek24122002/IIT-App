// import 'package:alzymer/ScoreManager.dart';
// import 'package:alzymer/ScoreManagerModule.dart';
import 'package:alzymer/scene/M2/M2L3.dart';
import 'package:alzymer/scene/M2/M2L4.dart';
import 'package:alzymer/scene/M2/m2L2.dart';
import 'package:alzymer/scene/M2/m2L5.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'M2L1.dart';

void main() {
  runApp(MaterialApp(
    home: M2L2(),
  ));
}

class M2L2 extends StatefulWidget {
  @override
  _M2L2State createState() => _M2L2State();
}

class _M2L2State extends State<M2L2> with SingleTickerProviderStateMixin {
  double xPosition = 20.0;
  double yPosition = 20.0;
  double step = 20.0;
  bool isAtSchool = false; // Flag to track if character is at school
  AnimationController? _controller;
  int moveCount = 0; // Track number of moves
  bool showHintButton = false; // Flag to show hint button
  Timer? hintTimer; // Timer to show hint button
  bool showHintPath = false; // Flag to show hint path
  String? gender;
  int M2L2Point = 0;
  bool hint = false;
  bool showHintMessage = false; // Flag to show hint message
  Timer? hintMessageTimer; // Timer to hide hint message
  List<Widget> levels = [M2L1(), M2L2(), M2L3(), M2L4()];
  int currentLevelIndex = 1;

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();


  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    // ScoreManager().initializeScore('M2L2Point');
    fetchGender();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start a timer to show hint button after 30 seconds
    hintTimer = Timer(Duration(seconds: 30), () {
      setState(() {
        showHintButton = true;
      });
    });
  }

  void fetchGender() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('users').doc(user.uid).get();

      setState(() {
        gender = snapshot.get('gender');
      });
    }
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM2L2() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M2'
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M2');

        // Check if the 'M2' document exists
        DocumentSnapshot scoreDocSnapshot = await scoreDocRef.get();

        if (!scoreDocSnapshot.exists) {
          // If the document doesn't exist, create it with the initial score
          await scoreDocRef.set({
            'M2L2Point': M2L2Point,
          });
        } else {
          // If the document exists, update the fields
          await scoreDocRef.update({
            'M2L2Point': M2L2Point,
          });
        }
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    hintTimer?.cancel();
    hintMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Module 2 level 2'),
          toolbarHeight: 30,
        ),
        backgroundColor: const Color.fromARGB(255, 110, 238, 117),
        body: Stack(
          children: [
            // Scrollable map
            SingleChildScrollView(
  controller: _horizontalController,
  scrollDirection: Axis.horizontal,
  child: SingleChildScrollView(
    controller: _verticalController,
    scrollDirection: Axis.vertical,
    child: SizedBox(
      width: 800,
      height: 600,
                  child: Stack(
                    children: [
                      // Map background
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RoadPainter(showHintPath),
                        ),
                      ),
                      // Static assets
                      Positioned(
                        left: 0,
                        top: 25,
                        child: Image.asset('assets/home.png',
                            width: 80, height: 80),
                      ),
                      Positioned(
                        left: 710,
                        top: 30,
                        child: Image.asset('assets/hospital.png',
                            width: 70, height: 70),
                      ),
                      Positioned(
                        left: 700,
                        top: 100,
                        child: Image.asset('assets/book.png',
                            width: 100, height: 100),
                      ),
                      Positioned(
                        top: 260,
                        left: 700,
                        child: Image.asset('assets/boy2_circle.png',
                            width: 30, height: 30),
                      ),

                      // Hint overlays
                      if (showHintPath) ...[
                        Positioned(
                          left: 262,
                          top: 135,
                          child: Image.asset('assets/lake.png',
                              width: 130, height: 120),
                        ),
                        Positioned(
                          top: 215,
                          left: 720,
                          child: Image.asset('assets/school.png',
                              width: 80, height: 80),
                        ),
                        Positioned(
                          right: 210,
                          top: 85,
                          child: Image.asset('assets/post.png',
                              width: 70, height: 70),
                        ),
                      ],

                      // Animated character
                      AnimatedPositioned(
                        left: xPosition,
                        top: yPosition,
                        duration: Duration(milliseconds: 200),
                        child: Image.asset('assets/old1.png',
                            width: 80, height: 70),
                      ),

                      // Hint button

                      // Hint message
                      if (showHintMessage)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            color: Color.fromARGB(245, 226, 224, 224),
                            child: Text(
                              'Take Right from Post Box',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Control buttons floating at bottom of screen
            Positioned(
              bottom: 65,
              left: 10,
              child: GestureDetector(
                onLongPressStart: (_) => moveContinuously(moveLeft),
                onLongPressEnd: (_) => stopMovement(),
                child: FloatingActionButton(
                  onPressed: moveLeft,
                  child: Icon(Icons.arrow_left),
                  backgroundColor: Colors.lightBlueAccent,
                  elevation: 5,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: 65,
              child: GestureDetector(
                onLongPressStart: (_) => moveContinuously(moveUp),
                onLongPressEnd: (_) => stopMovement(),
                child: FloatingActionButton(
                  onPressed: moveUp,
                  child: Icon(Icons.arrow_upward),
                  backgroundColor: Colors.lightBlueAccent,
                  elevation: 5,
                ),
              ),
            ),
            Positioned(
              bottom: 65,
              left: 120,
              child: GestureDetector(
                onLongPressStart: (_) => moveContinuously(moveRight),
                onLongPressEnd: (_) => stopMovement(),
                child: FloatingActionButton(
                  onPressed: moveRight,
                  child: Icon(Icons.arrow_right),
                  backgroundColor: Colors.lightBlueAccent,
                  elevation: 5,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 65,
              child: GestureDetector(
                onLongPressStart: (_) => moveContinuously(moveDown),
                onLongPressEnd: (_) => stopMovement(),
                child: FloatingActionButton(
                  onPressed: moveDown,
                  child: Icon(Icons.arrow_downward),
                  backgroundColor: Colors.lightBlueAccent,
                  elevation: 5,
                ),
              ),
            ),

            if (showHintButton && !isAtSchool)
              Positioned(
                bottom: 20,
                right: 100,
                child: ElevatedButton(
                  onPressed: showHint,
                  child: Text('Show Hint'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ));
  }

  void ensureCharacterIsVisible() {
  const double viewWidth = 400;  // screen width
  const double viewHeight = 300; // screen height
  const double charWidth = 80;
  const double charHeight = 70;

  double targetX = xPosition - viewWidth / 2 + charWidth / 2;
  double targetY = yPosition - viewHeight / 2 + charHeight / 2;

  _horizontalController.animateTo(
    targetX.clamp(0, _horizontalController.position.maxScrollExtent),
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );

  _verticalController.animateTo(
    targetY.clamp(0, _verticalController.position.maxScrollExtent),
    duration: Duration(milliseconds: 300),
    curve: Curves.easeOut,
  );
}


  void moveUp() {
    setState(() {
      if (!isOutOfBounds(xPosition, yPosition - step)) {
        yPosition -= step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
    ensureCharacterIsVisible();
  }

  void moveDown() {
    setState(() {
      if (!isOutOfBounds(xPosition, yPosition + step)) {
        yPosition += step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
    ensureCharacterIsVisible();
  }

  void moveLeft() {
    setState(() {
      if (!isOutOfBounds(xPosition - step, yPosition)) {
        xPosition -= step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
    ensureCharacterIsVisible();
  }

  void moveRight() {
    setState(() {
      if (!isOutOfBounds(xPosition + step, yPosition)) {
        xPosition += step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
    ensureCharacterIsVisible();
  }

  void incrementMoveCount() {
    moveCount++;
    if (moveCount >= 20) {
      setState(() {
        showHintButton = true;
      });
    }
  }

  void checkIfAtSchool() {
    // Check if character is at the school (adjust coordinates as needed)
    if (xPosition >= 680 && yPosition == 220) {
      setState(() {
        isAtSchool = true;
        M2L2Point = 1;
      });
      // ScoreManager().updateUserScore('M2L2Point', 1); // Update Firebase score
      showConversationDialog(); // Show next level dialog
    }
    updateFirebaseDataM2L2();
    // ScoreManager.updateUserScore(1);
  }

  bool isOutOfBounds(double x, double y) {
    // Define the bounds of the roads with multiple paths
    if ((x >= 20 && x <= 120 && y == 20) ||
        (x == 120 && y >= 10 && y <= 100) ||
        (x >= 120 && x <= 220 && y == 100) ||
        (x == 220 && y >= 100 && y <= 200) ||
        (x >= 210 && x <= 360 && y == 200) ||
        (x == 360 && y >= 100 && y <= 200) ||
        (x >= 360 && x <= 680 && y == 100) ||
        (x == 460 && y >= 20 && y <= 100) ||
        (x >= 460 && x <= 600 && y == 20) ||
        (x == 600 && y >= 10 && y <= 220) ||
        (x >= 600 && x <= 680 && y == 220) ||
        (x >= 460 && x <= 680 && y == 20)) {
      return false;
    }
    return true;
  }

  void showHint() {
    setState(() {
      showHintPath = true;
      showHintMessage = true;
      showHintButton = false;
    });

    // Hide hint message after 5 seconds
    hintMessageTimer = Timer(Duration(seconds: 5), () {
      setState(() {
        showHintMessage = false;
      });
    });
  }

  Timer? movementTimer;

  void moveContinuously(Function moveFunction) {
    movementTimer = Timer.periodic(Duration(milliseconds: 150), (timer) {
      moveFunction();
    });
  }

  void stopMovement() {
    movementTimer?.cancel();
  }

  void navigateToNextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ]);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => levels[currentLevelIndex + 1]),
      );
    }
  }

  void showConversationDialog() {
    List<Map<String, String>> conversation = [
      {'speaker': 'Grandchild', 'message': 'Grandpa, I want Sweet!'},
      {
        'speaker': 'Grandpa',
        'message': 'Ok, we will first go to the Sweet shop and then home.'
      },
    ];

    int currentMessageIndex = 0;

    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (currentMessageIndex == 0) {
              Future.delayed(Duration(seconds: 1), () {
                setState(() {
                  currentMessageIndex++;
                });
              });
            }

            return AlertDialog(
              title: Text('Conversation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Child's message and image (always shown initially)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(conversation[0]['message']!),
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        'assets/boy2_circle.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                  SizedBox(
                      height: 20), // Add some space between the two messages
                  // Grandpa's image (always shown initially) and text (shown after delay)
                  Row(
                    children: [
                      Image.asset(
                        'assets/old1.png',
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            currentMessageIndex > 0
                                ? conversation[1]['message']!
                                : '                      ',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    navigateToNextLevel(); // Close the dialog
                    setState(() {
                      isAtSchool = true; // Show the Next Level button
                    });
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class RoadPainter extends CustomPainter {
  final bool showHintPath;

  RoadPainter(this.showHintPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(255, 236, 205, 162)
      ..strokeWidth = 30
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    path1.moveTo(50, 85);

    path1.lineTo(160, 85);
    path1.lineTo(160, 165);
    path1.lineTo(260, 165);
    path1.lineTo(260, 265);
    path1.lineTo(400, 265);
    path1.lineTo(400, 165);
    path1.lineTo(500, 165);
    path1.lineTo(500, 80);
    path1.lineTo(640, 80);
    path1.lineTo(640, 275);
    path1.lineTo(730, 275);

    final path3 = Path();
    path3.moveTo(650, 80);
    path3.lineTo(730, 80);

    final path2 = Path();
    path2.moveTo(500, 165);
    path2.lineTo(730, 165);

    // Draw both paths
    canvas.drawPath(path1, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
