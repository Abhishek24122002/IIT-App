import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For screen orientation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:alzymer/scene/M3/m3L3.dart';
import 'package:alzymer/scene/M3/m3L4.dart';
import 'package:alzymer/scene/M3/m3L5.dart';

class M3L2 extends StatefulWidget {
  @override
  _M3L2State createState() => _M3L2State();
}

class _M3L2State extends State<M3L2> {
  List<Map<String, String>> stores = [
    {'image': 'assets/Cloth_Store.png', 'name': 'Cloth Store'},
    {'image': 'assets/Fruit_Store.png', 'name': 'Fruit & Vegetable Store'},
    {'image': 'assets/Toy_Store.png', 'name': 'Toy Store'},
    {'image': 'assets/Food_Store.png', 'name': 'Food Store'},
  ];

  int fruitStoreIndex = 0;
  bool showNames = false;
  bool showHintButton = false;
  int M3L2Point = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    stores.shuffle();
    fruitStoreIndex = stores.indexWhere((store) => store['image'] == 'assets/Fruit_Store.png');

    // Force landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Show instructions when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });

    // Show hint button after 10 seconds
    Timer(Duration(seconds: 10), () {
      setState(() {
        showHintButton = true;
      });
    });
  }

  // Get current user's UID
  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  // Update Firebase data
  void updateFirebaseDataM3L2() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference scoreDocRef = firestore.collection('users').doc(userUid).collection('score').doc('M3');
        await scoreDocRef.set({
          'M3L2Point': M3L2Point,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  void dispose() {
    // Reset preferred orientations when leaving the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  // Show instruction dialog
  void _showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instructions to complete level'),
          content: Text(
              'You are asked to bring Fruits and Vegetables. \n\nSelect the correct vendor to buy the items. \n\nFor correct selection, you will be rewarded with a point.'),
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

  // Reveal shop names
  void _revealNames() {
    setState(() {
      showNames = true;
      showHintButton = false; // Hide hint button after revealing names
    });
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 3 Level 2'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Shop Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return GestureDetector(
                onTap: () {
                  if (index == fruitStoreIndex) {
                    setState(() {
                      M3L2Point = 1; // Award point for correct selection
                    });
                    updateFirebaseDataM3L2();

                    // Navigate to the next level (M3L3)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => M3L3()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Wrong answer!')),
                    );
                  }
                },
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            spreadRadius: 2.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Card(
                        child: Image.asset(
                          stores[index]['image']!,
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      showNames ? stores[index]['name']! : '',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 20),
          // Show hint button after 10 seconds
          Visibility(
            visible: showHintButton && !showNames,
            child: ElevatedButton(
              onPressed: _revealNames,
              child: Text('Show Hint'),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: M3L2(),
  ));
}
