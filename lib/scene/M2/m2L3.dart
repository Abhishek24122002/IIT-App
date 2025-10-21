// import 'dart:math';
// import 'dart:ui';
// import 'package:alzymer/scene/M2/M2L1.dart';
// import 'package:alzymer/scene/M3/m3L2.dart';
// import 'package:alzymer/scene/M2/M2L4.dart';
// import 'package:alzymer/scene/M2/m2L5.dart';
// import 'package:alzymer/scene/M3/m3L1.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_joystick/flutter_joystick.dart';
// import 'package:vector_math/vector_math_64.dart' as vector;
// import 'dart:async';

// import 'm2L2.dart';
// import 'package:alzymer/components/next_level_button.dart';

// class M2L3 extends StatefulWidget {
//   @override
//   _M2L3State createState() => _M2L3State();
// }

// class _M2L3State extends State<M2L3> {
//   Offset initialPosition = Offset(50, 330);
//   Offset housePosition = Offset(750, 70);
//   Offset icecreamPosition = Offset(520, 70);
//   Offset characterPosition = Offset(50, 300);
//   final double speed = 6.0; // Speed factor to increase movement speed
//   bool iceCreamReached = false; // Boolean to track if ice cream is reached
//   bool lakeVisible = false; // Boolean to track if lake is visible
//   bool showHintButton =
//       false; // Boolean to track if hint button should be shown
//   bool showHintMessage =
//       false; // Boolean to track if hint message should be shown
//   String? gender;
//   int M2L3Point = 0;
//   List<Widget> levels = [M2L1(), M2L2(), M2L3(), M2L4()];
//   int currentLevelIndex = 2;
//   late ScrollController _horizontalController;
//   late ScrollController _verticalController;
//   bool dragging = false;
//   ScrollPhysics scrollPhysics = const AlwaysScrollableScrollPhysics();

//   @override
//   void initState() {
//     super.initState();
//     Firebase.initializeApp();
//     fetchGender();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeLeft,
//       DeviceOrientation.landscapeRight,
//     ]);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showInstructions();
//     });
//     _horizontalController = ScrollController();
//     _verticalController = ScrollController();
//     // Start a timer to show the hint button after 10 seconds
//     Timer(Duration(seconds: 10), () {
//       setState(() {
//         showHintButton = true;
//       });
//     });
//   }

//   void onJoystickUpdate(double x, double y) {
//     double distance = sqrt(x * x + y * y) * speed;
//     double angle = atan2(y, x);

//     Offset newPosition = Offset(
//       characterPosition.dx + distance * cos(angle),
//       characterPosition.dy + distance * sin(angle),
//     );

//     if (isOnPath(newPosition)) {
//       setState(() {
//         characterPosition = newPosition;

//         if ((characterPosition - icecreamPosition).distance <= 10 &&
//             !iceCreamReached) {
//           iceCreamReached = true;
//           showIceCreamPopup();
//         }

//         if ((characterPosition - housePosition).distance <= 30 &&
//             iceCreamReached) {
//           M2L3Point = 1;
//           updateFirebaseDataM2L3();
//         }
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         const edgePadding = 300.0;

//         final screenHeight = MediaQuery.of(context).size.height;
//         final screenWidth = MediaQuery.of(context).size.width;

//         final currentVerticalOffset = _verticalController.offset;
//         final currentHorizontalOffset = _horizontalController.offset;

//         final visibleTop = currentVerticalOffset;
//         final visibleBottom = visibleTop + screenHeight;

//         final visibleLeft = currentHorizontalOffset;
//         final visibleRight = visibleLeft + screenWidth;

//         double? targetVerticalOffset;
//         double? targetHorizontalOffset;

//         if (characterPosition.dy < visibleTop + edgePadding) {
//           targetVerticalOffset = (characterPosition.dy - edgePadding)
//               .clamp(0.0, _verticalController.position.maxScrollExtent);
//         } else if (characterPosition.dy > visibleBottom - edgePadding) {
//           targetVerticalOffset =
//               (characterPosition.dy - screenHeight + edgePadding)
//                   .clamp(0.0, _verticalController.position.maxScrollExtent);
//         }

//         if (characterPosition.dx < visibleLeft + edgePadding) {
//           targetHorizontalOffset = (characterPosition.dx - edgePadding)
//               .clamp(0.0, _horizontalController.position.maxScrollExtent);
//         } else if (characterPosition.dx > visibleRight - edgePadding) {
//           targetHorizontalOffset =
//               (characterPosition.dx - screenWidth + edgePadding)
//                   .clamp(0.0, _horizontalController.position.maxScrollExtent);
//         }

