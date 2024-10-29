import 'package:alzymer/scene/M3/m3L1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class M2L3 extends StatefulWidget {
  @override
  _M2L3State createState() => _M2L3State();
}

class _M2L3State extends State<M2L3> {
  TextEditingController answerController = TextEditingController();
  bool showHintButton = false;
  bool showHintOptions = false;
  bool isAnswerCorrect = false;
  Timer? _timer;
  String selectedFruit = ''; // Fruit fetched from Firebase
  List<String> hintFruits = [];

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
        title: Text("Module 2 Level 3"),
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
                  'Which fruit did you eat?',
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => M3L1(),
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
