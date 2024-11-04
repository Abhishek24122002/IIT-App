import 'dart:math';
import 'dart:ui';
import 'package:alzymer/scene/M2/M2L1.dart';
import 'package:alzymer/scene/M2/m2L3.dart';
import 'package:alzymer/scene/M2/M2L4.dart';
import 'package:alzymer/scene/M2/m2L5.dart';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:async';

class M2L2 extends StatefulWidget {
  @override
  _M2L2State createState() => _M2L2State();
}

class _M2L2State extends State<M2L2> {
  Offset initialPosition = Offset(50, 330);
  Offset housePosition = Offset(750, 70);
  Offset icecreamPosition = Offset(520, 70);
  Offset characterPosition = Offset(50, 300);
  final double speed = 6.0; // Speed factor to increase movement speed
  bool iceCreamReached = false; // Boolean to track if ice cream is reached
  bool lakeVisible = false; // Boolean to track if lake is visible
  bool showHintButton =
      false; // Boolean to track if hint button should be shown
  bool showHintMessage =
      false; // Boolean to track if hint message should be shown
  String? gender;
  int M2L2Point = 0;
  List<Widget> levels = [M2L1(), M2L2(), M2L3(), M2L4(), M2L5()];
  int currentLevelIndex = 1;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Start a timer to show the hint button after 10 seconds
    Timer(Duration(seconds: 10), () {
      setState(() {
        showHintButton = true;
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
        if ((characterPosition - icecreamPosition).distance <= 10 &&
            !iceCreamReached) {
          iceCreamReached = true;
          showIceCreamPopup();
        } // Check if the character is close enough to the house and has bought ice cream
        if ((characterPosition - housePosition).distance <= 30 &&
            iceCreamReached) {
          M2L2Point = 1;
          updateFirebaseDataM2L2();
        }
      });
    }
  }

  void showIceCreamPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thank You!'),
          content: Text('Thank you grandpa for ice cream! Now we can go home'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showNextLevelPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations'),
          content: Text(' Level Completed '),
          actions: [
            TextButton(
              child: Text('Next Module'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isOnPath(Offset position) {
    // Define the paths
    Path path = Path();
    path.moveTo(50, 330);
    path.quadraticBezierTo(100, -120, 240, 250);
    path.quadraticBezierTo(350, 300, 550, 250);
    path.quadraticBezierTo(660, 200, 750, 70);

    Path path2 = Path();
    path2.moveTo(840, 130);
    path2.quadraticBezierTo(550, 250, 520, 60);

    // path from school to turning point
    Path path3 = Path();
    path3.moveTo(50, 330);
    path3.quadraticBezierTo(140, 220, 240, 250);

    //path from turning (top A curve) to icecream
    Path path4 = Path();
    path4.moveTo(120, 85);
    path4.quadraticBezierTo(300, 43, 560, 140);

    Path path5 = Path();
    path5.moveTo(240, 250);
    path5.quadraticBezierTo(260, 350, 390, 350);

    //Extra obstacle 2
    Path path6 = Path();
    path6.moveTo(520, 250);
    path6.quadraticBezierTo(520, 300, 630, 350);

    Iterable<PathMetric> combinedPathMetrics = path
        .computeMetrics()
        .followedBy(path2.computeMetrics())
        .followedBy(path3.computeMetrics())
        .followedBy(path4.computeMetrics())
        .followedBy(path5.computeMetrics())
        .followedBy(path6.computeMetrics());

    for (PathMetric metric in combinedPathMetrics) {
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

  void showHint() {
    setState(() {
      lakeVisible = true;
      showHintMessage = true;
    });

    // Hide the hint message after 5 seconds
    Timer(Duration(seconds: 5), () {
      setState(() {
        showHintMessage = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 110, 238, 117),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: PathPainter(),
            ),
            Positioned(
              left: initialPosition.dx - 25,
              top: initialPosition.dy - 18,
              child: Image.asset('assets/school.png', width: 50, height: 50),
            ),
            Positioned(
              left: characterPosition.dx - 10,
              top: characterPosition.dy - 10,
              child:
                  Image.asset('assets/old_circle.png', width: 25, height: 25),
            ),
            Positioned(
              left: housePosition.dx - 27,
              top: housePosition.dy - 40,
              child: Image.asset('assets/home.png', width: 50, height: 50),
            ),
            Positioned(
              left: icecreamPosition.dx - 27,
              top: icecreamPosition.dy - 40,
              child: Image.asset('assets/icecream.png', width: 60, height: 60),
            ),
            if (lakeVisible)
              Positioned(
                left: 455,
                top: 130,
                child: Image.asset('assets/lake.png', width: 120, height: 120),
              ),
            Positioned(
              left: 390 - 25,
              top: 350 - 40,
              child: Image.asset('assets/bakery.png', width: 70, height: 70),
            ),
            Positioned(
              left: 630 - 25,
              top: 350 - 28,
              child: Image.asset('assets/shop.png', width: 50, height: 50),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
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
            ),
            if (showHintButton)
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(100, 15, 15, 30),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // Button background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18.0), // Rounded edges
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12), // Padding inside the button
                    ),
                    onPressed: showHint,
                    child: Text(
                      'Show Hint',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            if (showHintMessage)
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    'Take Left From The Lake For Icecream Shop',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if ((characterPosition - housePosition).distance <= 30)
              Align(
                alignment: Alignment.center,
                child: Container(
                  // color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: iceCreamReached
                      ? ElevatedButton(
                          onPressed: () {
                            M2L2Point = 1;
                            updateFirebaseDataM2L2();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => M2L3()),
                            );
                          },
                          child: Text('Next Module'),
                        )
                      : Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white, // White background
                            borderRadius:
                                BorderRadius.circular(12.0), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Shadow color
                                blurRadius: 10.0, // Spread of the shadow
                                offset: Offset(0, 5), // Position of the shadow
                              ),
                            ],
                          ),
                          child: Text(
                            'Buy ice cream first',
                            style: TextStyle(
                              fontSize: 20.0, // Slightly larger text
                              fontWeight: FontWeight.bold, // Bold text
                              color: Colors
                                  .redAccent, // Attractive color for the text
                            ),
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 236, 205, 162)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40.0;

    // Path from school to home
    Path path = Path();
    path.moveTo(50, 330);
    path.quadraticBezierTo(100, -120, 240, 250);
    path.quadraticBezierTo(350, 300, 550, 250);
    path.quadraticBezierTo(700, 200, 750, 70);

    // path to icecream
    Path path2 = Path();
    path2.moveTo(840, 130);
    path2.quadraticBezierTo(550, 250, 520, 60);

    // path from school to turning point
    Path path3 = Path();
    path3.moveTo(50, 330);
    path3.quadraticBezierTo(140, 220, 240, 250);

    //path from turning (top A curve) to icecream
    Path path4 = Path();
    path4.moveTo(120, 85);
    path4.quadraticBezierTo(300, 43, 560, 140);

    //Extra obstacle 1
    Path path5 = Path();
    path5.moveTo(240, 250);
    path5.quadraticBezierTo(260, 350, 390, 350);

    //Extra obstacle 2
    Path path6 = Path();
    path6.moveTo(520, 250);
    path6.quadraticBezierTo(520, 300, 630, 350);

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);
    canvas.drawPath(path5, paint);
    canvas.drawPath(path6, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
