import 'dart:math';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:alzymer/scene/M3/m3L3.dart';
import 'package:alzymer/scene/M3/m3L5.dart';
import 'package:alzymer/scene/M3/m3L6.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class M3L4 extends StatefulWidget {
  @override
  _M3L4State createState() => _M3L4State();
}

class _M3L4State extends State<M3L4> {
  int collectedOranges = 0;
  bool showPopup = true;
  int M3L4Point = 0;
  List<Widget> levels = [
    M3L1(),
    M3L6(),
    M3L2(),
    M3L3(),
    M3L4(),
    M3L5(),
  ];
  int currentLevelIndex = 4;

  List<List<String>> baskets = [
    [
      'Apple',
      'Apple',
      'Apple',
      'Apple',
      "Apple",
      'Apple',
      'Apple',
      'Orange',
      'Orange',
      'Orange'
    ],
    [
      'Mango',
      'Mango',
      'Mango',
      'Mango',
      'Orange',
      'Orange',
      'Orange',
      'Orange',
      'Orange',
      'Orange'
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
      'Orange'
    ],
  ];

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

  void updateFirebaseDataM3L4() async {
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
            'M3L4Point': M3L4Point,
          });
        } else {
          // If the document exists, update the fields
          await scoreDocRef.update({
            'M3L4Point': M3L4Point,
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

  // Generate random positions for the fruits in each basket
  void _generateFruitPositions() {
    Random random = Random();
    double basketSize = 180.0; // Assuming the basket container is 180x180
    double fruitSize = 50.0; // Assuming each fruit image is 50x50

    for (int basketIndex = 0; basketIndex < baskets.length; basketIndex++) {
      List<Offset> usedPositions = []; // Track used positions to avoid overlap

      for (int i = 0; i < baskets[basketIndex].length; i++) {
        Offset position = Offset.zero; // Initialize with a default value
        bool positionFound = false;

        // Attempt to place the fruit without overlap
        for (int attempt = 0; attempt < 10; attempt++) {
          double randomTop = random.nextDouble() * (basketSize - fruitSize);
          double randomLeft = random.nextDouble() * (basketSize - fruitSize);
          position = Offset(randomLeft, randomTop);

          // Check for overlap
          bool overlaps = usedPositions.any((usedPosition) {
            return (position - usedPosition).distance < fruitSize;
          });

          if (!overlaps) {
            positionFound = true;
            usedPositions.add(position);
            break;
          }
        }

        // If a position without overlap wasn't found, allow overlap
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
        title: Text('Find the Oranges - Level 4'),
      ),
      body: Stack(
        children: [
          if (!showPopup)
            _buildGameScreen(), // Show game content only if popup is not displayed
          if (showPopup) _buildPopupMessage(), // Show popup message if needed
          Positioned(
            top: 20,
            right: 20,
            child: _buildCollectedOrangesCounter(),
          ),
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
              'Find and collect all oranges!',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBasket(0),
        _buildBasket(1),
        _buildBasket(2),
      ],
    );
  }

  Widget _buildBasket(int basketIndex) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/basket.png',
          width: 250,
          height: 250,
          fit: BoxFit.cover,
        ),
        Container(
          width:
              180, // Ensure the Container has a fixed size matching the basket
          height: 180, // Same size as the basket image
          child: _buildFruitStack(basketIndex),
        ),
      ],
    );
  }

  Widget _buildFruitStack(int basketIndex) {
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
                if (fruit == 'Orange') {
                  setState(() {
                    collectedOranges++;
                    baskets[basketIndex][i] = ''; // Remove the orange
                    if (collectedOranges == 10) {
                      M3L4Point = 1; // Example: 10 oranges in total
                      showLevelCompleteDialog();
                      updateFirebaseDataM3L4();
                    }
                  });
                }
              },
              child: Image.asset(
                'assets/$fruit.png',
                height: 50,
                width: 50,
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: fruitWidgets,
    );
  }

  Widget _buildCollectedOrangesCounter() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height:50,
              width: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    spreadRadius: 0.2,
                    blurRadius: 20,
                  ),
                ]
              ),
            ),
        
          Image.asset('assets/Orange.png', height: 60), 
          ],),// Larger orange icon
        SizedBox(width: 10),
        Text(
          '$collectedOranges',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold), // Larger font size
        ),
      ],
    );
  }

  Widget _buildPopupMessage() {
    return Center(
      child: AlertDialog(
        title: Text('Collect All Oranges To Complete Level'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Orange.png', height: 80),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              setState(() {
                showPopup = false; // Close the popup and show the game screen
              });
            },
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
          title: Text('Level Complete!'),
          content: Text('Congratulations! You collected all the oranges.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Next Level'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                navigateToNextLevel();
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
    home: M3L4(),
  ));
}