//         if (targetVerticalOffset != null) {
//           _verticalController.animateTo(
//             targetVerticalOffset,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }

//         if (targetHorizontalOffset != null) {
//           _horizontalController.animateTo(
//             targetHorizontalOffset,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//           );
//         }
//       });
//     }
//   }
//   void _showInstructions() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Instructions to complete level'),
//           content: Text(
            
//             'Help Grandpa find his way home! \n\n Touch and slide his picture along the path on the map. Stay on the road and try not to go off track. When you reach home, the level will be complete. Remember the talk from the previous level; it will help you finish this task.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void showIceCreamPopup() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Thank You!'),
//           content: Text('Thank you grandpa for Sweets! Now we can go home'),
//           actions: [
//             TextButton(
//               child: Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void showNextLevelPopup() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Congratulations'),
//           content: Text(' Level Completed '),
//           actions: [
//             TextButton(
//               child: Text('Next Level'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   bool isOnPath(Offset position) {
//     // Define the paths
//     Path path = Path();
//     path.moveTo(50, 330);
//     path.quadraticBezierTo(100, -120, 240, 250);
//     path.quadraticBezierTo(350, 300, 550, 250);
//     path.quadraticBezierTo(660, 200, 750, 70);

//     Path path2 = Path();
//     path2.moveTo(840, 130);
//     path2.quadraticBezierTo(550, 250, 520, 60);

//     // path from school to turning point
//     Path path3 = Path();
//     path3.moveTo(50, 330);
//     path3.quadraticBezierTo(140, 220, 240, 250);

//     //path from turning (top A curve) to icecream
//     Path path4 = Path();
//     path4.moveTo(120, 85);
//     path4.quadraticBezierTo(300, 43, 560, 140);

//     Path path5 = Path();
//     path5.moveTo(240, 250);
//     path5.quadraticBezierTo(260, 350, 390, 350);

//     //Extra obstacle 2
//     Path path6 = Path();
//     path6.moveTo(520, 250);
//     path6.quadraticBezierTo(520, 300, 630, 350);

//     Iterable<PathMetric> combinedPathMetrics = path
//         .computeMetrics()
//         .followedBy(path2.computeMetrics())
//         .followedBy(path3.computeMetrics())
//         .followedBy(path4.computeMetrics())
//         .followedBy(path5.computeMetrics())
//         .followedBy(path6.computeMetrics());

//     for (PathMetric metric in combinedPathMetrics) {
//       for (double i = 0; i < metric.length; i += 1.0) {
//         Tangent? tangent = metric.getTangentForOffset(i);
//         if (tangent != null) {
//           Offset point = tangent.position;
//           if ((position - point).distance <= 15) {
//             return true;
//           }
//         }
//       }
//     }

//     return false;
//   }

//   void showHint() {
//     setState(() {
//       lakeVisible = true;
//       showHintMessage = true;
//     });

//     // Hide the hint message after 5 seconds
//     Timer(Duration(seconds: 5), () {
//       setState(() {
//         showHintMessage = false;
//       });
//     });
//   }

//   void fetchGender() async {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? user = auth.currentUser;

//     if (user != null) {
//       FirebaseFirestore firestore = FirebaseFirestore.instance;
//       DocumentSnapshot<Map<String, dynamic>> snapshot =
//           await firestore.collection('users').doc(user.uid).get();

//       setState(() {
//         gender = snapshot.get('gender');
//       });
//     }
//   }

//   String getCurrentUserUid() {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? user = auth.currentUser;
//     return user?.uid ?? '';
//   }

//   void moveCharacter(Offset delta) {
//     Offset newPosition = characterPosition + delta;

//     if (isOnPath(newPosition)) {
//       setState(() {
//         characterPosition = newPosition;

//         if ((characterPosition - icecreamPosition).distance <= 15 &&
//             !iceCreamReached) {
//           iceCreamReached = true;
//           showIceCreamPopup();
//         }

//         if ((characterPosition - housePosition).distance <= 30 &&
//             iceCreamReached) {
//           M2L3Point = 1;
//           updateFirebaseDataM2L3();
//         }
//       });

//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         scrollToKeepCharacterVisible();
//       });
//     }
//   }

