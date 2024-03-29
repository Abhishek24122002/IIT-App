import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M1L5 extends StatefulWidget {
  @override
  _M1L5State createState() => _M1L5State();
}

class _M1L5State extends State<M1L5> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // int M1L5Attempts = 0;
  // int M1L5Point = 0;

  Future<void> updateFirebaseUserAnswer(String savedSequence) async {
    try {
      String userUid = await getCurrentUserUid();
      if (userUid.isNotEmpty) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M1');

        // Get the current user's answer map
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await scoreDocRef.get() as DocumentSnapshot<Map<String, dynamic>>;
        Map<String, dynamic> userAnswerMap =
            snapshot.data()?['userAnswer'] ?? {};

        // Create or update L5 and store the saved sequence
        userAnswerMap['L5'] = {'savedSequence': savedSequence};

        // Update the 'userAnswer' field in the 'Score-M1' document with the modified map
        await scoreDocRef.update({
          'userAnswer': userAnswerMap,
        });
      }
    } catch (e) {
      print('Error updating user answer in Firestore: $e');
    }
  }

  Future<String> getCurrentUserUid() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return user.uid;
      }
    } catch (e) {
      print('Error getting user UID: $e');
    }
    return ''; // Return an empty string if the user is not authenticated
  }

  // void updateFirebaseDataM1L5() async {
  //   try {
  //     FirebaseFirestore firestore = FirebaseFirestore.instance;
  //     String userUid = await getCurrentUserUid();

  //     if (userUid.isNotEmpty) {
  //       // Reference to the user's document
  //       DocumentReference userDocRef =
  //           firestore.collection('users').doc(userUid);

  //       // Reference to the 'score' document with document ID 'M1'
  //       DocumentReference scoreDocRef =
  //           userDocRef.collection('score').doc('M1');

  //       DocumentReference attemptDocRef =
  //           userDocRef.collection('attempt').doc('M1');

  //       // Update the fields in the 'score' document
  //       await scoreDocRef.update({
  //         'M1L5Point': M1L5Point,
  //       });
  //       await attemptDocRef.update({
  //         'M1L5Attempts': M1L5Attempts,
  //       });
  //     }
  //   } catch (e) {
  //     print('Error updating data: $e');
  //   }
  // }

  List<String> tasks = [
    'Fruit eated',
    'Helped Grandchild with Season',
    'Helped Grandchild with Date',
    'Picking Up Grandchild'
  ];
  String savedSequence = '';
  final List<String> correctSequence = [
    'Helped Grandchild with Date',
    'Helped Grandchild with Season',
    'Fruit eated',
    'Picking Up Grandchild'
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialPopup(); // Call the initialPopup function after the frame has been built
    });
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
                ' Task 5 ',
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
                'For this task, your objective is to choose the tasks you have completed in the previous level in the accurate order .',
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
                // M1L5Attempts++;
                // M1L5Point = 1;
                // updateFirebaseDataM1L5();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Done Sequence'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: tasks
                .map(
                  (task) => Draggable<String>(
                    data: task,
                    childWhenDragging: Container(
                      width: 150,
                      height: 70,
                      color: Colors.grey[300],
                      child: Center(
                        child: Text(
                          task,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                    feedback: Material(
                      elevation: 4.0,
                      child: Container(
                        width: 150,
                        height: 70,
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            task,
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    child: DragTarget<String>(
                      builder: (context, candidateData, rejectedData) {
                        return Card(
                          elevation:
                              6.0, // Increased elevation for a stronger shadow
                          shadowColor: Colors.grey[600], // Shadow color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.0), // Rounded corners for the card
                          ),
                          child: Container(
                            width: 150,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  10.0), // Rounded corners for the container
                            ),
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  task,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      onAccept: (data) {
                        setState(() {
                          int index = tasks.indexOf(data);
                          tasks[tasks.indexOf(task)] = data;
                          tasks[index] = task;
                        });
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            savedSequence = tasks.join(', ');
          });

          // Compare savedSequence with correctSequence
          if (savedSequence == correctSequence.join(', ')) {
            updateFirebaseUserAnswer(savedSequence);
            showCelebrationDialog();
          } else {
            showTryAgainDialog();
          }
        },
        child: Text('Save'),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: M1L5(),
    theme: ThemeData(
      primaryColor: Color.fromARGB(255, 94, 114, 228),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.indigo,
      ),
    ),
  ));
}
