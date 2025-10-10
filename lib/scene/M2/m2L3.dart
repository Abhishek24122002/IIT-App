import 'dart:math';
import 'dart:ui';
import 'package:alzymer/scene/M2/M2L1.dart';
import 'package:alzymer/scene/M3/m3L2.dart';
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

import 'm2L2.dart';

class M2L3 extends StatefulWidget {
  @override
  _M2L3State createState() => _M2L3State();
}

class _M2L3State extends State<M2L3> {
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
  int M2L3Point = 0;
  List<Widget> levels = [M2L1(), M2L2(), M2L3(), M2L4()];
  int currentLevelIndex = 2;
  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  bool dragging = false;
  ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
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
        }

        if ((characterPosition - housePosition).distance <= 30 &&
            iceCreamReached) {
          M2L3Point = 1;
          updateFirebaseDataM2L3();
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        const edgePadding = 300.0;

        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        final currentVerticalOffset = _verticalController.offset;
        final currentHorizontalOffset = _horizontalController.offset;

        final visibleTop = currentVerticalOffset;
        final visibleBottom = visibleTop + screenHeight;

        final visibleLeft = currentHorizontalOffset;
        final visibleRight = visibleLeft + screenWidth;

        double? targetVerticalOffset;
        double? targetHorizontalOffset;

        if (characterPosition.dy < visibleTop + edgePadding) {
          targetVerticalOffset = (characterPosition.dy - edgePadding)
              .clamp(0.0, _verticalController.position.maxScrollExtent);
        } else if (characterPosition.dy > visibleBottom - edgePadding) {
          targetVerticalOffset =
              (characterPosition.dy - screenHeight + edgePadding)
                  .clamp(0.0, _verticalController.position.maxScrollExtent);
        }

        if (characterPosition.dx < visibleLeft + edgePadding) {
          targetHorizontalOffset = (characterPosition.dx - edgePadding)
              .clamp(0.0, _horizontalController.position.maxScrollExtent);
        } else if (characterPosition.dx > visibleRight - edgePadding) {
          targetHorizontalOffset =
              (characterPosition.dx - screenWidth + edgePadding)
                  .clamp(0.0, _horizontalController.position.maxScrollExtent);
        }

        if (targetVerticalOffset != null) {
          _verticalController.animateTo(
            targetVerticalOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }

        if (targetHorizontalOffset != null) {
          _horizontalController.animateTo(
            targetHorizontalOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions to complete level'),
          content: Text(
            
            'Help Grandpa find his way home! \n\n Touch and slide his picture along the path on the map. Stay on the road and try not to go off track. When you reach home, the level will be complete. Remember the talk from the previous level; it will help you finish this task.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showIceCreamPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thank You!'),
          content: Text('Thank you grandpa for Sweets! Now we can go home'),
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

  void moveCharacter(Offset delta) {
    Offset newPosition = characterPosition + delta;

    if (isOnPath(newPosition)) {
      setState(() {
        characterPosition = newPosition;

        if ((characterPosition - icecreamPosition).distance <= 15 &&
            !iceCreamReached) {
          iceCreamReached = true;
          showIceCreamPopup();
        }

        if ((characterPosition - housePosition).distance <= 30 &&
            iceCreamReached) {
          M2L3Point = 1;
          updateFirebaseDataM2L3();
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToKeepCharacterVisible();
      });
    }
  }

  void updateFirebaseDataM2L3() async {
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
            'M2L3Point': M2L3Point,
          });
        } else {
          // If the document exists, update the fields
          await scoreDocRef.update({
            'M2L3Point': M2L3Point,
          });
        }
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  void scrollToKeepCharacterVisible() {
    const double margin = 50.0; // How close to edge before scrolling
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final currentHorizontalOffset = _horizontalController.offset;
    final currentVerticalOffset = _verticalController.offset;

    final visibleLeft = currentHorizontalOffset;
    final visibleRight = visibleLeft + screenWidth;
    final visibleTop = currentVerticalOffset;
    final visibleBottom = visibleTop + screenHeight;

    double? targetHorizontalOffset;
    double? targetVerticalOffset;

    // Check horizontal position and adjust scroll only if character moves near edges
    if (characterPosition.dx < visibleLeft + margin) {
      // Move scroll left just enough to keep margin
      targetHorizontalOffset = (characterPosition.dx - margin)
          .clamp(0.0, _horizontalController.position.maxScrollExtent);
    } else if (characterPosition.dx > visibleRight - margin) {
      // Move scroll right just enough to keep margin
      targetHorizontalOffset = (characterPosition.dx - screenWidth + margin)
          .clamp(0.0, _horizontalController.position.maxScrollExtent);
    }

    // Check vertical position and adjust scroll only if character moves near edges
    if (characterPosition.dy < visibleTop + margin) {
      // Scroll up gently
      targetVerticalOffset = (characterPosition.dy - margin)
          .clamp(0.0, _verticalController.position.maxScrollExtent);
    } else if (characterPosition.dy > visibleBottom - margin) {
      // Scroll down gently
      targetVerticalOffset = (characterPosition.dy - screenHeight + margin)
          .clamp(0.0, _verticalController.position.maxScrollExtent);
    }

    // Animate only if needed and small distance to avoid big jumps
    if (targetHorizontalOffset != null) {
      final double diff =
          (targetHorizontalOffset - currentHorizontalOffset).abs();
      if (diff > 1) {
        // animate only if significant scroll needed
        _horizontalController.animateTo(
          targetHorizontalOffset,
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    }

    if (targetVerticalOffset != null) {
      final double diff = (targetVerticalOffset - currentVerticalOffset).abs();
      if (diff > 1) {
        _verticalController.animateTo(
          targetVerticalOffset,
          duration: Duration(milliseconds: 150),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scrollable game area
          SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            physics: NeverScrollableScrollPhysics(),
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: NeverScrollableScrollPhysics(),
              child: Container(
                width: 1200,
                height: 800,
                color: Color.fromARGB(255, 110, 238, 117),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(1200, 800),
                      painter: PathPainter(),
                    ),
                    Positioned(
                      left: initialPosition.dx - 25,
                      top: initialPosition.dy - 18,
                      child: Image.asset('assets/school.png',
                          width: 50, height: 50),
                    ),
                    Positioned(
                      left: housePosition.dx - 27,
                      top: housePosition.dy - 40,
                      child:
                          Image.asset('assets/home.png', width: 50, height: 50),
                    ),
                    Positioned(
                      left: icecreamPosition.dx - 27,
                      top: icecreamPosition.dy - 40,
                      child: Image.asset('assets/Sweets_Store.png',
                          width: 60, height: 60),
                    ),
                    if (lakeVisible)
                      Positioned(
                        left: 455,
                        top: 130,
                        child: Image.asset('assets/lake.png',
                            width: 120, height: 120),
                      ),
                    Positioned(
                      left: 390 - 25,
                      top: 350 - 40,
                      child: Image.asset('assets/bakery.png',
                          width: 70, height: 70),
                    ),
                    Positioned(
                      left: 630 - 25,
                      top: 350 - 28,
                      child:
                          Image.asset('assets/shop.png', width: 50, height: 50),
                    ),
                    Positioned(
                      left: characterPosition.dx - 12,
                      top: characterPosition.dy - 12,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          final localTouch = details.localPosition;
                          if ((localTouch - Offset(12, 12)).distance <= 30) {
                            // Start dragging and disable scroll
                            setState(() {
                              dragging = true;
                            });
                          }
                        },
                        onPanUpdate: (details) {
                          if (!dragging) return;

                          Offset newPosition =
                              characterPosition + details.delta;

                          if (isOnPath(newPosition)) {
                            setState(() {
                              characterPosition = newPosition;

                              if ((characterPosition - icecreamPosition)
                                          .distance <=
                                      10 &&
                                  !iceCreamReached) {
                                iceCreamReached = true;
                                showIceCreamPopup();
                              }

                              if ((characterPosition - housePosition)
                                          .distance <=
                                      30 &&
                                  iceCreamReached) {
                                M2L3Point = 1;
                                updateFirebaseDataM2L3();
                              }
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              scrollToKeepCharacterVisible();
                            });
                          }
                        },
                        onPanEnd: (_) {
                          // Stop dragging and re-enable scroll
                          setState(() {
                            dragging = false;
                          });
                        },
                        child: Image.asset(
                          'assets/old_circle.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overlay widgets outside scroll area
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: Padding(
          //     padding: const EdgeInsets.all(15.0),
          //     child: Joystick(
          //       base: JoystickBase(size: 160, withBorderCircle: false),
          //       mode: JoystickMode.all,
          //       listener: (details) {
          //         onJoystickUpdate(details.x, details.y);
          //       },
          //     ),
          //   ),
          // ),

//

          if (showHintButton)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(100, 15, 15, 30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: showHint,
                  child: Text(
                    'Show Hint',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                  'Take Left From The Lake For Sweet Shop',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          if ((characterPosition - housePosition).distance <= 30)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: iceCreamReached
                    ? ElevatedButton(
                        onPressed: () {
                          M2L3Point = 1;
                          updateFirebaseDataM2L3();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => M2L4()),
                          );
                        },
                        child: Text('Next Module'),
                      )
                    : Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10.0,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          'Buy Sweet first',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Timer? _movementTimer;

  void stopMoving() {
    _movementTimer?.cancel();
  }

  void startMoving(Offset direction) {
    _movementTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      moveCharacter(direction);
    });
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
