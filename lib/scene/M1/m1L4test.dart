import 'package:alzymer/scene/M1/M1L2.dart';
import 'package:alzymer/scene/M1/M1L3.dart';
import 'package:alzymer/scene/M1/m1L1.dart';
import 'package:alzymer/scene/M1/m1L4.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:alzymer/ScoreManager.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final bool isGrandfather;

  SpeechBubble({required this.text, required this.isGrandfather});

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

class M1L5 extends StatefulWidget {
  @override
  _M1L5State createState() => _M1L5State();
}

class _M1L5State extends State<M1L5> {
  bool showStartButton = true;
  bool showcontinuebutton = false;
  bool showAnswerButton = false;
  bool showSpeechBubble = false;
  bool showSpeechBubble2 = false;
  bool nextLevelButton = false;
  int M1L5Attempts = 0;
  bool showHintButton = true;
  String? gender;
  int M1L5Point = 0;
  int pointer = 0;
  int currentIndex = 0;
  String selectedTime = '';
  bool showTimeSelectionButtons = false;

  final List<String> grandfatherSpeech = [
    "Hey, son! Good to see you. How was your day?",
    "School ends at", // Placeholder for selected time
    "Yes Sure, I'll take care of it.",
  ];
  final List<String> sonSpeech = [
    "Busy, as always. Got some urgent work today. What time does the grandchild's school finish?",
    "Can you pick him today? I have some urgent office work now.",
    "Thank You, "
  ];
  void pickTime(String time) {
    setState(() {
      selectedTime = time;
      showcontinuebutton = true;
    });
  }

  String userAnswer = '';
  TextEditingController answerController = TextEditingController();

  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4(), M1L5()];
  int currentLevelIndex = 4;

  bool isAnswerCorrect(String input) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return input == formattedDate;
  }

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

  void updateFirebaseDataM1L5() async {
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
          'M1L5Point': M1L5Point,
        });
        await attemptDocRef.update({
          'M1L5Attempts': M1L5Attempts,
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  // String getSpeechBubbleText() {
  //   if (gender == 'Male') {
  //     return "Hi, Dad! How's it going?";
  //   } else if (gender == 'Female') {
  //     return "Hi, Mom! How's it going?";
  //   } else {
  //     return "Hi,How's it going?";
  //   }
  // }

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
    M1L5Attempts++;
    bool correctAnswer = isAnswerCorrect(userAnswer);

    if (correctAnswer) {
      showCelebrationDialog();
      setState(() {
        showAnswerButton = false;
        nextLevelButton = true;
        showHintButton = false;
        showSpeechBubble = false;
        showSpeechBubble2 = false;
        M1L5Point = 1;
      });

      updateFirebaseDataM1L5();
      ScoreManager.updateUserScore(1);
    } else {
      showTryAgainDialog();
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
        return SingleChildScrollView(
          child: AlertDialog(
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
                  bottom: 20.0,
                  right: 20.0,
                  child: Image.asset(
                    'assets/man2.png',
                    width: 200.0,
                    height: 300.0,
                  ),
                ),

                Positioned(
                  top: 150.0, // Adjust the top position for son's speech bubble
                  right: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: !showSpeechBubble &&
                            showSpeechBubble2 &&
                            !showStartButton,
                        child: SpeechBubble(
                          text: sonSpeech[currentIndex ~/ 2],
                          isGrandfather: false,
                        ),
                      ),
                    ],
                  ),
                ),
                // Inside the build method, where grandfather's speech bubble is displayed

// Inside the build method, where grandfather's speech bubble is displayed
                Positioned(
                  top:
                      150.0, // Adjust the top position for grandfather's speech bubble
                  left: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
  visible: showSpeechBubble && !showSpeechBubble2 && !showStartButton,
  child: SpeechBubble(
    text: grandfatherSpeech[currentIndex ~/ 2], // Display grandfather's speech
    isGrandfather: true,
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
                              showcontinuebutton = true;
                            });
                          },
                          child: Text('Start'),
                        ),
                      ),
                      Visibility(
                        visible: showcontinuebutton,
                        child: ElevatedButton(
                          onPressed: () {
                            changeSpeech();
                          },
                          child: Text('Contine'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showAnswerButton)
                  Positioned(
                    bottom: 20.0,
                    left: 30.0,
                    child: ElevatedButton(
                      onPressed: () {
                        _showInputDialog();
                      },
                      child: Text('Answer the Question '),
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
                if (M1L5Attempts >= 1 && showHintButton)
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

  void changeSpeech() {
    setState(() {
      currentIndex++;
      if (currentIndex >= sonSpeech.length * 2) {
        currentIndex = 0; // Loop back to the start
      }
      if (currentIndex % 2 == 0) {
        showSpeechBubble = true;
        showSpeechBubble2 = false;
      } else {
        showSpeechBubble = false;
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            showSpeechBubble2 = true;
          });
        });
      }
    });
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
