import 'dart:math';
import 'package:alzymer/ScoreManager.dart';
import 'package:alzymer/scene/M1/M1L1.dart';
import 'package:alzymer/scene/M1/M1L3.dart';
import 'package:alzymer/scene/M1/M1L4.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

// buttons
import 'package:alzymer/components/start_button.dart';
import 'package:alzymer/components/answer_button.dart';
import 'package:alzymer/components/next_level_button.dart';

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

class M1L2 extends StatefulWidget {
  @override
  _M1L2State createState() => _M1L2State();
}

class _M1L2State extends State<M1L2> {
  bool showStartButton = true;
  bool showAnswerButton = false;
  bool showSpeechBubble = false;
  bool showSpeechBubble2 = false;
  bool nextLevelButton = false;
  int level2Attempts = 0;
  bool showHintButton = false;
  String? gender;
  String userAnswer = '';
  String weather = '';
  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4()];
  int currentLevelIndex = 1;
  String sceneImage = 'assets/bg1.png';
  int M1L2Attempts = 0;
  int M1L2Point = 0;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
    setInitialSceneImage();

    // Set landscape orientation when entering this page
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

  bool isAnswerCorrect(String userAnswer, String weather) {
    return userAnswer.toLowerCase() == weather.toLowerCase();
  }

  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseDataM1L2() async {
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
          'M1L2Point': M1L2Point,
        });
        await attemptDocRef.update({
          'M1L2Attempts': M1L2Attempts,
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
      return "hey, do you know what season it is right now?";
    } else {
      return "Hey, do you know what season it is right now?";
    }
  }

  // String getSpeechBubbleImage() {
  //   if (gender == 'Male') {
  //     return 'assets/old1.png';
  //   } else if (gender == 'Female') {
  //     return 'assets/old1-lady.png';
  //   } else {
  //     return 'assets/old1.png';
  //   }
  // }
  String getSpeechBubbleImage() {
    if (gender == 'Male') {
      return 'assets/old1.png';
    } else if (gender == 'Female') {
      return 'assets/old1.png';
    } else {
      return 'assets/old1.png';
    }
  }

  void submitAnswer(String selectedAnswer) {
    M1L2Attempts++;
    level2Attempts++;

    bool correctAnswer = isAnswerCorrect(selectedAnswer, weather);

    if (correctAnswer) {
      showCelebrationDialog();
      setState(() {
        showAnswerButton = false;
        nextLevelButton = true;
        showHintButton = false;
        showSpeechBubble = false;
        showSpeechBubble2 = false;
        M1L2Point = 1;
      });

      updateFirebaseDataM1L2();
      ScoreManager.updateUserScore(2); // You need to define this function
    } else {
      showTryAgainDialog();
      if (level2Attempts >= 2) {
        setState(() {
          showHintButton = true;
        });
      }
    }

    setState(() {
      userAnswer = '';
      showAnswerButton = true;
    });
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

  void showHint() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hint'),
          content: Text('The season is $weather.'),
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
        sceneImage = 'assets/winter.png';
        break;
      case 'rainy':
        sceneImage = 'assets/rainy.png';
        break;
      case 'summer':
        sceneImage = 'assets/summer.png';
        break;
      default:
        // Default background if weather is unknown
        sceneImage = 'assets/bg1.png';
        break;
    }
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select the season"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  submitAnswer('winter');
                },
                child: Text('Winter'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  submitAnswer('rainy');
                },
                child: Text('Rainy'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  submitAnswer('summer');
                },
                child: Text('Summer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(sceneImage),
            fit: BoxFit.fill,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Stack(
              children: [
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
                  left: 20.0,
                  right: 20.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT SIDE — Start, Answer, Hint
                      Row(
                        children: [
                          if (showStartButton)
                            StartButton(
                              onPressed: () {
                                setState(() {
                                  showSpeechBubble = true;
                                  showStartButton = false;
                                  showAnswerButton = true;
                                });
                              },
                            ),
                          if (showAnswerButton && !nextLevelButton)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AnswerButton(
                                onPressed: _showInputDialog,
                              ),
                            ),
                          if (showHintButton)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: showHint,
                                child: const Text(
                                  'Hint',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // RIGHT SIDE — Next Level
                      if (nextLevelButton)
                        NextLevelButton(
                          onPressed: navigateToNextLevel,
                        ),
                    ],
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
    // Revert to original orientation when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
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
                ' Task 2 ',
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
                'In this task, Observe the  Game Environment to Complete the Task.',
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
}
