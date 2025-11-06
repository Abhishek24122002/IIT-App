import 'dart:async';
import 'dart:math';
import 'package:alzymer/scene/M3/M3L3.dart';
import 'package:alzymer/scene/M3/M3L4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'm3L1_2.dart';
import 'm3L2.dart';
import 'm3L3_2.dart';
import 'm3L3_3.dart';
import 'm3L4_2.dart';

class M3L1 extends StatefulWidget {
  @override
  _M3L1State createState() => _M3L1State();
}

class _M3L1State extends State<M3L1> {
  Offset? characterPosition; // Initialize characterPosition as nullable
  final double speed = 20.0;
  late ScrollController _scrollController;
  late Timer signalTimer;
  int signalTimerCounter = 0;
  bool isSignalRed = true;
  int points = 0;
  List<double> crossedSignals = [];
  List<Widget> trees = [];
  double previousYPosition = 0.0;
  bool hasShownRedSignalToast = false;
  bool islevelcompleted = false; // Flag to track level completion
  bool isPositionLoaded = false; // Flag to track if position is loaded
  String? gender;
  int M3L1Point = 0;
  List<Widget> levels = [M3L1(), M3L2(), M3L3(), M3L3_2(), M3L3_3(),M3L4(),M3L4_2()];
  int currentLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    
    fetchGender();
    // Lock orientation to landscape only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,

  ]);
    _scrollController = ScrollController();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      double maxDimension = max(screenWidth, screenHeight);

      setState(() {
        characterPosition = Offset(screenWidth / 2, maxDimension * 13 - 100);
        previousYPosition = characterPosition!.dy;
        isPositionLoaded = true; // Mark position as loaded
      });

      startSignalTimer();
      generateTrees(maxDimension);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(mounted){
        scrollToCharacterPosition(characterPosition!);
        showInstructionsPopup(context);
        }
        
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

  void updateFirebaseDataM3L1() async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getCurrentUserUid();

    if (userUid.isNotEmpty) {
      // Reference to the user's document
      DocumentReference userDocRef = firestore.collection('users').doc(userUid);

      // Reference to the 'score' document with document ID 'M3'
      DocumentReference scoreDocRef = userDocRef.collection('score').doc('M3');

      // Check if the 'M2' document exists
      DocumentSnapshot scoreDocSnapshot = await scoreDocRef.get();
      int totalSignals = getSignalYPositions().length;

      if (!scoreDocSnapshot.exists) {
        // If the document doesn't exist, create it with the initial score
        await scoreDocRef.set({
          'M3L1Point': M3L1Point,
          // 'M3L1_Green_Signal': points,
          

          'Without_timer_Green_Signal': points,
          'M3L1_Total_Signal': totalSignals,
        });
      } else {
        // If the document exists, update the fields
        await scoreDocRef.update({
          'M3L1Point': M3L1Point,
          // 'M3L1_Green_Signal': points,

          'Without_timer_Green_Signal': points,
          'M3L1_Total_Signal': totalSignals,
        });
      }
    }
  } catch (e) {
    print('Error updating data: $e');
  }
}

  void showInstructionsPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 10),
              Text('Instructions', style: TextStyle(fontSize: 24)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blueAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your Task is To Bring Groceries From The Mall.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              // SizedBox(height: 10),
              // Row(
              //   children: [
              //     Icon(Icons.traffic, color: Colors.blueGrey),
              //     SizedBox(width: 10),
              //     Expanded(
              //       child: Text(
              //         'There are 13 Signals Between Home and The Mall.',
              //         style: TextStyle(fontSize: 16),
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_walk, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cross The Signal Only When it is Green For Pedestrians.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Stop When The Signal is Red.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.yellow),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You Will Be Rewarded With A Point For Each Correct Crossing On Green.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),  
            ],
          )),
          actions: [
            TextButton(
              child: Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  

 @override
void dispose() {
  if (signalTimer.isActive) {
    signalTimer.cancel();
  }
  _scrollController.dispose();
  super.dispose();
}


  void startSignalTimer() {
  final random = Random();

  signalTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (!islevelcompleted && mounted) {
      setState(() {
        if (signalTimerCounter > 0) {
          signalTimerCounter--;
        } else {
          isSignalRed = !isSignalRed;

          // Randomize the next signal duration between 6 and 12 seconds
          signalTimerCounter = 6 + random.nextInt(7); // Random number between 6 and 12
        }
      });
    }
  });
}



  void onJoystickUpdate(double x, double y) {
    if (islevelcompleted) return; // Stop all actions if level is completed

    double distance = sqrt(x * x + y * y) * speed;
    double angle = atan2(y, x);

    Offset newPosition = Offset(
      characterPosition!.dx + distance * cos(angle),
      characterPosition!.dy + distance * sin(angle),
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
          crossedSignals.add(signalYPosition);
        });
        showToastMessage('Crossed on Green Signal', Colors.green);
      } else if (isSignalRed && newPosition.dy < previousYPosition) {
        showToastMessage('Crossed on Red Signal', Colors.red);
      }
    }
  }

  previousYPosition = newPosition.dy;
}


  void showToastMessage(String message, Color color) {
    if (!islevelcompleted) { // Prevent showing toast if level is completed
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  List<double> getSignalYPositions() {
    double maxDimension = max(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    double signalSpacing = 500.0;
    List<double> signalPositions = [];

    for (double y = maxDimension * 13 - 100; y > 0; y -= signalSpacing) {
      if (y == maxDimension * 13 - 100) continue;
      signalPositions.add(y - 15);
    }

    return signalPositions;
  }

  void scrollToPosition(double joystickY) {
    if (islevelcompleted) return; // Stop scrolling if level is completed

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
    if (islevelcompleted) return; // Stop scrolling if level is completed

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
        position.dy <= maxDimension * 13 - 100;
  }

  List<Widget> buildSignals(double maxDimension) {
    List<Widget> signals = [];
    double signalSpacing = 500.0;
    double signalX = MediaQuery.of(context).size.width / 2 - 80;

    for (double y = maxDimension * 13 - 100; y > 0; y -= signalSpacing) {
      if (y == maxDimension * 13 - 100) continue;
      signals.add(Positioned(
        left: signalX - 5,
        top: y - 15,
        child: Image.asset(
          isSignalRed ? 'assets/red.png' : 'assets/green.png',
          width: 35,
          height: 140,
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
    double leftTreeX = roadCenterX - roadWidth / 2 - 80;
    double rightTreeX = roadCenterX + roadWidth / 2 + 50;
    List<double> signalPositions = getSignalYPositions();

    for (double y = maxDimension * 13 - 150; y > 50; y -= treeSpacing) {
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

  void showCongratulationsPopup(BuildContext context) {
  if (islevelcompleted) return; // Prevent showing multiple popups
  islevelcompleted = true; // Mark the level as completed

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false, // Disable closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '🎉🏆Congratulations!🏆🎉',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level Completed with',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text(
                '$points Points',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Repeat Level'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => M3L1()),
                );
              },
            ),
            TextButton(
              child: Text('Next Level'),
              onPressed: () {
                Navigator.of(context).pop();
                navigateToNextLevel();
              },
            ),
          ],
        );
      },
    );
  });
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double maxDimension = max(screenWidth, screenHeight);
    double mallPositionY = 0.0; 

    // Check if the character has crossed all signals
    if (points >= getSignalYPositions().length && !islevelcompleted) {
  M3L1Point = 1;

  updateFirebaseDataM3L1();
  showCongratulationsPopup(context);
}

    bool hasReachedMall =
          characterPosition!.dy <= (mallPositionY + 100); // Add some buffer to ensure condition is met
          

int totalSignals = getSignalYPositions().length;
      if (hasReachedMall) {
        M3L1Point=1;
        M3L1_Total_Signal: totalSignals;

       
        updateFirebaseDataM3L1();
        Future.delayed(Duration.zero, () => showCongratulationsPopup(context));
      }
      // Skeleton screen (loading indicator) until position is loaded
    // Show a loading indicator while the position is being loaded
    if (!isPositionLoaded || characterPosition == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Display a loading spinner
        ),
      );
    }

    // After the position is loaded, proceed with the rest of the UI
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: maxDimension * 13,
                color: Color.fromARGB(255, 167, 216, 97),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(double.infinity, maxDimension * 4),
                      painter: PathPainter(
                        startY: maxDimension * 13 - 100,
                        signalYPositions: getSignalYPositions(),
                      ),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 40,
                      top: maxDimension * 13 - 100,
                      child: Image.asset('assets/home.png', width: 80, height: 80),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width / 2 - 75,
                      top: mallPositionY,
                      child:
                          Image.asset('assets/mall.png', width: 150, height: 150),
                    ),
                    ...buildSignals(maxDimension),
                    ...trees,
                    Positioned(
                      left: characterPosition!.dx - 12.5,
                      top: characterPosition!.dy - 30,
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
                  // Row(
                  //   children: [
                  //     Icon(Icons.timer, size: 24, color: Colors.black),
                  //     SizedBox(width: 5),
                  //     Text('$signalTimerCounter',
                  //         style: TextStyle(
                  //           fontSize: 24,
                  //           color: Colors.black,
                  //         )),
                  //   ],
                  // ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              right: 6,
              child: Joystick(
                base: JoystickBase(
                  size: 180,
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
      ));
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