//   void updateFirebaseDataM2L3() async {
//     try {
//       FirebaseFirestore firestore = FirebaseFirestore.instance;
//       String userUid = getCurrentUserUid();

//       if (userUid.isNotEmpty) {
//         // Reference to the user's document
//         DocumentReference userDocRef =
//             firestore.collection('users').doc(userUid);

//         // Reference to the 'score' document with document ID 'M2'
//         DocumentReference scoreDocRef =
//             userDocRef.collection('score').doc('M2');

//         // Check if the 'M2' document exists
//         DocumentSnapshot scoreDocSnapshot = await scoreDocRef.get();

//         if (!scoreDocSnapshot.exists) {
//           // If the document doesn't exist, create it with the initial score
//           await scoreDocRef.set({
//             'M2L3Point': M2L3Point,
//           });
//         } else {
//           // If the document exists, update the fields
//           await scoreDocRef.update({
//             'M2L3Point': M2L3Point,
//           });
//         }
//       }
//     } catch (e) {
//       print('Error updating data: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _horizontalController.dispose();
//     _verticalController.dispose();
//     super.dispose();
//   }

//   void scrollToKeepCharacterVisible() {
//     const double margin = 50.0; // How close to edge before scrolling
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     final currentHorizontalOffset = _horizontalController.offset;
//     final currentVerticalOffset = _verticalController.offset;

//     final visibleLeft = currentHorizontalOffset;
//     final visibleRight = visibleLeft + screenWidth;
//     final visibleTop = currentVerticalOffset;
//     final visibleBottom = visibleTop + screenHeight;

//     double? targetHorizontalOffset;
//     double? targetVerticalOffset;

//     // Check horizontal position and adjust scroll only if character moves near edges
//     if (characterPosition.dx < visibleLeft + margin) {
//       // Move scroll left just enough to keep margin
//       targetHorizontalOffset = (characterPosition.dx - margin)
//           .clamp(0.0, _horizontalController.position.maxScrollExtent);
//     } else if (characterPosition.dx > visibleRight - margin) {
//       // Move scroll right just enough to keep margin
//       targetHorizontalOffset = (characterPosition.dx - screenWidth + margin)
//           .clamp(0.0, _horizontalController.position.maxScrollExtent);
//     }

//     // Check vertical position and adjust scroll only if character moves near edges
//     if (characterPosition.dy < visibleTop + margin) {
//       // Scroll up gently
//       targetVerticalOffset = (characterPosition.dy - margin)
//           .clamp(0.0, _verticalController.position.maxScrollExtent);
//     } else if (characterPosition.dy > visibleBottom - margin) {
//       // Scroll down gently
//       targetVerticalOffset = (characterPosition.dy - screenHeight + margin)
//           .clamp(0.0, _verticalController.position.maxScrollExtent);
//     }

//     // Animate only if needed and small distance to avoid big jumps
//     if (targetHorizontalOffset != null) {
//       final double diff =
//           (targetHorizontalOffset - currentHorizontalOffset).abs();
//       if (diff > 1) {
//         // animate only if significant scroll needed
//         _horizontalController.animateTo(
//           targetHorizontalOffset,
//           duration: Duration(milliseconds: 150),
//           curve: Curves.easeOut,
//         );
//       }
//     }

