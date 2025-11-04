import 'dart:math';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'm3L1_2.dart';
import 'm3L2.dart';
import 'm3L3.dart';
import 'm3L3_2.dart';
import 'm3L4.dart';
import 'm3L4_2.dart';

class M3L3_3 extends StatefulWidget {
  @override
  _M3L3_3State createState() => _M3L3_3State();
}

class _M3L3_3State extends State<M3L3_3> {
  int collectedApples = 0;
  bool showPopup = true;
  int M3L3_3Score = 0;
  List<Widget> levels = [M3L1(),M3L1_2(), M3L2(), M3L3(), M3L3_2(), M3L3_3(),M3L4(),M3L4_2()];
  int currentLevelIndex = 5;

  List<List<String>> baskets = [
    [
      'Orange',
      'Orange',
      'Orange',
      'Orange',
      "Orange",
      'Orange',
      'Orange',
      'Apple',
      'Apple',
      'Apple'
    ],
    [
      'Mango',
      'Mango',
      'Mango',
      'Mango',
      'Apple',
      'Apple',
      'Apple',
      'Apple',
      'Apple',
      'Apple'
    ],
    [
      'Tomato',
      'Tomato',
      'Tomato',
      'Tomato',
      'Tomato',
      'Tomato',
      'Tomato',
      'Tomato',
      'Tomato',
      'Apple'
    ],
  ];

  // Store random positions for each fruit
  List<List<Offset>> fruitPositions = [[], [], []];

  @override
  void initState() {
    super.initState();
    // Force landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Generate random positions only once when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateFruitPositions();
      showInstructionDialog();
    });
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM3L3_3() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M3'
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M3');

        // Check if the 'M2' document exists
        DocumentSnapshot scoreDocSnapshot = await scoreDocRef.get();

        if (!scoreDocSnapshot.exists) {
          // If the document doesn't exist, create it with the initial score
          await scoreDocRef.set({
            'M3L3_3Score': M3L3_3Score,
          });
        } else {
          // If the document exists, update the fields
          await scoreDocRef.update({
            'M3L3_3Score': M3L3_3Score,
          });
        }
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  

  // Generate random positions for the fruits in each basket
  void _generateFruitPositions() {
  Random random = Random();

  double screenWidth = MediaQuery.of(context).size.width;
  double basketSize = screenWidth / 4 * 0.72; // match container size
  double fruitSize = basketSize * 0.28;

  for (int basketIndex = 0; basketIndex < baskets.length; basketIndex++) {
    List<Offset> usedPositions = [];

    for (int i = 0; i < baskets[basketIndex].length; i++) {
      Offset position = Offset.zero;
      bool positionFound = false;

      for (int attempt = 0; attempt < 10; attempt++) {
        double randomTop = random.nextDouble() * (basketSize - fruitSize);
        double randomLeft = random.nextDouble() * (basketSize - fruitSize);
        position = Offset(randomLeft, randomTop);

        bool overlaps = usedPositions.any((usedPosition) {
          return (position - usedPosition).distance < fruitSize;
        });

        if (!overlaps) {
          positionFound = true;
          usedPositions.add(position);
          break;
        }
      }

      if (!positionFound) {
        double randomTop = random.nextDouble() * (basketSize - fruitSize);
        double randomLeft = random.nextDouble() * (basketSize - fruitSize);
        position = Offset(randomLeft, randomTop);
      }

      fruitPositions[basketIndex].add(position);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Find the Apples - Level 3'),
          _buildCollectedApplesCounter(),
        ],
      ),
    ),
      body: Stack(
        children: [
          if (!showPopup)
            _buildGameScreen(), // Show game content only if popup is not displayed
          if (showPopup) _buildPopupMessage(), // Show popup message if needed
          // Positioned(
          //   top: 20,
          //   right: 20,
          //   child: _buildCollectedApplesCounter(),
          // ),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Find and collect all apples!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildBasketRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasketRow() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        SizedBox(width: 16),
        _buildBasket(0),
        SizedBox(width: 16),
        _buildBasket(1),
        SizedBox(width: 16),
        _buildBasket(2),
        SizedBox(width: 16),
      ],
    ),
  );
}


  Widget _buildBasket(int basketIndex) {
  double screenWidth = MediaQuery.of(context).size.width;
  double basketSize = screenWidth / 4;
  double innerContainerSize = basketSize * 0.72;

  return Stack(
    alignment: Alignment.center,
    children: [
      Image.asset(
        'assets/basket.png',
        width: basketSize,
        height: basketSize,
        fit: BoxFit.cover,
      ),
      Container(
        width: innerContainerSize,
        height: innerContainerSize,
        child: _buildFruitStack(basketIndex, innerContainerSize),
      ),
    ],
  );
}


  Widget _buildFruitStack(int basketIndex, double basketSize) {
  double fruitSize = basketSize * 0.28;
  List<Widget> fruitWidgets = [];

  for (int i = 0; i < baskets[basketIndex].length; i++) {
    String fruit = baskets[basketIndex][i];
    Offset position = fruitPositions[basketIndex][i];

    if (fruit.isNotEmpty) {
      fruitWidgets.add(
        Positioned(
          top: position.dy,
          left: position.dx,
          child: GestureDetector(
            onTap: () {
              if (fruit == 'Apple') {
                setState(() {
                  collectedApples++;
                  baskets[basketIndex][i] = '';
                  if (collectedApples == 10) {
                    M3L3_3Score = 1;
                    showLevelCompleteDialog();
                    updateFirebaseDataM3L3_3();
                  }
                });
              }
            },
            child: Image.asset(
              'assets/$fruit.png',
              height: fruitSize,
              width: fruitSize,
            ),
          ),
        ),
      );
    }
  }

  return Stack(children: fruitWidgets);
}


  Widget _buildCollectedApplesCounter() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glowing effect
            Container(
              height: 50,
              width: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8), // Golden glow
                    spreadRadius: 0.2,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            Image.asset('assets/Apple.png', height: 45),
          ],
        ), // Larger apple icon
        SizedBox(width: 10),
        Text(
          '$collectedApples',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold), // Larger font size
        ),
      ],
    );
  }

  Widget _buildPopupMessage() {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Center(
    child: AlertDialog(
      title: Text(
        'Collect All Apples To Complete Level',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6, // up to 60% of screen
          maxWidth: screenWidth * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Apple.png', height: 50, width: 50),
              SizedBox(height: 12),
              Text(
                'Gather all apples in this level to proceed!',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        SizedBox(
          width: 80,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 8),
              textStyle: TextStyle(fontSize: 14),
            ),
            onPressed: () {
              setState(() {
                showPopup = false; // Close the popup and show the game screen
              });
            },
            child: Text("OK"),
          ),
        ),
      ],
    ),
  );
}


  void showInstructionDialog() {
    setState(() {
      showPopup = true;
    });
  }

  void showLevelCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task Completed !'),
          content: Text('Congratulations! You collected all the apples.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Next Task'),
              onPressed: () {
                //  Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => M3L4()),
                );
              },
            ),
          ],
        );
      },
    );
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

void main() {
  runApp(MaterialApp(
    home: M3L3_3(),
  ));
}
