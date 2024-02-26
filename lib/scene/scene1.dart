import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:alzymer/ScoreManager.dart'; // Import ScoreManager file

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
      constraints: BoxConstraints(maxWidth: 300), // Constrain the width of the SpeechBubble
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

class Scene1 extends StatefulWidget {
  @override
  _Scene1State createState() => _Scene1State();
}

class _Scene1State extends State<Scene1> {
  bool showSpeechBubble = false;
  bool showStartButton = true;
  bool showAnswerButton = false; // Set to false initially to hide the "Answer the Question" button
  String userAnswer = '';
  TextEditingController answerController = TextEditingController();

  // Function to check if the user's input matches the current date
  bool isAnswerCorrect(String input) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return input == formattedDate;
  }

  // Function to handle submitting the user's answer
  void submitAnswer() {
    // Check if the answer is correct
    bool correctAnswer = isAnswerCorrect(userAnswer);

    // Construct response messages
    String response;
    if (correctAnswer) {
      response = "Correct answer!";
      ScoreManager.updateUserScore(); // Update the score using ScoreManager
    } else {
      response = "Wrong answer, Grandpa.";
    }

    // Construct Grandpa's response with today's date or user's input
    String grandpaResponse = correctAnswer
        ? "Today's date is ${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
        : "Today's date is $userAnswer";

    // Show the responses
    setState(() {
      showSpeechBubble = true;
      userAnswer = grandpaResponse; // Show Grandpa's response with today's date or user's input
    });

    Future.delayed(Duration(seconds: 2), () {
      // Delay for a few seconds before showing child's response
      setState(() {
        userAnswer = response; // Show the child's response
        if (!correctAnswer) {
          // If the answer is wrong, show the "Answer the Question" button again
          showAnswerButton = true;
        }
      });
    });
  }

  // Input Dialog Function
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input'),
          content: TextField(
            controller: answerController,
            decoration: InputDecoration(hintText: 'Enter day/month/year'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                setState(() {
                  userAnswer = answerController.text;
                });
                // Process the input and update the UI accordingly
                submitAnswer(); // Check if the answer is correct
              },
              child: Text('Submit'),
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
        // Close the keyboard when tapping outside the TextField
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          resizeToAvoidBottomInset: true, // Set to true to resize the body when the keyboard appears
          body: SingleChildScrollView(
            child: Stack(
              children: [
                // Background image
                Image.asset(
                  'assets/bg1.jpg',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                // First little image
                Positioned(
                  top: 50.0,
                  left: -60.0,
                  child: Image.asset(
                    'assets/old1.png',
                    width: 500.0,
                    height: 500.0,
                  ),
                ),
                // Second little image and SpeechBubble
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
                          text: userAnswer,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 75.0,
                  left: 250.0,
                  child: Row( // Wrap the content in a Row
                    children: [
                      Visibility(
                        visible: showStartButton,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showSpeechBubble = true;
                              showStartButton = false;
                              // Change to true to show the "Answer the Question" button
                              showAnswerButton = true;
                              // Child initiates conversation
                              userAnswer = "Hello Grandpa, what is today's date?";
                            });
                          },
                          child: Text('Start'),
                        ),
                      ),
                      // Answer the Question Button
                      if (showAnswerButton)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showAnswerButton = false;
                            });
                            _showInputDialog(); // Call the function to show the dialog
                          },
                          child: Text('Answer the Question'),
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
}