//     if (targetVerticalOffset != null) {
//       final double diff = (targetVerticalOffset - currentVerticalOffset).abs();
//       if (diff > 1) {
//         _verticalController.animateTo(
//           targetVerticalOffset,
//           duration: Duration(milliseconds: 150),
//           curve: Curves.easeOut,
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Scrollable game area
//           SingleChildScrollView(
//             controller: _verticalController,
//             scrollDirection: Axis.vertical,
//             physics: NeverScrollableScrollPhysics(),
//             child: SingleChildScrollView(
//               controller: _horizontalController,
//               scrollDirection: Axis.horizontal,
//               physics: NeverScrollableScrollPhysics(),
//               child: Container(
//                 width: 1200,
//                 height: 800,
//                 color: Color.fromARGB(255, 110, 238, 117),
//                 child: Stack(
//                   children: [
//                     CustomPaint(
//                       size: Size(1200, 800),
//                       painter: PathPainter(),
//                     ),
//                     Positioned(
//                       left: initialPosition.dx - 25,
//                       top: initialPosition.dy - 18,
//                       child: Image.asset('assets/school.png',
//                           width: 50, height: 50),
//                     ),
//                     Positioned(
//                       left: housePosition.dx - 27,
//                       top: housePosition.dy - 40,
//                       child:
//                           Image.asset('assets/home.png', width: 50, height: 50),
//                     ),
//                     Positioned(
//                       left: icecreamPosition.dx - 27,
//                       top: icecreamPosition.dy - 40,
//                       child: Image.asset('assets/Sweets_Store.png',
//                           width: 60, height: 60),
//                     ),
//                     if (lakeVisible)
//                       Positioned(
//                         left: 455,
//                         top: 130,
//                         child: Image.asset('assets/lake.png',
//                             width: 120, height: 120),
//                       ),
//                     Positioned(
//                       left: 390 - 25,
//                       top: 350 - 40,
//                       child: Image.asset('assets/bakery.png',
//                           width: 70, height: 70),
//                     ),
//                     Positioned(
//                       left: 630 - 25,
//                       top: 350 - 28,
//                       child:
//                           Image.asset('assets/shop.png', width: 50, height: 50),
//                     ),
//                     Positioned(
//                       left: characterPosition.dx - 12,
//                       top: characterPosition.dy - 12,
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.translucent,
//                         onPanStart: (details) {
//                           final localTouch = details.localPosition;
//                           if ((localTouch - Offset(12, 12)).distance <= 30) {
//                             // Start dragging and disable scroll
//                             setState(() {
//                               dragging = true;
//                             });
//                           }
//                         },
//                         onPanUpdate: (details) {
//                           if (!dragging) return;

//                           Offset newPosition =
//                               characterPosition + details.delta;

//                           if (isOnPath(newPosition)) {
//                             setState(() {
//                               characterPosition = newPosition;

//                               if ((characterPosition - icecreamPosition)
//                                           .distance <=
//                                       10 &&
//                                   !iceCreamReached) {
//                                 iceCreamReached = true;
//                                 showIceCreamPopup();
//                               }

//                               if ((characterPosition - housePosition)
//                                           .distance <=
//                                       30 &&
//                                   iceCreamReached) {
//                                 M2L3Point = 1;
//                                 updateFirebaseDataM2L3();
//                               }
//                             });
//                             WidgetsBinding.instance.addPostFrameCallback((_) {
//                               scrollToKeepCharacterVisible();
//                             });
//                           }
//                         },
//                         onPanEnd: (_) {
//                           // Stop dragging and re-enable scroll
//                           setState(() {
//                             dragging = false;
//                           });
//                         },
//                         child: Image.asset(
//                           'assets/old_circle.png',
//                           width: 40,
//                           height: 40,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Overlay widgets outside scroll area
//           // Align(
//           //   alignment: Alignment.bottomRight,
//           //   child: Padding(
//           //     padding: const EdgeInsets.all(15.0),
//           //     child: Joystick(
//           //       base: JoystickBase(size: 160, withBorderCircle: false),
//           //       mode: JoystickMode.all,
//           //       listener: (details) {
//           //         onJoystickUpdate(details.x, details.y);
//           //       },
//           //     ),
//           //   ),
//           // ),

// //

//           if (showHintButton)
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(100, 15, 15, 30),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.amber,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18.0),
//                     ),
//                     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   ),
//                   onPressed: showHint,
//                   child: Text(
//                     'Show Hint',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ),

//           if (showHintMessage)
//             Positioned(
//               top: 40,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 10,
//                       spreadRadius: 1,
//                       offset: Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   'Take Left From The Lake For Sweet Shop',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),

//           if ((characterPosition - housePosition).distance <= 30)
//   Align(
//     alignment: Alignment.center,
//     child: Container(
//       padding: const EdgeInsets.all(16.0),
//       child: iceCreamReached
//           ? NextLevelButton(
//               label: 'Next Level',
//               onPressed: () {
//                 M2L3Point = 1;
//                 updateFirebaseDataM2L3();

//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => M2L4()),
//                 );
//               },
//             )
//           : Container(
//               padding: const EdgeInsets.all(20.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.0),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 10.0,
//                     offset: Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'Buy Sweet first',
//                 style: TextStyle(
//                   fontSize: 20.0,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.redAccent,
//                 ),
//               ),
//             ),
//     ),
//   ),

//         ],
//       ),
//     );
//   }

//   Timer? _movementTimer;

