import 'dart:math';

import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:alzymer/scene/M3/m3L3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'm3L1_2.dart';
import 'm3L3_3.dart';
import 'm3L4.dart';
import 'm3L4_2.dart';

class M3L3_2 extends StatefulWidget {
  @override
  _M3L3_2State createState() => _M3L3_2State();
}

class _M3L3_2State extends State<M3L3_2> {
  int collectedOranges = 0;
  bool showPopup = true;
  int M3L3_2Score = 0;
  List<Widget> levels = [M3L1(), M3L1_2(), M3L2(), M3L3(), M3L3_2(), M3L3_3(), M3L4(), M3L4_2()];
  int currentLevelIndex = 4;

  List<List<String>> baskets = [
    ['Apple', 'Apple', 'Apple', 'Apple', "Apple", 'Apple', 'Apple', 'Orange', 'Orange', 'Orange'],
    ['Mango', 'Mango', 'Mango', 'Mango', 'Orange', 'Orange', 'Orange', 'Orange', 'Orange', 'Orange'],
    ['Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Orange'],
  ];

  List<List<Offset>> fruitPositions = [[], [], []];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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

  void updateFirebaseDataM3L3_2() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference userDocRef = firestore.collection('users').doc(userUid);
        DocumentReference scoreDocRef = userDocRef.collection('score').doc('M3');
        DocumentSnapshot scoreDocSnapshot = await scoreDocRef.get();

        if (!scoreDocSnapshot.exists) {
          await scoreDocRef.set({'M3L3_2Score': M3L3_2Score});
        } else {
          await scoreDocRef.update({'M3L3_2Score': M3L3_2Score});
        }
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void _generateFruitPositions() {
    Random random = Random();
    double screenWidth = MediaQuery.of(context).size.width;
    double basketSize = screenWidth / 4 * 0.72;
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

          bool overlaps = usedPositions.any((usedPosition) =>
              (position - usedPosition).distance < fruitSize);

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
            Text('Find the Oranges - Level 4'),
            _buildCollectedOrangesCounter(),
          ],
        ),
      ),
      body: Stack(
        children: [
          if (!showPopup) _buildGameScreen(),
          if (showPopup) _buildPopupMessage(),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Center(
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
    double basketInnerSize = basketSize * 0.72;

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
          width: basketInnerSize,
          height: basketInnerSize,
          child: _buildFruitStack(basketIndex, basketInnerSize),
        ),
      ],
    );
  }

  Widget _buildFruitStack(int basketIndex, double basketInnerSize) {
    List<Widget> fruitWidgets = [];
    double fruitSize = basketInnerSize * 0.28;

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
                    baskets[basketIndex][i] = '';
                    if (collectedOranges == 10) {
                      M3L3_2Score = 1;
                      showLevelCompleteDialog();
                      updateFirebaseDataM3L3_2();
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

  Widget _buildCollectedOrangesCounter() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 50,
              width: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    spreadRadius: 0.2,
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
            Image.asset('assets/Orange.png', height: 45),
          ],
        ),
        SizedBox(width: 10),
        Text(
          '$collectedOranges',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
        'Collect All Oranges To Complete Level',
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
              Image.asset('assets/Orange.png', height: 50, width: 50),
              SizedBox(height: 12),
              Text(
                'Gather all oranges in this level to proceed!',
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
                showPopup = false;
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
          title: Text('Level Complete!'),
          content: Text('Congratulations! You collected all the oranges.'),
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
