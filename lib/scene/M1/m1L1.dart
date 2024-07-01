import 'package:alzymer/scene/M1/M1L2.dart';
import 'package:alzymer/scene/M1/M1L3.dart';
import 'package:alzymer/scene/M1/M1L4.dart';
import 'package:alzymer/scene/M1/M1L5.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:alzymer/ScoreManager.dart';

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

class M1L1 extends StatefulWidget {
  @override
  _M1L1State createState() => _M1L1State();
}

class _M1L1State extends State<M1L1> {
  bool showStartButton = true;
  bool showAnswerButton = false;
  bool showSpeechBubble = false;
  bool showSpeechBubble2 = false;
  bool nextLevelButton = false;
  int M1L1Attempts = 0;
  bool showHintButton = true;
  String? gender;
  int M1L1Point = 0;

  String userAnswer = '';
  TextEditingController answerController = TextEditingController();

  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4(), M1L5()];
  int currentLevelIndex = 0;

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

  void updateFirebaseDataM1L1() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef = firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M1'
        DocumentReference scoreDocRef = userDocRef.collection('score').doc('M1');

        DocumentReference attemptDocRef = userDocRef.collection('attempt').doc('M1');

        // Update the fields in the 'score' document
        await scoreDocRef.update({
          'M1L1Point': M1L1Point,
        });
        await attemptDocRef.update({
          'M1L1Attempts': M1L1Attempts,
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  String getSpeechBubbleText() {
    if (gender == 'Male') {
      return "Hello Grandpa!! what is Today's Date?";
    } else if (gender == 'Female') {
      return "Hello grandma !! what is Today's Date?";
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
      return 'assets/old1.png';
    }
  }

  void submitAnswer() {
    M1L1Attempts++;
    bool correctAnswer = isAnswerCorrect(userAnswer);

    if (correctAnswer) {
      showCelebrationDialog();
      setState(() {
        showAnswerButton = false;
        nextLevelButton = true;
        showHintButton = false;
        showSpeechBubble = false;
        showSpeechBubble2 = false;
        M1L1Point = 1;
      });

      updateFirebaseDataM1L1();
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

  Future<void> _showDatePickerDialog() async {
  DateTime now = DateTime.now();
  DateTime initialDate = DateTime(now.year, 1, 1); // January 1st of the current year

  DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (selectedDate != null) {
    setState(() {
      userAnswer = DateFormat('dd/MM/yyyy').format(selectedDate);
    });

    // Delay the scroll to show the selected date
    Future.delayed(Duration(milliseconds: 200), () {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5, // Adjust as needed to center the date picker
        duration: Duration(milliseconds: 300),
      );
    });

    submitAnswer();
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
                            _showDatePickerDialog();
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
                if (M1L1Attempts >= 1 && showHintButton)
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