//   void stopMoving() {
//     _movementTimer?.cancel();
//   }

//   void startMoving(Offset direction) {
//     _movementTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
//       moveCharacter(direction);
//     });
//   }
// }

// class PathPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Color.fromARGB(255, 236, 205, 162)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 40.0;

//     // Path from school to home
//     Path path = Path();
//     path.moveTo(50, 330);
//     path.quadraticBezierTo(100, -120, 240, 250);
//     path.quadraticBezierTo(350, 300, 550, 250);
//     path.quadraticBezierTo(700, 200, 750, 70);

//     // path to icecream
//     Path path2 = Path();
//     path2.moveTo(840, 130);
//     path2.quadraticBezierTo(550, 250, 520, 60);

//     // path from school to turning point
//     Path path3 = Path();
//     path3.moveTo(50, 330);
//     path3.quadraticBezierTo(140, 220, 240, 250);

//     //path from turning (top A curve) to icecream
//     Path path4 = Path();
//     path4.moveTo(120, 85);
//     path4.quadraticBezierTo(300, 43, 560, 140);

//     //Extra obstacle 1
//     Path path5 = Path();
//     path5.moveTo(240, 250);
//     path5.quadraticBezierTo(260, 350, 390, 350);

//     //Extra obstacle 2
//     Path path6 = Path();
//     path6.moveTo(520, 250);
//     path6.quadraticBezierTo(520, 300, 630, 350);

//     canvas.drawPath(path, paint);
//     canvas.drawPath(path2, paint);     
//     canvas.drawPath(path3, paint);
//     canvas.drawPath(path4, paint);
//     canvas.drawPath(path5, paint);
//     canvas.drawPath(path6, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:alzymer/components/next_level_button.dart';
import 'package:alzymer/scene/M2/M2L1.dart';
import 'package:alzymer/scene/M2/M2L4.dart';
import 'package:alzymer/scene/M2/m2L2.dart';
import 'package:alzymer/scene/M2/m2L5.dart';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M2L3 extends StatefulWidget {
  @override
  _M2L3State createState() => _M2L3State();
}

class _M2L3State extends State<M2L3> {
  // --- Base design dimensions (original artboard)
  static const double designWidth = 1200.0;
  static const double designHeight = 400.0;

  // Horizontal shrink factor (0.8 = reduce width by 20%)
  static const double horizontalShrink = 1.5;

  // Logical (design) positions - unchanged base coordinates from your original file
  // We'll scale these in build() according to actual screen size
  static const Offset baseInitialPosition = Offset(50, 330);
  static const Offset baseHousePosition = Offset(750, 70);
  static const Offset baseIcecreamPosition = Offset(520, 70);
  static const Offset baseCharacterPosition = Offset(50, 300);
  static const Offset baseBakeryPosition = Offset(390, 350);
  static const Offset baseShopPosition = Offset(630, 350);
  static const Offset baseLakePosition = Offset(455, 130);

  // Game state
  Offset characterPosition = baseCharacterPosition; // will be scaled in build()
  bool iceCreamReached = false;
  bool lakeVisible = false;
  bool showHintButton = false;
  bool showHintMessage = false;
  String? gender;
  int M2L3Point = 0;

  late ScrollController _horizontalController;
  late ScrollController _verticalController;
  bool dragging = false;

