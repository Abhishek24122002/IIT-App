import 'package:alzymer/level_selection.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CharacterSelection(),
    );
  }
}

class CharacterSelection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Your Character'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First character
            Container(
              margin: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/old1.png', // replace with your first character image path
                    width: 300.0,
                    height: 300.0,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      // Handle choose button press for the first character
                      _handleChooseCharacter(context, 'Old Character');
                    },
                    child: Text('Choose'),
                  ),
                ],
              ),
            ),
            // Second character
            Container(
              margin: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.asset(
                    'assets/boy1.png', // replace with your second character image path
                    width: 200.0,
                    height: 300.0,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: () {
                      // Handle choose button press for the second character
                      _handleChooseCharacter(context, 'Boy Character');
                    },
                    child: Text('Choose'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to handle character selection
  void _handleChooseCharacter(BuildContext context, String characterName) {
    // Navigate to the LevelSelectionScreen after choosing a character
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LevelSelectionScreen(),
      ),
    );
  }
}

