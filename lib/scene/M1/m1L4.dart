import 'package:alzymer/scene/M1/M1L5.dart';
import 'package:alzymer/scene/M1/m1L1.dart';
import 'package:alzymer/scene/M1/m1L2.dart';
import 'package:alzymer/scene/M1/m1L3.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:alzymer/ScoreManager.dart';

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

class M1L4 extends StatefulWidget {
  @override
  _M1L4State createState() => _M1L4State();
}

class _M1L4State extends State<M1L4> {
  bool showStartButton = true;
  bool showAnswerButtons = false;
  bool showSpeechBubble = false;
  bool nextLevelButton = false;
  int M1L4Attempts = 0;
  bool showHintButton = true;
  String? gender;
  int M1L4Point = 0;

  String userAnswer = '';

  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4(), M1L5()];
  int currentLevelIndex = 3;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    fetchGender();
    // Set landscape orientation when entering this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
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

  void updateFirebaseDataM1L4() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M1'
        DocumentReference scoreDocRef = userDocRef.collection('score').doc('M1');

        DocumentReference attemptDocRef =
            userDocRef.collection('attempt').doc('M1');

        // Update the fields in the 'score' document
        await scoreDocRef.update({
          'M1L4Point': M1L4Point,
        });
        await attemptDocRef.update({
          'M1L4Attempts': M1L4Attempts,
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  String getSpeechBubbleText() {
    if (gender == 'Male') {
      return "Hello Dad !! What is today's school pickup time of Chintu?";
    } else if (gender == 'Female') {
      return "Hello mom !! What is today's school pickup time of Chintu?";
    } else {
      return "Hello!! What is today's school pickup time of Chintu?";
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

  void submitAnswer(String time) {
  M1L4Attempts++;

  String pickupTime = "3:00 PM";

  if (time == pickupTime) {
    showCelebrationDialog();
    setState(() {
      showAnswerButtons = false;
      nextLevelButton = true;
      showHintButton = false;
      showSpeechBubble = false;
      M1L4Point = 1;
    });

    updateFirebaseDataM1L4();
    ScoreManager.updateUserScore(1);
  } else {
    showTryAgainDialog();
  }

  setState(() {
    showSpeechBubble = true;
    userAnswer = 'Today\'s pickup time is $pickupTime';
  });
}


     

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Pickup Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  submitAnswer('1:00 PM');
                },
                child: Text('1:00 PM'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  submitAnswer('2:00 PM');
                },
                child: Text('2:00 PM'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  submitAnswer('3:00 PM');
                },
                child: Text('3:00 PM'),
              ),
            ],
          ),
        );
      },
    );
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
    String pickupTime = DateFormat('hh:mm a').format(DateTime.now());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hint'),
          content: Text('Today\'s pickup time is $pickupTime'),
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
                  right: 130.0,
                  child: Image.asset(
                    'assets/clock3.png',
                    width: 90.0,
                    height: 90.0,
                  ),
                ),
              Positioned(
                bottom: -50.0,
                right: 20.0,
                child: Image.asset(
                  'assets/man2.png',
                  width: 200.0,
                  height: 400.0,
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
                            ? 'Please pick him from school. I have some urgent office work now' // Change the text here
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
                            showAnswerButtons = true;
                          });
                        },
                        child: Text('Start'),
                      ),
                    ),
                    if (showAnswerButtons)
                      ElevatedButton(
                        onPressed: () {
                          _showInputDialog();
                        },
                        child: Text('Select Pickup Time'),
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
              if (M1L4Attempts >= 1 && showHintButton)
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

  @override
  void dispose() {
    // Revert to original orientation when leaving this page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
