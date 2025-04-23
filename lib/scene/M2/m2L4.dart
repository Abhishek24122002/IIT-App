import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L2_old.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:firebase_core/firebase_core.dart';

class M2L4 extends StatefulWidget {
  @override
  _M2L4State createState() => _M2L4State();
}

class _M2L4State extends State<M2L4> with SingleTickerProviderStateMixin {
  int points = 0;
  int M2L4Point = 0;
  List<bool> sweetDropped = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ]; // Track each sweet drop
  double progress = 0.0;
  late AnimationController _glowController;
  final GlobalKey boyKey = GlobalKey(); // Key to locate the boy image

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    Firebase.initializeApp();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM2L4() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M1'
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M4');

        // Update the fields in the 'score' document
        await scoreDocRef.update({
          'M2L4Point': M2L4Point,
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void handlesweetDrop() {
    setState(() {
      progress = points / sweetDropped.length;
      if (progress == 1.0) {
        _glowController.forward().then((_) {
          _glowController.stop();
          M2L4Point = 1;
          _showCongratsDialog();
          updateFirebaseDataM2L4();
          // Long vibration for level completion
          Vibration.vibrate(duration: 1000);
        });
      }
    });
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have completed the game!'),
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

  bool _issweetInMouth(DragTargetDetails<String> details) {
    // Get the position of the boy image
    final RenderBox box =
        boyKey.currentContext!.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    // Boy's image size and mouth position
    final boyWidth = box.size.width;
    final boyHeight = box.size.height;

    // Define mouth area (a small rectangle in the center of the boy image)
    final double mouthCenterX = position.dx + boyWidth / 2;
    final double mouthCenterY =
        position.dy + boyHeight * 0.55; // Adjust mouth position

    // Define acceptable range around mouth
    final double mouthRadius = 30.0;

    // Get the drop position
    final dropPosition = details.offset;

    // Check if drop position is within mouth region
    return (dropPosition.dx - mouthCenterX).abs() < mouthRadius &&
        (dropPosition.dy - mouthCenterY).abs() < mouthRadius;
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions to complete level'),
          content: Text(
              'Grandchild is Hungry, Feed The Fruits to the Child. \n\nFruit Need To Be Picked From Right and Dropped in Mouth of Child. For Every Correct Fruit Drop, you will be rewarded with a point.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 2 Level 4'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Points: $points',
                style: TextStyle(fontSize: 24),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (progress == 1.0)
                          AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) {
                              return Container(
                                width: 30,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.amberAccent.withOpacity(0.7),
                                      blurRadius: 30.0 * _glowController.value,
                                      spreadRadius:
                                          10.0 * _glowController.value,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        Container(
                          width: 40,
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey, width: 2),
                            color: Colors.black12,
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              FractionallySizedBox(
                                heightFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.green,
                                        Colors.lightGreenAccent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: DragTarget<String>(
                      key: boyKey, // Assign the key to the boy's image
                      builder: (BuildContext context,
                          List<String?> candidateData,
                          List<dynamic> rejectedData) {
                        return Image.asset(
                          'assets/boy.png',
                          width: 180,
                          height: 180,
                        );
                      },
                      onAcceptWithDetails: (details) {
                        if (_issweetInMouth(details)) {
                          setState(() {
                            String data = details.data;
                            if (data.startsWith('sweet')) {
                              points += 1;
                              int index =
                                  int.parse(data.replaceAll('sweet', ''));
                              sweetDropped[index] = true;
                              handlesweetDrop();

                              // Short vibration for correct sweet drop
                              Vibration.vibrate(duration: 100);
                            }
                          });
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return sweetWidget(index);
                          }),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            return sweetWidget(index + 4);
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              //remove this navigation logic
              if (progress == 1.0)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => M3L1()),
                    ); // Navigate to M3L2
                  },
                  child: Text('Next Level'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sweetWidget(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: sweetDropped[index]
          ? Container(
              height: 40,
              width: 40,
              color: Colors.transparent,
            )
          : Draggable<String>(
              data: 'sweet$index',
              feedback: Image.asset(
                'assets/Sweet.png',
                width: 40,
                height: 40,
              ),
              childWhenDragging: Container(),
              child: Image.asset(
                'assets/Sweet.png',
                width: 40,
                height: 40,
              ),
            ),
    );
  }
}
