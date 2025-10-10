import 'package:alzymer/scene/M3/M3L3.dart';
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
  String selectedFruit = '';
  List<String> hintFruits = [];
  int M3L2Point = 0;

  @override
  void initState() {
    super.initState();
    fetchSelectedFruit();
    startAnswerTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => initialPopup());
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
        DocumentReference scoreDocRef =
            firestore.collection('users').doc(userUid).collection('score').doc('M3');

        await scoreDocRef.set({'M3L2Point': M3L2Point}, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void startAnswerTimer() {
    _timer = Timer(Duration(seconds: 10), () {
      setState(() => showHintButton = true);
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
      _showCorrectDialog();
    } else {
      _showIncorrectDialog();
    }
  }

  void _showCorrectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('🎉 Great Job!'),
          content: Text('Your answer is correct! You may move to the next level.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  M3L2Point = 1;
                  updateFirebaseDataM3L2();
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => M3L3()),
                );
              },
              child: Text('Next Level'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  void _showIncorrectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('❌ Oops!'),
          content: Text('That’s not correct. Try again!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  void initialPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Task 2',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                color: Color.fromARGB(255, 94, 114, 228),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 158, 124, 193),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'Type the name of the fruit that you ate in the previous level. If you are unsure, you can use hints after 10 seconds.',
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Got it!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 94, 114, 228),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buy the Fruit You Ate"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // const SizedBox(height: 10),
            // Text(
            //   "Type your answer below:",
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueAccent, width: 1.2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: answerController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Type the fruit name here',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (!isAnswerCorrect)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => checkAnswer(answerController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (showHintButton)
                    ElevatedButton(
                      onPressed: showHint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Show Hint",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16),
                      ),
                    ),
                ],
              ),

            const SizedBox(height: 15),
            if (showHintOptions)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: hintFruits.map((fruit) {
                  return GestureDetector(
                    onTap: () => checkAnswer(fruit),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightBlue, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        fruit,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
