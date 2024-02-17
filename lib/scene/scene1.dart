import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeechBubble extends StatelessWidget {
    final String text;

  SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
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
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}

class Scene1 extends StatelessWidget {
  final String question = 'What is the date today?';
  final String answer = 'Today is February 17, 2024';

  @override
  @override
  Widget build(BuildContext context) {
    // Set the preferred screen orientation to landscape
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight,
    // ]);

    // Hide the system overlay (status bar and navigation bar)
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersive,
      overlays: [
        SystemUiOverlay.bottom,
        SystemUiOverlay.top,
      ],
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/bg1.jpg', // replace with your background image path
              fit: BoxFit.cover,
            ),
            // First little image
            Positioned(
              top: 50.0,
              left: -60.0,
              child: Image.asset(
                'assets/old1.png', // replace with your first image path
                width: 500.0,
                height: 500.0,
              ),
            ),
            // Second little image and SpeechBubble
            Positioned(
              bottom: 20.0,
              right: 20.0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/boy1.png', // replace with your second image path
                    width: 200.0,
                    height: 300.0,
                  ),
                ],
              ),
            ),
            // Display stored answers in new SpeechBubble
            Positioned(
              top: 75.0,
              left: 250.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpeechBubble(
                    text: answer,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 170.0,
              left: 430.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SpeechBubble(
                    text: question,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}