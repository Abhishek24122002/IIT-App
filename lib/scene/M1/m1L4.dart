import 'package:alzymer/scene/M2/m2L1.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class M1L4 extends StatefulWidget {
  @override
  _M1L4State createState() => _M1L4State();
}

class _M1L4State extends State<M1L4> {
  List<String> selectedTasks = [];
  int M1L4Point = 0;
  List<String> allTasks = [
    'Fruit eaten',
    'Helped Grandchild with Season',
    'Helped Grandchild with Date'
  ];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    allTasks.shuffle();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialPopup();
    });
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
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);
        DocumentReference scoreDocRef =
            userDocRef.collection('score').doc('M1');

        await scoreDocRef.update({
          'M1L4Point': M1L4Point,
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  void initialPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              ' Task 4 ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                color: Color.fromARGB(255, 94, 114, 228),
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 158, 124, 193),
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                'For this task, your objective is to choose the tasks you have completed in the previous level in the accurate order.',
                style: TextStyle(fontSize: 14.0, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Got it!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 94, 114, 228),
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        );
      },
    );
  }

  void onSavePressed() {
    setState(() {
      if (_checkSequence()) {
        M1L4Point = 1;
        updateFirebaseDataM1L4();
        _showCorrectDialog();
      } else {
        _showIncorrectDialog();
      }
    });
  }

  bool _checkSequence() {
    List<String> correctSequence = [
      'Helped Grandchild with Date',
      'Helped Grandchild with Season',
      'Fruit eaten'
    ];
    return selectedTasks.length == correctSequence.length &&
        List.generate(selectedTasks.length,
                (index) => selectedTasks[index] == correctSequence[index])
            .every((element) => element);
  }

  void _showCorrectDialog() {
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => M2L1()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showIncorrectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: Text('Your answer is incorrect. Please try again.'),
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

  void moveToAllTasks(String task) {
    setState(() {
      selectedTasks.remove(task);
      allTasks.add(task);
    });
  }

  void moveToSelectedTasks(String task) {
    if (selectedTasks.length < 3) {
      setState(() {
        selectedTasks.add(task);
        allTasks.remove(task);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Tasks Sequence:"),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected slots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  3,
                  (index) => GestureDetector(
                    onTap: selectedTasks.length > index
                        ? () => moveToAllTasks(selectedTasks[index])
                        : null,
                    child: Container(
                      width: 180,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 1.2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Text(
                        selectedTasks.length > index
                            ? selectedTasks[index]
                            : "${index + 1}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selectedTasks.length > index
                              ? Colors.orange
                              : Colors.grey,
                        ),
                      ),  
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // All tasks
              Text(
                "All Tasks:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allTasks
                    .map((task) => GestureDetector(
                          onTap: () => moveToSelectedTasks(task),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.lightBlue,
                                  Colors.blue
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Text(
                              task,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 10),

              Center(
                child: ElevatedButton(
                  onPressed: onSavePressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "Confirm Order",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: M1L4(),
    theme: ThemeData(
      primaryColor: Color.fromARGB(255, 94, 114, 228),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.indigo,
      ),
    ),
  ));
}
