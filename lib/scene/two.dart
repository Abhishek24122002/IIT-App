import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../ScoreManager.dart';

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

class Two extends StatefulWidget {
  @override
  _TwoState createState() => _TwoState();
}

class _TwoState extends State<Two> {
  bool showStartButton = true;
  bool showAnswerButton = false;
  bool showSpeechBubble = false;
  bool showSpeechBubble2 = false;
  bool nextLevelButton = false;
  int level2Attempts = 0;
  bool showHintButton = true;
  String? gender;
  String userAnswer = '';
  String weather = '';
  TextEditingController answerController = TextEditingController();
  List<Widget> levels = [Two()];
  int currentLevelIndex = 0;
  String sceneImage = 'assets/bg1.jpg';

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
    setInitialSceneImage();
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

  bool isAnswerCorrect(String userAnswer, String weather) {
    return userAnswer.toLowerCase() == weather.toLowerCase();
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
          'level2Attempts': level2Attempts,
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  String getSpeechBubbleText() {
    if (gender == 'Male') {
      return "Hey Grandpa, do you know what season it is right now?";
    } else if (gender == 'Female') {
      return "Hey Grandma, do you know what season it is right now?";
    } else {
      return "Hey, do you know what season it is right now?";
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

  void submitAnswer() {
    level2Attempts++;

    bool correctAnswer = isAnswerCorrect(userAnswer, weather);

    if (correctAnswer) {
      showCelebrationDialog();
      setState(() {
        showAnswerButton = false;
        nextLevelButton = true;
        showHintButton = false;
        showSpeechBubble = false;
        showSpeechBubble2 = false;
      });

      updateFirebaseData();
      ScoreManager.updateUserScore(); // You need to define this function
    } else {
      showTryAgainDialog();
    }

    String grandpaResponse = correctAnswer
        ? "The weather is $weather"
        : "The weather is $weather, not $userAnswer";

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

  void navigateToNextLevel() {
    if (currentLevelIndex < levels.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => levels[currentLevelIndex + 1]),
      );
    }
  }

  void showHint() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hint'),
          content: Text('The weather is $weather.'),
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

  void showCelebrationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('🎉🎉🎉 Your Answer is Correct. 🏆'),
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

  void showTryAgainDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: Text('Please try again.'),
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

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input'),
          content: TextField(
            controller: answerController,
            decoration: InputDecoration(hintText: 'Enter season (winter/rainy/summer)'),
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

  void setInitialSceneImage() {
    setRandomWeatherAndBackground();
  }

  void setRandomWeatherAndBackground() {
    List<String> weatherOptions = ['winter', 'rainy', 'summer'];
    Random random = Random();

    // Set random weather
    weather = weatherOptions[random.nextInt(weatherOptions.length)];

    // Set background based on weather
    switch (weather.toLowerCase()) {
      case 'winter':
        sceneImage = 'assets/winter.jpg';
        break;
      case 'rainy':
        sceneImage = 'assets/rainy.jpg';
        break;
      case 'summer':
        sceneImage = 'assets/summer.jpg';
        break;
      default:
        // Default background if weather is unknown
        sceneImage = 'assets/bg1.jpg';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  sceneImage,
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
                              ? 'Thank You' // Change the text here
                              : getSpeechBubbleText(),
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
                if (level2Attempts >= 2 && showHintButton)
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
        ),
      ),
    );
  }
}
