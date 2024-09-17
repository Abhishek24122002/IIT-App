import 'dart:math';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L2.dart';
import 'package:alzymer/scene/M3/m3L3.dart';
import 'package:alzymer/scene/M3/m3L4.dart';
import 'package:alzymer/scene/M4/m4L3.dart';
import 'package:alzymer/scene/M4/m4L1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class M3L5 extends StatefulWidget {
  @override
  _M3L5State createState() => _M3L5State();
}

class _M3L5State extends State<M3L5> {
  int collectedApples = 0;
  bool showPopup = true;
  int M3L5Point = 0;
  List<Widget> levels = [M3L1(), M3L2(), M3L3(), M3L4(), M3L5()];
  int currentLevelIndex = 4;
  
  List<List<String>> baskets = [
    ['Orange','Orange', 'Orange', 'Orange', "Orange",'Orange', 'Orange', 'Apple', 'Apple', 'Apple'],
    ['Mango', 'Mango', 'Mango','Mango', 'Apple', 'Apple', 'Apple', 'Apple', 'Apple', 'Apple'],
    ['Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato', 'Tomato','Apple'],
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

  void updateFirebaseDataM3L5() async {
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

      if (!scoreDocSnapshot.exists) {
        // If the document doesn't exist, create it with the initial score
        await scoreDocRef.set({
          'M3L5Point': M3L5Point,
        });
      } else {
        // If the document exists, update the fields
        await scoreDocRef.update({
          'M3L5Point': M3L5Point,
        });
      }
    }
  } catch (e) {
    print('Error updating data: $e');
  }
}

  @override
  void dispose() {
    // Reset orientation to normal when exiting this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
        title: Text('Find the Apples - Level 5'),
      ),
      body: Stack(
        children: [
          if (!showPopup) _buildGameScreen(), // Show game content only if popup is not displayed
          if (showPopup) _buildPopupMessage(), // Show popup message if needed
          Positioned(
            top: 20,
            right: 20,
            child: _buildCollectedApplesCounter(),
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
          width: 180, // Ensure the Container has a fixed size matching the basket
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
                if (fruit == 'Apple') {
                  setState(() {
                    collectedApples++;
                    baskets[basketIndex][i] = ''; // Remove the apple
                    if (collectedApples == 10) { // Example: 10 apples in total
                      M3L5Point=1;// Example: 10 oranges in total
                      showLevelCompleteDialog();
                      updateFirebaseDataM3L5();
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

  Widget _buildCollectedApplesCounter() {
    return Row(
      children: [
        Image.asset('assets/Apple.png', height: 50), // Larger apple icon
        SizedBox(width: 10),
        Text(
          '$collectedApples',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold), // Larger font size
        ),
      ],
    );
  }

  Widget _buildPopupMessage() {
    return Center(
      child: AlertDialog(
        title: Text('Collect All Apples To Complete Level'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/Apple.png', height: 80),
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
          title: Text('Task Completed !'),
          content: Text('Congratulations! You collected all the apples.'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Next Task'),
              onPressed: () {
              //  Navigator.of(context).pop(); // Close the dialog
                Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => M4L1()),
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
    home: M3L5(),
  ));
}
