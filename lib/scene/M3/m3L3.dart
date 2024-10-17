import 'dart:math';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:alzymer/scene/M3/m3L4.dart';
import 'package:alzymer/scene/M3/m3L5.dart';
import 'package:alzymer/scene/M3/m3L6.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class M3L3 extends StatefulWidget {
  @override
  _M3L3State createState() => _M3L3State();
}

class _M3L3State extends State<M3L3> {
  int collectedPotatoes = 0;
  bool showPopup = true;
  int M3L3Point = 0;
  List<Widget> levels = [
    M3L1(),
    M3L6(),
    M3L2(),
    M3L3(),
    M3L4(),
    M3L5(),
  ];
  int currentLevelIndex = 3;

  List<List<String>> baskets = [
    [
      'Cabbage',
      'Cabbage',
      'Cabbage',
      'Cabbage',
      'Carrot',
      'Carrot',
      'Onion',
      'Onion',
      'Cabbage',
      'Carrot',
      'Potato',
      'Potato',
      'Potato'
    ],
    [
      'Carrot',
      'Carrot',
      'Carrot',
      'Cabbage',
      'Onion',
      'Onion',
      'Onion',
      'Cabbage',
      'Carrot',
      'Carrot',
      'Potato',
      'Potato',
      'Potato'
    ],
    [
      'Onion',
      'Onion',
      'Cabbage',
      'Cabbage',
      'Cabbage',
      'Cabbage',
      'Carrot',
      'Onion',
      'Onion',
      'Potato',
      'Potato',
      'Potato',
      'Potato'
    ],
  ];

  List<List<Offset>> vegetablePositions = [[], [], []];

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
      _generateVegetablePositions();
      showInstructionDialog();
    });
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM3L3() async {
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
            'M3L3Point': M3L3Point,
          });
        } else {
          // If the document exists, update the fields
          await scoreDocRef.update({
            'M3L3Point': M3L3Point,
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

  // Generate random positions for the vegetables in each basket
  void _generateVegetablePositions() {
    Random random = Random();
    double basketSize = 180.0; // Increased basket size
    double vegetableSize = 50.0; // Increased vegetable size

    for (int basketIndex = 0; basketIndex < baskets.length; basketIndex++) {
      List<Offset> usedPositions = []; // Track used positions to avoid overlap

      for (int i = 0; i < baskets[basketIndex].length; i++) {
        Offset position = Offset.zero; // Initialize with a default value
        bool positionFound = false;

        // Attempt to place the vegetable without overlap
        for (int attempt = 0; attempt < 10; attempt++) {
          double randomTop = random.nextDouble() * (basketSize - vegetableSize);
          double randomLeft =
              random.nextDouble() * (basketSize - vegetableSize);
          position = Offset(randomLeft, randomTop);

          // Check for overlap
          bool overlaps = usedPositions.any((usedPosition) {
            return (position - usedPosition).distance < vegetableSize;
          });

          if (!overlaps) {
            positionFound = true;
            usedPositions.add(position);
            break;
          }
        }

        // If a position without overlap wasn't found, allow overlap
        if (!positionFound) {
          double randomTop = random.nextDouble() * (basketSize - vegetableSize);
          double randomLeft =
              random.nextDouble() * (basketSize - vegetableSize);
          position = Offset(randomLeft, randomTop);
        }

        vegetablePositions[basketIndex].add(position);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find the Potatoes - Level 3'),
      ),
      body: Stack(
        children: [
          if (!showPopup) _buildGameScreen(),
          if (showPopup) _buildPopupMessage(),
          Positioned(
            top: 20,
            right: 20,
            child: _buildCollectedPotatoesCounter(),
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
              'Find and collect all the potatoes!',
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
          width: 180,
          height: 180,
          child: _buildVegetableStack(basketIndex),
        ),
      ],
    );
  }

  Widget _buildVegetableStack(int basketIndex) {
    List<Widget> vegetableWidgets = [];

    for (int i = 0; i < baskets[basketIndex].length; i++) {
      String vegetable = baskets[basketIndex][i];
      Offset position = vegetablePositions[basketIndex][i];

      if (vegetable.isNotEmpty) {
        vegetableWidgets.add(
          Positioned(
            top: position.dy,
            left: position.dx,
            child: GestureDetector(
              onTap: () {
                if (vegetable == 'Potato') {
                  setState(() {
                    collectedPotatoes++;
                    baskets[basketIndex][i] = ''; // Remove the potato
                    if (collectedPotatoes == 10) {
                      // 10 potatoes in total
                      M3L3Point = 1;
                      showLevelCompleteDialog();
                      updateFirebaseDataM3L3();
                    }
                  });
                }
              },
              child: Image.asset(
                'assets/$vegetable.png',
                height: 50, // Increased size
                width: 50,
              ),
            ),
          ),
        );
      }
    }

    return Stack(
      children: vegetableWidgets,
    );
  }


Widget _buildCollectedPotatoesCounter() {
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
          // Actual image
          Image.asset(
            'assets/Potato.png',
            height: 60, // Size of the image
          ),
        ],
      ),
      SizedBox(width: 10),
      Text(
        '$collectedPotatoes',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    ],
  );
}


  Widget _buildPopupMessage() {
    return Center(
      child: AlertDialog(
        title: Text('Collect All Potatoes To Complete Level'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Potato.png', height: 80),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              setState(() {
                showPopup = false;
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
          content: Text('Congratulations! You collected all the potatoes.'),
          actions: <Widget>[
            ElevatedButton(
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
    home: M3L3(),
  ));
}
