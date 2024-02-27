import 'package:flutter/material.dart';

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

class two extends StatefulWidget {
  @override
  _twoState createState() => _twoState();
}

class _twoState extends State<two> {
  bool showSpeechBubble = false;
  bool showInputPopup = false;
  bool showStartButton = true;
  bool showAnswerButton = false;
  String userAnswer = '';
  TextEditingController answerController = TextEditingController();

  // Input Dialog Function
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input'),
          content: TextField(
            controller: answerController,
            decoration: InputDecoration(hintText: 'Enter your answer'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                setState(() {
                  showInputPopup = false;
                  userAnswer = answerController.text;
                });
                // Process the input and update the UI accordingly
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
                  'assets/winter.jpg',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
                // First little image
                Positioned(
                  top: 50.0,
                  left: -130.0,
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
                          text: userAnswer.isNotEmpty
                              ? ' Thank You'
                              : "Hey Grandpa, do you know what season it is right now?",
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
                // Start Button
                if (showStartButton)
                  Positioned(
                    bottom: 20.0,
                    left: 30.0,
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
                // Answer the Question Button
                if (showAnswerButton)
                  Positioned(
                    bottom: 20.0,
                    left: 30.0,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showInputPopup = true;
                        });
                        _showInputDialog(); // Call the function to show the dialog
                      },
                      child: Text('Answer the Question'),
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

