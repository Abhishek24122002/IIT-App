import 'package:alzymer/scene/M3/M3L3.dart';
import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class M3L2 extends StatefulWidget {
  @override
  _M3L2State createState() => _M3L2State();
}

class _M3L2State extends State<M3L2> {
  TextEditingController answerController = TextEditingController();
  bool showHintButton = false;
  bool showHintOptions = false;
  bool isAnswerCorrect = false;
  Timer? _timer;
  String selectedFruit = ''; // Fruit fetched from Firebase
  List<String> hintFruits = [];
  int M3L2Point = 0;

  @override
  void initState() {
    super.initState();
    fetchSelectedFruit();
    startAnswerTimer();
  }

  void fetchSelectedFruit() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        DocumentSnapshot snapshot = await firestore
            .collection('users')
            .doc(user.uid)
            .collection('score')
            .doc('M1')
            .get();

        if (snapshot.exists) {
          setState(() {
            selectedFruit = snapshot.get('Fruit_Selected') ?? '';
          });
        } else {
          print('No Fruit_Selected found for M1');
        }
      }
    } catch (e) {
      print('Error fetching Fruit_Selected: $e');
    }
  }
   String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM3L2() async {
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
            'M3L2Point': M3L2Point,
          });
        } else {
          // If the document exists, update the fields
          await scoreDocRef.update({
            'M3L2Point': M3L2Point,
          });
        }
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void startAnswerTimer() {
    _timer = Timer(Duration(seconds: 10), () {
      setState(() {
        showHintButton = true;
      });
    });
  }

  void showHint() {
    setState(() {
      showHintOptions = true;
      hintFruits = generateHintOptions(selectedFruit);
    });
  }

  List<String> generateHintOptions(String correctFruit) {
    List<String> fruits = ['Apple', 'Banana', 'Orange', 'Pineapple', 'Mango'];
    fruits.remove(correctFruit);
    fruits.shuffle();
    return [correctFruit, ...fruits.take(4)]..shuffle();
  }

  void checkAnswer(String answer) {
    if (answer.trim().toLowerCase() == selectedFruit.toLowerCase()) {
      setState(() {
        isAnswerCorrect = true;
        showHintButton = false;
        showHintOptions = false;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Incorrect'),
            content: Text('Try again!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Module 3 Level 2"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'You need to buy the fruit that you ate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'Your Answer',
                    border: OutlineInputBorder(),
                    hintText: 'Type the fruit name here',
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                if (!isAnswerCorrect)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightGreen,
                    ),
                    onPressed: () => checkAnswer(answerController.text),
                    child: Text('Submit'),
                  ),
                  if (!isAnswerCorrect)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.amberAccent,
                    ),
                    onPressed: showHint,
                    child: Text('Show Hint'),
                  ),
                  Wrap(
                    spacing: 10,
                    children: hintFruits.map((fruit) {
                      return ElevatedButton(
                        onPressed: () => checkAnswer(fruit),
                        child: Text(fruit),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          if (isAnswerCorrect)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    setState(() {
                      M3L2Point =1;
                      updateFirebaseDataM3L2();
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => M3L3(),
                      ),
                    );
                  },
                  child: Text('Next Level'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
