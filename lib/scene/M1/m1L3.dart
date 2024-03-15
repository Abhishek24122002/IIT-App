import 'package:alzymer/scene/M1/M1L1.dart';
import 'package:alzymer/scene/M1/M1L2.dart';
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

class M1L3 extends StatefulWidget {
  @override
  _M1L3State createState() => _M1L3State();
}

class _M1L3State extends State<M1L3> {
  bool showStartButton = true;
  bool showselectfruit = false;
  bool showSpeechBubble = false;
  bool nextLevelButton = false;
  // int level1Attempts = 0;
  String? gender;
  bool showtable = false;
  bool showBoyImage = true;
  bool showfruit = false;
  
  

  List<String> fruits = [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Strawberry',
    'Watermelon',
    'Pineapple',
    'Mango',
    'Kiwi',
    'Peach'
  ];

  List<String> getRandomFruits(List<String> fruits) {
    // Shuffle the original fruits list
    List<String> shuffledFruits = List.from(fruits)..shuffle();

    // Take the first 5 fruits from the shuffled list
    List<String> randomFruits = shuffledFruits.take(5).toList();

    return randomFruits;
  }

  String userAnswer = '';
  TextEditingController answerController = TextEditingController();

  List<Widget> levels = [M1L1(), M1L2(), M1L3(), M1L4(), M1L5()];
  int currentLevelIndex = 2;

  // bool isAnswerCorrect(String input) {
  //   DateTime now = DateTime.now();
  //   String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  //   return input == formattedDate;
  // }

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

  // void updateFirebaseData() async {
  //   try {
  //     FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     String userUid = getCurrentUserUid();

  //     if (userUid.isNotEmpty) {
  //       DocumentReference documentReference =
  //           firestore.collection('users').doc(userUid);

  //       await documentReference.update({
  //         'level3Attempts': level1Attempts,
  //       });
  //     }
  //   } catch (e) {
  //     print('Error updating data: $e');
  //   }
  // }

  String getSpeechBubbleText() {
    if (gender == 'Male') {
      return "Hey Grandpa ,I have to go school now, It will' finish by 3:00 today.";
    } else if (gender == 'Female') {
      return "Hey Grandma ,I have to go school now, It will' finish by 3:00 today.";
    } else {
      return "Hey, I have to go to school now. It will' finish by 3:00 today.";
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

  void showFruitButtons(List<String> randomFruits) {
    setState(() {
      // Reset selected fruit
      showselectfruit = false; // Hide the "Sure" button
      showSpeechBubble = false;
      showBoyImage = false;
      showtable = true;
      showfruit = true;
      fruits = randomFruits;
    });
  }

  void showinstruction() {
    List<String> randomFruits = getRandomFruits(fruits);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Instruction'),
          content: Text('Please Select Fruit From Table'),
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

  // void showTryAgainDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Oops!'),
  //         content: Text('Please try again.'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                  right: 120.0,
                  child: Image.asset(
                    'assets/clock10.png',
                    width: 100.0,
                    height: 100.0,
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  right: 20.0,
                  child: Visibility(
                    // Wrap boy2 image in a Visibility widget
                    visible:
                        showBoyImage, // Control visibility based on showBoyImage variable
                    child: Image.asset(
                      'assets/boy2.png',
                      width: 200.0,
                      height: 300.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
                  right: 20,
                  child: Visibility(
                    // Wrap table image in a Visibility widget
                    visible:
                        showtable, // Control visibility based on showBoyImage variable
                    child: Image.asset(
                      'assets/table2.png',
                      width: 300.0,
                      height: 300.0,
                    ),
                  ),
                ),
                Positioned(
                  top: 70.0,
                  right: 110.0,
                  child: Visibility(
                    // Wrap boy2 image in a Visibility widget
                    visible:
                        showfruit, // Control visibility based on showBoyImage variable
                    child: Image.asset(
                      'assets/fruit.png',
                      width: 120.0,
                      height: 120.0,
                    ),
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
                              showselectfruit = true;
                            });
                          },
                          child: Text('Start'),
                        ),
                      ),
                      if (showselectfruit)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSpeechBubble = false;
                              showBoyImage = false;
                              showtable = true;
                              showfruit = true;

                              showinstruction();
                            });
                          },
                          child: Text('Sure'),
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
                // if (level1Attempts >= 1 && showHintButton)
                //   Positioned(
                //     bottom: 20.0,
                //     right: 30.0,
                //     child: ElevatedButton(
                //       onPressed: () {
                //         // showHint();
                //       },
                //       child: Text('Show Hint'),
                //     ),
                //   ),
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