  Timer? _movementTimer;

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
      if (mounted) {
        setState(() {
          showHintButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _movementTimer?.cancel();
    super.dispose();
  }

  // -------------------- Firebase helper --------------------
  void fetchGender() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await firestore.collection('users').doc(user.uid).get();

        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            gender = snapshot.get('gender');
          });
        }
      }
    } catch (e) {
      // keep silent in production but print for debugging
      print('fetchGender error: $e');
    }
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM2L3() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference scoreDocRef =
            firestore.collection('users').doc(userUid).collection('score').doc('M2');

        DocumentSnapshot scoreDocSnapshot = await scoreDocRef.get();

        if (!scoreDocSnapshot.exists) {
          await scoreDocRef.set({
            'M2L3Point': M2L3Point,
          });
        } else {
          await scoreDocRef.update({
            'M2L3Point': M2L3Point,
          });
        }
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  // -------------------- UI helpers --------------------
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

  void showHint() {
    setState(() {
      lakeVisible = true;
      showHintMessage = true;
    });

    // Hide the hint message after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          showHintMessage = false;
        });
      }
    });
  }

  // -------------------- Movement / collisions --------------------
  void moveCharacter(Offset delta, PathChecker checker) {
    Offset newPosition = characterPosition + delta;

    if (checker.isOnPath(newPosition)) {
      setState(() {
        characterPosition = newPosition;

        if ((characterPosition - checker.scaledIcecreamPosition).distance <=
                15 &&
            !iceCreamReached) {
          iceCreamReached = true;
          showIceCreamPopup();
        }

        if ((characterPosition - checker.scaledHousePosition).distance <= 30 &&
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

  void startMoving(Offset direction, PathChecker checker) {
    stopMoving();
    _movementTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      moveCharacter(direction, checker);
    });
  }

  void stopMoving() {
    _movementTimer?.cancel();
    _movementTimer = null;
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
      targetHorizontalOffset = (characterPosition.dx - margin)
          .clamp(0.0, _horizontalController.position.maxScrollExtent);
    } else if (characterPosition.dx > visibleRight - margin) {
      targetHorizontalOffset = (characterPosition.dx - screenWidth + margin)
          .clamp(0.0, _horizontalController.position.maxScrollExtent);
    }

    // Check vertical position and adjust scroll only if character moves near edges
    if (characterPosition.dy < visibleTop + margin) {
      targetVerticalOffset = (characterPosition.dy - margin)
          .clamp(0.0, _verticalController.position.maxScrollExtent);
    } else if (characterPosition.dy > visibleBottom - margin) {
      targetVerticalOffset = (characterPosition.dy - screenHeight + margin)
          .clamp(0.0, _verticalController.position.maxScrollExtent);
    }

    if (targetHorizontalOffset != null) {
      final double diff = (targetHorizontalOffset - currentHorizontalOffset).abs();
      if (diff > 1) {
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

  // -------------------- Build --------------------
  @override
  Widget build(BuildContext context) {
    // compute scales based on available screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double scaleX = (screenWidth / designWidth);
    final double scaleY = (screenHeight / designHeight);

    // incorporate horizontal shrink
    final double sx = scaleX * horizontalShrink;
    final double sy = scaleY;

    // Map (canvas) size in logical (scaled) coordinates
    final double mapWidth = designWidth * sx;
    final double mapHeight = designHeight * sy;

    // helper to scale base offsets
    Offset s(Offset base) => Offset(base.dx * sx, base.dy * sy);

    // compute scaled positions used in multiple places and path checking
    final Offset scaledInitialPosition = s(baseInitialPosition);
    final Offset scaledHousePosition = s(baseHousePosition);
    final Offset scaledIcecreamPosition = s(baseIcecreamPosition);
    final Offset scaledCharacterStart = s(baseCharacterPosition);
    final Offset scaledBakery = s(baseBakeryPosition);
    final Offset scaledShop = s(baseShopPosition);
    final Offset scaledLake = s(baseLakePosition);

    // Initialize characterPosition on first build if it's still the base (unscaled)
    if (characterPosition == baseCharacterPosition ||
        characterPosition == baseCharacterPosition) {
      characterPosition = scaledCharacterStart;
    }

    // Create a PathChecker for path membership tests (uses same scaled geometry)
    final PathChecker checker = PathChecker(
      sx: sx,
      sy: sy,
      scaledIcecreamPosition: scaledIcecreamPosition,
      scaledHousePosition: scaledHousePosition,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Scrollable game area
          SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                width: mapWidth,
                height: mapHeight,
                color: const Color.fromARGB(255, 110, 238, 117),
                child: Stack(
                  children: [
                    // Draw the scaled paths
                    CustomPaint(
                      size: Size(mapWidth, mapHeight),
                      painter: PathPainter(sx: sx, sy: sy),
                    ),

                    // school icon
                    Positioned(
                      left: scaledInitialPosition.dx - 30 * sx,
                      top: scaledInitialPosition.dy - 35 * sy,
                      child: Image.asset('assets/school.png',
                          width: 80 * sx, height: 80 * sy),
                    ),

                    // home icon
                    Positioned(
                      left: scaledHousePosition.dx - 45 * sx,
                      top: scaledHousePosition.dy - 60 * sy,
                      child:
                          Image.asset('assets/home.png', width: 90 * sx, height: 90 * sy),
                    ),

                    // ice cream
                    Positioned(
                      left: scaledIcecreamPosition.dx - 40 * sx,
                      top: scaledIcecreamPosition.dy - 70 * sy,
                      child: Image.asset('assets/Sweets_Store.png',
                          width: 90 * sx, height: 90 * sy),
                    ),

                    // lake (hint)
                    if (lakeVisible)
                      Positioned(
                        left: scaledLake.dx,
                        top: scaledLake.dy,
                        child:
                            Image.asset('assets/lake.png', width: 120 * sx, height: 120 * sy),
                      ),

                    // bakery
                    Positioned(
                      left: scaledBakery.dx - 45 * sx,
                      top: scaledBakery.dy - 75 * sy,
                      child: Image.asset('assets/bakery.png',
                          width: 140 * sx, height: 140 * sy),
                    ),

                    // shop
                    Positioned(
                      left: scaledShop.dx - 30 * sx,
                      top: scaledShop.dy - 35 * sy,
                      child: Image.asset('assets/shop.png',
                          width: 80 * sx, height: 80 * sy),
                    ),

                    // character (draggable)
                    Positioned(
                      left: characterPosition.dx - 12 * sx,
                      top: characterPosition.dy - 12 * sy,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onPanStart: (details) {
                          final localTouch = details.localPosition;
                          if ((localTouch - Offset(12 * sx, 12 * sy)).distance <= 30 * sx) {
                            setState(() {
                              dragging = true;
                            });
                          }
                        },
                        onPanUpdate: (details) {
                          if (!dragging) return;

                          Offset newPosition =
                              characterPosition + details.delta;

                          if (checker.isOnPath(newPosition)) {
                            setState(() {
                              characterPosition = newPosition;

                              if ((characterPosition - scaledIcecreamPosition).distance <=
                                      10 * sx &&
                                  !iceCreamReached) {
                                iceCreamReached = true;
                                showIceCreamPopup();
                              }

                              if ((characterPosition - scaledHousePosition).distance <=
                                      30 * sx &&
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
                          setState(() {
                            dragging = false;
                          });
                        },
                        child: Image.asset(
                          'assets/old_circle.png',
                          width: 40 * sx,
                          height: 40 * sy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Show Hint button
          if (showHintButton)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(100 * sx, 15 * sy, 15 * sx, 30 * sy),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24 * sx, vertical: 12 * sy),
                  ),
                  onPressed: showHint,
                  child: Text(
                    'Show Hint',
                    style: TextStyle(fontSize: 16 * sx, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // hint message
          if (showHintMessage)
            Positioned(
              top: 40 * sy,
              right: 20 * sx,
              child: Container(
                padding: EdgeInsets.all(16.0 * sy),
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
                  style: TextStyle(fontSize: 16 * sx, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // Next level / Buy sweet notice
          if ((characterPosition - scaledHousePosition).distance <= 30 * sx)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: iceCreamReached
                    ? NextLevelButton(
                        label: 'Next Level',
                        onPressed: () {
                          M2L3Point = 1;
                          updateFirebaseDataM2L3();

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => M2L4()),
                          );
                        },
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
                            fontSize: 20.0 * sx,
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
}

// -------------------- Path checking helper --------------------
// This class mirrors the same path shapes used by PathPainter but in scaled coordinates.
// It provides isOnPath() used for collision checking with the character.
class PathChecker {
  final double sx;
  final double sy;
  final Offset scaledIcecreamPosition;
  final Offset scaledHousePosition;

  PathChecker({
    required this.sx,
    required this.sy,
    required this.scaledIcecreamPosition,
    required this.scaledHousePosition,
  });

  // Helper to scale a base offset (base coords are from original design)
  Offset s(double x, double y) => Offset(x * sx, y * sy);

  bool isOnPath(Offset position) {
    // Recreate all paths scaled (same shape as painter)
    Path path = Path();
    path.moveTo(s(50, 330).dx, s(50, 330).dy);
    path.quadraticBezierTo(s(100, -120).dx, s(100, -120).dy, s(240, 250).dx, s(240, 250).dy);
    path.quadraticBezierTo(s(350, 300).dx, s(350, 300).dy, s(550, 250).dx, s(550, 250).dy);
    path.quadraticBezierTo(s(700, 200).dx, s(700, 200).dy, s(750, 70).dx, s(750, 70).dy);

    Path path2 = Path();
    path2.moveTo(s(840, 130).dx, s(840, 130).dy);
    path2.quadraticBezierTo(s(550, 250).dx, s(550, 250).dy, s(520, 60).dx, s(520, 60).dy);

    Path path3 = Path();
    path3.moveTo(s(50, 330).dx, s(50, 330).dy);
    path3.quadraticBezierTo(s(140, 220).dx, s(140, 220).dy, s(240, 250).dx, s(240, 250).dy);

    Path path4 = Path();
    path4.moveTo(s(120, 85).dx, s(120, 85).dy);
    path4.quadraticBezierTo(s(300, 43).dx, s(300, 43).dy, s(560, 140).dx, s(560, 140).dy);

    Path path5 = Path();
    path5.moveTo(s(240, 250).dx, s(240, 250).dy);
    path5.quadraticBezierTo(s(260, 350).dx, s(260, 350).dy, s(390, 350).dx, s(390, 350).dy);

    Path path6 = Path();
    path6.moveTo(s(520, 250).dx, s(520, 250).dy);
    path6.quadraticBezierTo(s(520, 300).dx, s(520, 300).dy, s(630, 350).dx, s(630, 350).dy);

    Iterable<PathMetric> combined = path
        .computeMetrics()
        .followedBy(path2.computeMetrics())
        .followedBy(path3.computeMetrics())
        .followedBy(path4.computeMetrics())
        .followedBy(path5.computeMetrics())
        .followedBy(path6.computeMetrics());

    // tolerance should scale with sx (so it's proportional on different screens)
    final double tolerance = 15.0 * sx;

    for (PathMetric metric in combined) {
      // iterate along path at step proportional to screen density
      final double step = max(1.0, metric.length / (metric.length / (1.0 * sx + 1.0)));
      for (double i = 0; i < metric.length; i += step) {
        Tangent? tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          Offset point = tangent.position;
          if ((position - point).distance <= tolerance) {
            return true;
          }
        }
      }
    }

    return false;
  }
}

// -------------------- Responsive painter --------------------
class PathPainter extends CustomPainter {
  final double sx;
  final double sy;

  PathPainter({required this.sx, required this.sy});

  // helper to scale coordinates
  Offset s(double x, double y) => Offset(x * sx, y * sy);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 236, 205, 162)
      ..style = PaintingStyle.stroke
      // scale stroke width with horizontal scale as primary factor
      ..strokeWidth = 40.0 * ((sx + sy) / 2.0);

    // Path from school to home
    Path path = Path();
    path.moveTo(s(50, 330).dx, s(50, 330).dy);
    path.quadraticBezierTo(s(100, -120).dx, s(100, -120).dy, s(240, 250).dx, s(240, 250).dy);
    path.quadraticBezierTo(s(350, 300).dx, s(350, 300).dy, s(550, 250).dx, s(550, 250).dy);
    path.quadraticBezierTo(s(700, 200).dx, s(700, 200).dy, s(750, 70).dx, s(750, 70).dy);

    // path to icecream
    Path path2 = Path();
    path2.moveTo(s(840, 130).dx, s(840, 130).dy);
    path2.quadraticBezierTo(s(550, 250).dx, s(550, 250).dy, s(520, 60).dx, s(520, 60).dy);

    // path from school to turning point
    Path path3 = Path();
    path3.moveTo(s(50, 330).dx, s(50, 330).dy);
    path3.quadraticBezierTo(s(140, 220).dx, s(140, 220).dy, s(240, 250).dx, s(240, 250).dy);

    // path from turning to icecream
    Path path4 = Path();
    path4.moveTo(s(120, 85).dx, s(120, 85).dy);
    path4.quadraticBezierTo(s(300, 43).dx, s(300, 43).dy, s(560, 140).dx, s(560, 140).dy);

    // Extra obstacle 1
    Path path5 = Path();
    path5.moveTo(s(240, 250).dx, s(240, 250).dy);
    path5.quadraticBezierTo(s(260, 350).dx, s(260, 350).dy, s(390, 350).dx, s(390, 350).dy);

    // Extra obstacle 2
    Path path6 = Path();
    path6.moveTo(s(520, 250).dx, s(520, 250).dy);
    path6.quadraticBezierTo(s(520, 300).dx, s(520, 300).dy, s(630, 350).dx, s(630, 350).dy);

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);
    canvas.drawPath(path5, paint);
    canvas.drawPath(path6, paint);
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    // Repaint if scale changes
    return oldDelegate.sx != sx || oldDelegate.sy != sy;
  }
}
