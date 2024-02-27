import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alzymer/ScoreManager.dart';

import 'two.dart';
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

class one extends StatefulWidget {
  @override
  _oneState createState() => _oneState();
}

class _oneState extends State<one> {
  bool showStartButton = true;
  bool showAnswerButton = false;
  bool showSpeechBubble = false;
  bool showSpeechBubble2 = false;
  bool nextLevelButton = false;
  int level1Attempts = 0;
  bool showHintButton = true;

  String userAnswer = '';
  TextEditingController answerController = TextEditingController();

  // List of level classes
  List<Widget> levels = [one(), two()]; // Add more levels as needed
  int currentLevelIndex = 0;

  set hint(String hint) {}

  bool isAnswerCorrect(String input) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return input == formattedDate;
  }

  // Initialize Firebase
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  // Function to get the current user's UID
  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  // Function to update data in Firebase
  void updateFirebaseData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        DocumentReference documentReference =
            firestore.collection('users').doc(userUid);

        await documentReference.update({
          'level1Attempts': level1Attempts,
        });

        
      } 
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void submitAnswer() {
    level1Attempts++;
    bool correctAnswer = isAnswerCorrect(userAnswer);

    if (correctAnswer) {
      setState(() {
        showAnswerButton = false;
        nextLevelButton = true;
        showHintButton = false;
      });

      // Update Firebase data
      updateFirebaseData();

      ScoreManager.updateUserScore();
    }

    String grandpaResponse = correctAnswer
        ? "Today's date is ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
        : "Today's date is $userAnswer";

    setState(() {
      showSpeechBubble = true;
      userAnswer = grandpaResponse;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (!correctAnswer) {
          showAnswerButton = true;
        }
      });
    });
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input'),
          content: TextField(
            controller: answerController,
            decoration: InputDecoration(hintText: 'Enter day/month/year'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  userAnswer = answerController.text;
                });
                submitAnswer();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void navigateToNextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => levels[currentLevelIndex + 1]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String $hint = 'show Hint';
   void showHint() {
  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Hint'),
        content: Text('The current date is $formattedDate'),
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


    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
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
                    'assets/old1.png',
                    width: 500.0,
                    height: 500.0,
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: Image.asset(
                    'assets/boy1.png',
                    width: 200.0,
                    height: 300.0,
                  ),
                ),
                Positioned(
                  top: 150.0,
                  right: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: showSpeechBubble2,
                        child: SpeechBubble(
                          text: userAnswer,
                        ),
                      ),
                    ],
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
                          text: userAnswer.isNotEmpty
                              ? ' Thank You'
                              : "Hello Grandpa!! what is Today's Date?",
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 80.0,
                  left: 150.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: userAnswer.isNotEmpty,
                        child: SpeechBubble(
                          text: userAnswer,
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
                              showAnswerButton = true;
                              // userAnswer =
                              //     "Hello Grandpa, what is today's date?";
                            });
                          },
                          child: Text('Start'),
                        ),
                      ),
                      if (showAnswerButton)
                        ElevatedButton(
                          onPressed: () {
                            _showInputDialog();
                          },
                          child: Text('Answer the Question '),
                          // child: Text('$level1Attempts'),
                        ),
                    ],
                  ),
                ),
                if (nextLevelButton)
                  Positioned(
                    bottom: 20.0,
                    right: 30.0,
                    child: ElevatedButton(
                      onPressed: () {
                        navigateToNextLevel();
                      },
                      child: Text('Next Level'),
                    ),
                  ),
                
                
                if (level1Attempts >= 2 && showHintButton)
                  Positioned(
                      bottom: 20.0,
                      right: 30.0,
                      child: ElevatedButton(
                        onPressed: () {
                          showHint();
                        },
                        child: Text('Show Hint'),
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
