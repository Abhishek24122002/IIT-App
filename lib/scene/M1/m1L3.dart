import 'dart:math';

import 'package:alzymer/scene/M1/m1L1.dart';
import 'package:alzymer/scene/M1/m1L2.dart';
import 'package:alzymer/scene/M1/m1L4.dart';
import 'package:alzymer/scene/M1/m1L5.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SpeechBubble extends StatelessWidget {
  final String text;

  SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxWidth: 300,
      ),
      child: Wrap(
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class M1L3 extends StatefulWidget {
  @override
  _M1L3State createState() => _M1L3State();
}

class _M1L3State extends State<M1L3> {
  bool showStartButton = true;
  bool showSelectFruitButton = false;
  bool showSpeechBubble = false;
  String? gender;
  bool showTable = false;
  bool showBoyImage = true;
  bool showfruitbasket = false;
  bool showFruit = false;
  List<String> fruits = ['Apple', 'Banana', 'Orange', 'Pineapple', 'Mango'];

  List<String> selectedFruits = [];
  List<String> displayedFruits = [];
  TextEditingController answerController = TextEditingController();
  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4(), M1L5()];
  int currentLevelIndex = 2;
  bool fruitSelected = false;

  int M1L3Attempts = 0;
  int M1L3Point = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    Future.delayed(Duration.zero, () {
      initialPopup();
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
  void showAllFruits() {
  setState(() {
    displayedFruits = List.from(fruits); // Display all available fruits
    showFruit = true;
  });
}

  void updateFirebaseDataM1L3() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M1'
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M1');

        DocumentReference attemptDocRef =
            userDocRef.collection('attempt').doc('M1');

        // Update the fields in the 'score' document
        await scoreDocRef.update({
          'M1L3Point': M1L3Point,
          'Fruit_Selected':selectedFruits,
        });
        await attemptDocRef.update({
          'M1L3Attempts': M1L3Attempts,
          
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void initialPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ' Task 3 ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Color.fromARGB(255, 94, 114, 228), // Title color
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromARGB(
                      255, 158, 124, 193), // Instruction title color
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'In this task, your grandchild will provide you with some information that will be useful for future game tasks.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87, // Content color
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text(
                'Got it!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromARGB(255, 94, 114, 228), // Button color
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10.0,
          backgroundColor: Colors.white, // Background color
        );
      },
    );
  }

  // Firebase update function for storing only the selected fruit
void updateFirebaseUserAnswer(String selectedFruit) async {
  try {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getCurrentUserUid();

    if (userUid.isNotEmpty) {
      DocumentReference userDocRef = firestore.collection('users').doc(userUid);
      DocumentReference scoreDocRef = userDocRef.collection('score').doc('M1');

      await scoreDocRef.update({
        'Fruit_Selected': selectedFruit, // Storing only the selected fruit
      });
    }
  } catch (e) {
    print('Error updating user answer in Firestore: $e');
  }
}

  String getSpeechBubbleText() {
    if (gender == 'Male') {
      return "Hey Grandpa, I have to go to school now. It will finish by 3:00 today.";
    } else if (gender == 'Female') {
      return "Hey Grandma, I have to go to school now. It will finish by 3:00 today.";
    } else {
      return "Hey, I have to go to school now. It will finish by 3:00 today.";
    }
  }

  String getSpeechBubbleImage() {
    if (gender == 'Male') {
      return 'assets/old1.png';
    } else if (gender == 'Female') {
      return 'assets/old1-lady.png';
    } else {
      return 'assets/old1.png';
    }
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

  void showInstruction() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instruction'),
          content: Text('Please select a fruit from the table.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  showSelectFruitButton = true;
                });
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showSelectedFruitDialog(String fruit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selected Fruit'),
          content: Text('You selected: $fruit'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // showCelebrationDialog();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showCelebrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('🎉🎉🎉 Your answer is correct. 🏆'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  void onFruitSelected(String fruit) {
  setState(() {
    fruitSelected = true;
    showSelectedFruitDialog(fruit);
    // Clear the fruit display since we only need to select one
    displayedFruits.clear();
  });
  updateFirebaseUserAnswer(fruit);
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Image.asset(
                  'assets/bg1.jpg',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                Positioned(
                  top: 50.0,
                  left: -130.0,
                  child: Image.asset(
                    getSpeechBubbleImage(),
                    width: 500.0,
                    height: 500.0,
                  ),
                ),
                Positioned(
                  top: 12.0,
                  right: 120.0,
                  child: Image.asset(
                    'assets/clock10.png',
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: Visibility(
                    visible: showBoyImage,
                    child: Image.asset(
                      'assets/boy2.png',
                      width: 200.0,
                      height: 300.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 180,
                  right: 20,
                  child: Visibility(
                    visible: showTable,
                    child: Image.asset(
                      'assets/table2.png',
                      width: 300.0,
                      height: 300.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 150.0,
                  right: 110.0,
                  child: Visibility(
                    visible: showfruitbasket,
                    child: Image.asset(
                      'assets/fruit.png',
                      width: 120.0,
                      height: 120.0,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120.0,
                  left: 220.0,
                  child: Visibility(
                    visible: showFruit && !fruitSelected,
                    child: Column(
                      children: [
                        SizedBox(height: 10), // Adding spacing
                        Wrap(
                          spacing: 10, // Adding spacing between buttons
                          children: displayedFruits
                              .map(
                                (fruit) => ElevatedButton(
                                  onPressed: () {
                                    M1L3Attempts++;
                                    M1L3Point = 1;
                                    updateFirebaseDataM1L3();

                                    onFruitSelected(fruit);
                                    showSelectFruitButton = false;
                                  },
                                  child: Text(fruit),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 150.0,
                  right: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: showSpeechBubble,
                        child: SpeechBubble(
                          text: selectedFruits.isNotEmpty
                              ? 'Thank You'
                              : getSpeechBubbleText(),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 30.0,
                  child: Row(
                    children: [
                      Visibility(
                        visible: showStartButton,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSpeechBubble = true;
                              showStartButton = false;
                              showSelectFruitButton = true;
                            });
                          },
                          child: Text('Start'),
                        ),
                      ),
                      if (showSelectFruitButton)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSpeechBubble = false;
                              showBoyImage = false;
                              showTable = true;
                              showFruit = true;
                              showfruitbasket = true;

                              showInstruction();
                              showAllFruits();
                            });
                          },
                          child: Text('Sure'),
                        ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  right: 30.0,
                  child: Visibility(
                    visible: fruitSelected,
                    child: ElevatedButton(
                      onPressed: () {
                        navigateToNextLevel();
                      },
                      child: Text('Next Level'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
