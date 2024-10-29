import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For screen orientation
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alzymer/scene/M3/m3L3.dart';
import 'package:alzymer/scene/M4/m4L1.dart'; // Add import for M4L1
import 'package:alzymer/scene/M5/m5L2.dart';

import '../M5/M5L3.dart';

class M3L2 extends StatefulWidget {
  @override
  _M3L2State createState() => _M3L2State();
}

class _M3L2State extends State<M3L2> {
  List<Map<String, dynamic>> stores = [
    {
      'image': 'assets/Fruit_Store.png',
      'name': 'Vegetable Store',
      'navigateTo': 'M3L3',
      'locked': false // Unlock the first store
    },
    {
      'image': 'assets/Dairy.png',
      'name': 'Milk Products',
      'navigateTo': 'M5L2',
      'locked': true // Locked initially
    },
    {
      'image': 'assets/Grocery_Store.png',
      'name': 'Grocery Store',
      'navigateTo': 'M5L3',
      'locked': true // Locked initially
    },
    {
      'image': 'assets/Sweets_Store.png',
      'name': 'Sweet Shop',
      'navigateTo': 'M4L1', // No navigation yet, placeholder store
      'locked': true // Locked initially
    },
  ];

  bool showNames = false;
  bool showHintButton = false;
  int M3L2Point = 0;

  // Variable to track if all levels are completed
  bool allLevelsCompleted = false;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();

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
    Timer(Duration(seconds: 5), () {
      setState(() {
        showHintButton = true;
      });
    });

    // Fetch lock status from Firestore
    _fetchStoreLockStatus();
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void _fetchStoreLockStatus() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Fetch the scores from the respective modules (M3, M4, M5)
        DocumentSnapshot m3Doc = await firestore
            .collection('users')
            .doc(userUid)
            .collection('score')
            .doc('M3')
            .get();
        DocumentSnapshot m4Doc = await firestore
            .collection('users')
            .doc(userUid)
            .collection('score')
            .doc('M4')
            .get();
        DocumentSnapshot m5Doc = await firestore
            .collection('users')
            .doc(userUid)
            .collection('score')
            .doc('M5')
            .get();

        // Get the points for each module and level
        Map<String, dynamic>? m3Data = m3Doc.data() as Map<String, dynamic>?;
        Map<String, dynamic>? m4Data = m4Doc.data() as Map<String, dynamic>?;
        Map<String, dynamic>? m5Data = m5Doc.data() as Map<String, dynamic>?;

        setState(() {
          // Unlock stores based on previous completion
          if (m3Data != null && m3Data['M3L5Point'] == 1) {
            stores[1]['locked'] = false; // Unlock Milk Products
          }
          if (m5Data != null && m5Data['M5L2Point'] == 1) {
            stores[2]['locked'] = false; // Unlock Grocery Store
          }
          if (m5Data != null && m5Data['M5L3Point'] == 1) {
            stores[3]['locked'] = false; // Unlock Sweet Shop
          }

          // Check if all levels are completed
          allLevelsCompleted = (m3Data != null && m3Data['M3L5Point'] == 1) &&
              (m4Data != null && m4Data['M4L1Point'] == 1) &&
              (m5Data != null && m5Data['M5L2Point'] == 1) &&
              (m5Data['M5L3Point'] == 1);
        });
      }
    } catch (e) {
      print('Error fetching store lock status: $e');
    }
  }

  void updateFirebaseDataM3L2() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference scoreDocRef = firestore
            .collection('users')
            .doc(userUid)
            .collection('score')
            .doc('M3');
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

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

  void _revealNames() {
    setState(() {
      showNames = true;
      showHintButton = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 3 Level 2'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Layout based on orientation
                orientation == Orientation.landscape
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          bool isLocked = stores[index]['locked'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: isLocked
                                  ? null // Disable tap if the store is locked
                                  : () {
                                      String selectedStore =
                                          stores[index]['name']!;
                                      if (selectedStore == 'Vegetable Store') {
                                        setState(() {
                                          M3L2Point = 1;
                                        });
                                        updateFirebaseDataM3L2();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => M3L3()),
                                        );
                                      } else if (selectedStore ==
                                          'Milk Products') {
                                        setState(() {});
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => M5L2()),
                                        );
                                      } else if (selectedStore ==
                                          'Grocery Store') {
                                        setState(() {});
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => M5L3()),
                                        );
                                      } else if (selectedStore ==
                                          'Sweet Shop') {
                                        setState(() {});
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => M4L1()),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Wrong answer! You entered the wrong shop.')),
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
                                        width: 140, // Increased image size
                                        height: 140,
                                        color: isLocked
                                            ? Colors.black.withOpacity(0.3)
                                            : null, // Apply opacity if locked
                                        colorBlendMode: isLocked
                                            ? BlendMode.dstIn
                                            : null, // Blend mode to apply opacity
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4), // Reduced spacing
                                  Text(
                                    showNames ? stores[index]['name']! : '',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          bool isLocked = stores[index]['locked'];
                          return GestureDetector(
                            onTap: isLocked
                                ? null
                                : () {
                                    String selectedStore =
                                        stores[index]['name']!;
                                    if (selectedStore == 'Vegetable Store') {
                                      setState(() {
                                        M3L2Point = 1;
                                      });
                                      updateFirebaseDataM3L2();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => M3L3()),
                                      );
                                    } else if (selectedStore ==
                                        'Milk Products') {
                                      setState(() {});
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => M5L2()),
                                      );
                                    } else if (selectedStore ==
                                        'Grocery Store') {
                                      setState(() {});
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => M4L1()),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Wrong answer! You entered the wrong shop.')),
                                      );
                                    }
                                  },
                            child: Column(
                              children: [
                                Card(
                                  child: Image.asset(
                                    stores[index]['image']!,
                                    width: 120,
                                    height: 120,
                                    color: isLocked
                                        ? Colors.black.withOpacity(0.3)
                                        : null, // Apply opacity if locked
                                    colorBlendMode: isLocked
                                        ? BlendMode.dstIn
                                        : null, // Blend mode to apply opacity
                                  ),
                                ),
                                Text(
                                  showNames ? stores[index]['name']! : '',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                SizedBox(height: 20), // Added spacing for visual clarity
                if (showHintButton && !allLevelsCompleted)
                  ElevatedButton(
                    onPressed: _revealNames,
                    child: Text('Show Hint'),
                  ),
                if (allLevelsCompleted)
                  ElevatedButton(
                    onPressed: () {
                      // Handle next module navigation
                    },
                    child: Text('Next Module'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
