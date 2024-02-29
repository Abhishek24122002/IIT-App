import 'package:alzymer/ScoreManager.dart';
import 'package:alzymer/scene/two.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final bool isOldMan;

  SpeechBubble({required this.text, required this.isOldMan});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: isOldMan ? 20.0 : MediaQuery.of(context).size.height - 300.0,
      left: isOldMan ? 20.0 : MediaQuery.of(context).size.width - 220.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: text.isNotEmpty,
            child: Container(
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
            ),
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
  bool nextLevelButton = false;
  int level1Attempts = 0;
  bool showHintButton = true;
  String userAnswer = '';
  String oldManAnswer = '';
  String? gender;

  List<Widget> levels = [one(), two()];
  int currentLevelIndex = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
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

  String getSpeechBubbleText() {
    if (gender == 'Male') {
      return "Hello Grandpa!! what is Today's Date?";
    } else if (gender == 'Female') {
      return "Hello granny !! what is Today's Date?";
    } else {
      return "Hello !! what is Today's Date?";
    }
  }

  String getSpeechBubbleImage() {
    if (gender == 'Male') {
      return 'assets/old1.png';
    } else if (gender == 'Female') {
      return 'assets/old1-lady.png';
    } else {
      return 'assets/old1.png'; // You can set a default image or handle it accordingly
    }
  }

  bool isAnswerCorrect(String input) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return input == formattedDate;
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

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
        oldManAnswer = "Today's date is $userAnswer";
      });

      updateFirebaseData();
      ScoreManager.updateUserScore();
    }

    String boyResponse =
    correctAnswer ? "Correct answer!" : "Wrong answer. Try again.";
    oldManAnswer = correctAnswer ? "Today's date is $userAnswer" : "";

    setState(() {
      userAnswer = "";
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        userAnswer = boyResponse;
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
            decoration: InputDecoration(hintText: 'Enter day/month/year'),
            onChanged: (value) {
              setState(() {
                userAnswer = value;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background images
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
              bottom: 20.0,
              right: 20.0,
              child: Image.asset(
                'assets/boy1.png',
                width: 200.0,
                height: 300.0,
              ),
            ),

            // Speech bubbles
            SpeechBubble(
              text: oldManAnswer.isEmpty ? getSpeechBubbleText() : oldManAnswer,
              isOldMan: gender ==
                  'male', // Assuming male image is considered 'old man'
            ),
            Visibility(
              visible: !showStartButton && userAnswer.isEmpty,
              child: SpeechBubble(
                text: getSpeechBubbleText(),
                isOldMan: false,
              ),
            ),
            Visibility(
              visible: !showStartButton && userAnswer.isNotEmpty,
              child: SpeechBubble(
                text: userAnswer,
                isOldMan: false,
              ),
            ),

            // Buttons
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
                          showStartButton = false;
                          showAnswerButton = true;
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
                      child: Text('Answer the Question'),
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
                ),
              ),
          ],
        ),
      ),
    );
  }
}
