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
import 'package:alzymer/scene/M1/M1L5.dart';
import 'package:alzymer/ScoreManager.dart';
import 'package:flutter/cupertino.dart';

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
  bool nextLevelButton = false;
  int M1L1Attempts = 0;
  bool showHintButton = false;
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

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: Text('Hint'),
    //       content: Text('The current date is $formattedDate'),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.pop(context);
    //           },
    //           child: Text('OK'),
    //         ),
    //       ],
    //     );
    //   },
    // );
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
                  right: 100,
                  child: Row(
                    children: [
                      if (showStartButton)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showStartButton = false;
                              showAnswerButton = true;
                              showSpeechBubble = true;
                            });
                          },
                          child: Text('Start'),
                        ),
                      if (showAnswerButton)
                        ElevatedButton(
                          onPressed: () {
                            _showDatePickerDialog();
                          },
                          child: Text('Answer'),
                        ),
                      if (nextLevelButton)
                        ElevatedButton(
                          onPressed: () {
                            navigateToNextLevel();
                          },
                          child: Text('Next Level'),
                        ),
                      if (showHintButton)
                        ElevatedButton(
                          onPressed: () {
                            showHint();
                          },
                          child: Text('Hint'),
                        ),
                    ],
                  ),
                ),
                if (showSpeechBubble)
                  Positioned(
                    top: 120.0,
                    left: 160.0,
                    child: SpeechBubble(
                      text: getSpeechBubbleText(),
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
   int selectedDay = 1;  // Set to 1 for January 1st
  int selectedMonth = 1;  // Set to 1 for January
  int selectedYear = DateTime.now().year;

  List<int> getDaysInMonth(int month, int year) {
    return List.generate(
      DateTime(year, month + 1, 0).day,
      (index) => index + 1,
    );
  }

 @override
Widget build(BuildContext context) {
  return AlertDialog(
    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    title: Center(
        child: Text('Select Date',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))),
    content: Container(
      height: 160,  // Adjusted height to accommodate headings
      child: Column(
        children: [
          // Add a row for the headings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Center(child: Text('Day', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ),
              Expanded(
                child: Center(child: Text('Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ),
              Expanded(
                child: Center(child: Text('Year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ),
            ],
          ),
          SizedBox(height: 10),  // Add spacing between headings and pickers
          // Row for the pickers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 60,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedDay = index + 1;
                    });
                  },
                  children: getDaysInMonth(selectedMonth, selectedYear)
                      .map((day) => Center(child: Text(day.toString())))
                      .toList(),
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedDay - 1,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 60,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedMonth = index + 1;
                    });
                  },
                  children: List.generate(12, (index) => index + 1)
                      .map((month) => Center(child: Text(month.toString())))
                      .toList(),
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedMonth - 1,
                  ),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 60,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedYear = DateTime.now().year - index;
                    });
                  },
                  children: List.generate(
                          100, (index) => DateTime.now().year - index)
                      .map((year) => Center(child: Text(year.toString())))
                      .toList(),
                  scrollController: FixedExtentScrollController(
                    initialItem: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () {
          DateTime selectedDate =
              DateTime(selectedYear, selectedMonth, selectedDay);
          widget.onDateSelected(selectedDate);
        },
        child: Text('OK', style: TextStyle(color: Colors.blue, fontSize: 16)),
      ),
    ],
  );
}
}
