import 'package:alzymer/ScoreManager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(MaterialApp(
    home: M2L1(),
  ));
}

class M2L1 extends StatefulWidget {
  @override
  _M2L1State createState() => _M2L1State();
}

class _M2L1State extends State<M2L1> with SingleTickerProviderStateMixin {
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
  int M2L1Point = 0;

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

  void updateFirebaseDataM2L1() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef = firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M2'
        DocumentReference scoreDocRef = userDocRef.collection('score').doc('M2');


        // Update the fields in the 'score' document
        await scoreDocRef.update({
          'M2L1Point': M2L1Point,
        });
        
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    hintTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 level 1'),
      ),
      backgroundColor: const Color.fromARGB(255, 110, 238, 117),
      body: Stack(
        children: [
          // Road (Path)
          Positioned.fill(
            child: CustomPaint(
              painter: RoadPainter(showHintPath),
            ),
          ),
          // House Image
          Positioned(
            left: 0,
            top: 25,
            child: Image.asset(
              'assets/home.png', // Path to the house image
              width: 80,
              height: 80,
            ),
          ),
          Positioned(
            left: 262,
            top: 135,
            child: Image.asset(
              'assets/lake.png', // Path to the house image
              width: 130,
              height: 120,
            ),
          ),
          Positioned(
            right: 350,
            top: 55,
            child: Image.asset(
              'assets/tree.png', // Path to the house image
              width: 100,
              height: 100,
            ),
          ),

          Positioned(
            right: 40,
            top: 35,
            child: Image.asset(
              'assets/hospital.png', // Path to the hospital image
              width: 70,
              height: 70,
            ),
          ),
          Positioned(
            right: 210,
            top: 85,
            child: Image.asset(
              'assets/temple.png', // Path to the hospital image
              width: 70,
              height: 70,
            ),
          ),
          // School Image
          Positioned(
            right: 40,
            bottom: 10,
            child: Image.asset(
              'assets/school.png', // Path to the school image
              width: 80,
              height: 80,
            ),
          ),
          // Character
          AnimatedPositioned(
            left: xPosition,
            top: yPosition,
            duration: Duration(milliseconds: 200),
            child: Image.asset(
              'assets/old1.png', // Path to the character image
              width: 80,
              height: 70,
            ),
          ),
          // Coordinates Display
          // Positioned(
          //   top: 20,
          //   left: 20,
          //   child: Container(
          //     color: Colors.white.withOpacity(0.7),
          //     padding: EdgeInsets.all(8),
          //     child: Text(
          //       'x: $xPosition, y: $yPosition',
          //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //     ),
          //   ),
          // ),
          // Next Level Button (Show when at school)
          if (isAtSchool)
          
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to next level or perform next level action
                      print('Next level action here');
                    },
                    child: Text('Next Level'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
            
          // Hint Button (Show when hint conditions are met)
          if (showHintButton && !isAtSchool)
            Positioned(
              bottom: 20,
              left: 460,
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
          // Control Buttons
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
        ],
      ),
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
  }

  void moveDown() {
    setState(() {
      if (!isOutOfBounds(xPosition, yPosition + step)) {
        yPosition += step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (!isOutOfBounds(xPosition - step, yPosition)) {
        xPosition -= step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
  }

  void moveRight() {
    setState(() {
      if (!isOutOfBounds(xPosition + step, yPosition)) {
        xPosition += step;
        checkIfAtSchool();
        incrementMoveCount();
      }
    });
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
        M2L1Point = 1;
      });
    }
    updateFirebaseDataM2L1();
    ScoreManager.updateUserScore(1);
  }

  bool isOutOfBounds(double x, double y) {
    // Define the bounds of the roads with multiple paths
    if ((x >= 20 && x <= 120 && y == 20) ||
        (x == 120 && y >= 20 && y <= 100) ||
        (x >= 120 && x <= 220 && y == 100) ||
        (x == 220 && y >= 100 && y <= 200) ||
        (x >= 210 && x <= 360 && y == 200) ||
        (x == 360 && y >= 100 && y <= 200) ||
        (x >= 360 && x <= 460 && y == 100) ||
        (x == 460 && y >= 20 && y <= 100) ||
        (x >= 460 && x <= 600 && y == 20) ||
        (x == 600 && y >= 20 && y <= 220) ||
        (x >= 600 && x <= 680 && y == 220) ||
        (x >= 460 && x <= 680 && y == 20)) {
      return false;
    }
    return true;
  }

  void showHint() {
    setState(() {
      showHintPath = true;
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
}

class RoadPainter extends CustomPainter {
  final bool showHintPath;

  RoadPainter(this.showHintPath);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ..color = Color.fromARGB(255, 158, 158, 158)
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
    path1.lineTo(500, 85);
    path1.lineTo(640, 85);
    path1.lineTo(640, 275);
    path1.lineTo(730, 275);

    final path3 = Path();
    path3.moveTo(650, 85);
    path3.lineTo(730, 85);

    // Draw both paths
    canvas.drawPath(path1, paint);
    canvas.drawPath(path3, paint);

    // Draw hint path if showHintPath is true
    if (showHintPath) {
      final hintPaint = Paint()
        ..color = Colors.amber
        ..strokeWidth = 20
        ..style = PaintingStyle.stroke;

      final hintPath = Path();
      hintPath.moveTo(50, 85);

      hintPath.lineTo(160, 85);
      hintPath.lineTo(160, 165);
      hintPath.lineTo(260, 165);
      hintPath.lineTo(260, 265);
      hintPath.lineTo(400, 265);
      hintPath.lineTo(400, 165);
      hintPath.lineTo(500, 165);
      hintPath.lineTo(500, 85);
      hintPath.lineTo(640, 85);
      hintPath.lineTo(640, 275);
      hintPath.lineTo(730, 275);

      canvas.drawPath(hintPath, hintPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
