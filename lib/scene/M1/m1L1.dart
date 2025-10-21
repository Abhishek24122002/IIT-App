import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:alzymer/scene/M1/M1L2.dart';
import 'package:alzymer/scene/M1/M1L3.dart';
import 'package:alzymer/scene/M1/M1L4.dart';
import 'package:alzymer/ScoreManager.dart';

// buttons
import 'package:alzymer/components/start_button.dart';
import 'package:alzymer/components/answer_button.dart';
import 'package:alzymer/components/next_level_button.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final bool isFromGrandchild;

  SpeechBubble({required this.text, required this.isFromGrandchild});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isFromGrandchild ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(10.0),
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
        constraints: BoxConstraints(maxWidth: 300),
        child: Text(
          text,
          style: TextStyle(fontSize: 16.0),
          textAlign: TextAlign.center,
        ),
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
  bool nextLevelButton = false;
  int M1L1Attempts = 0;
  bool showHintButton = false;
  String? gender;
  int M1L1Point = 0;

  String userAnswer = '';
  String grandchildMessage = '';
  String grandpaMessage = '';

  TextEditingController answerController = TextEditingController();

  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4()];
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
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M1'
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M1');

        DocumentReference attemptDocRef =
            userDocRef.collection('attempt').doc('M1');

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
      return "Hello !! what is Today's Date?";
    } else {
      return "Hello !! what is Today's Date?";
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

  void submitAnswer() {
    M1L1Attempts++;
    bool correctAnswer = isAnswerCorrect(userAnswer);

    if (correctAnswer) {
      // showCelebrationDialog();
      setState(() {
        showAnswerButton = false;
        nextLevelButton = true;
        showHintButton = false;
        showSpeechBubble = false;
        M1L1Point = 1;
        grandchildMessage = ''; // <-- Hide grandchild bubble
        grandpaMessage =
            "Today's date is ${DateFormat('dd/MM/yyyy').format(DateTime.now())}";
        showSpeechBubble =
            true; // Optional: can be removed if you use message strings
      });

      updateFirebaseDataM1L1();
      ScoreManager.updateUserScore(1);
    } else {
      setState(() {
        showHintButton = true;
      });
      showTryAgainDialog();
    }

    String grandpaResponse = correctAnswer
        ? "Today's date is ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
        : "Today's date is $userAnswer";

    setState(() {
      showSpeechBubble = true;
      userAnswer = grandpaResponse;
      grandpaMessage =
          "Today's date is ${DateFormat('dd/MM/yyyy').format(DateTime.now())}";
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
    showDialog(
      context: context,
      barrierDismissible: false, // prevent tap outside to close
      builder: (BuildContext context) {
        return CustomDatePicker(
          onDateSelected: (selectedDate) {
            setState(() {
              userAnswer = DateFormat('dd/MM/yyyy').format(selectedDate);
            });
            bool correctAnswer = isAnswerCorrect(userAnswer);
            Navigator.pop(context);
            if (correctAnswer) {
              submitAnswer();
              showCelebrationDialog();
            } else {
              showTryAgainDialog();
            }
          },
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
                  top: 60.0,
                  left: -130.0,
                  child: Image.asset(
                    getSpeechBubbleImage(),
                    width: 450,
                    height: 450,
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
                                  showStartButton = false;
                                  showAnswerButton = true;
                                  showSpeechBubble = true;
                                  grandchildMessage = getSpeechBubbleText();
                                  grandpaMessage = '';
                                });
                              },
                            ),
                          if (showAnswerButton)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AnswerButton(
                                onPressed: _showDatePickerDialog,
                              ),
                            ),
                          if (showHintButton)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: showHint,
                                child: Text(
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
                if (grandchildMessage.isNotEmpty)
                  Positioned(
                    top: 100.0,
                    right: 200.0, // Grandchild on right
                    child: SpeechBubble(
                      text: grandchildMessage,
                      isFromGrandchild: true,
                    ),
                  ),
                if (grandpaMessage.isNotEmpty)
                  Positioned(
                    top: 100.0,
                    left: 160.0, // Grandpa on left
                    child: SpeechBubble(
                      text: grandpaMessage,
                      isFromGrandchild: false,
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

class CustomDatePicker extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  CustomDatePicker({required this.onDateSelected});

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  int selectedDay = 0;
  int selectedMonth = 0;
  int selectedYear = 2000;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        width: 400, // wider popup
        height: 300,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Select Date',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabeledPicker('Date', 0, 31, selectedDay,
                      (val) => setState(() => selectedDay = val)),
                  _buildLabeledPicker('Month', 0, 12, selectedMonth,
                      (val) => setState(() => selectedMonth = val)),
                  _buildLabeledPicker('Year', 1900, 2100, selectedYear,
                      (val) => setState(() => selectedYear = val)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDay == 0 || selectedMonth == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Date and Month cannot be zero.")),
                  );
                  return;
                }

                try {
                  final selected =
                      DateTime(selectedYear, selectedMonth, selectedDay);
                  widget.onDateSelected(selected);
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("Invalid date")));
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledPicker(String label, int start, int end, int selected,
      Function(int) onSelected) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Expanded(
            child: CupertinoPicker(
              scrollController:
                  FixedExtentScrollController(initialItem: selected - start),
              itemExtent: 40,
              onSelectedItemChanged: (index) => onSelected(start + index),
              children: List.generate(end - start + 1, (index) {
                final val = start + index;
                return Center(
                    child:
                        Text(val.toString(), style: TextStyle(fontSize: 20)));
              }),
            ),
          ),
        ],
      ),
    );
  }
}
