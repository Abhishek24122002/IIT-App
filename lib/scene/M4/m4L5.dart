import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MaterialApp(
    home: M4L5(),
  ));
}

class M4L5 extends StatefulWidget {
  @override
  _M4L5State createState() => _M4L5State();
}

class _M4L5State extends State<M4L5> {
  Offset targetPosition = Offset(100, 100);
  double targetRadius = 30;
  int score = 0;
  int timeLeft = 60; // Game duration in seconds
  bool gameEnded = false;
  bool gameStarted = false; // To track if the game has started
  Timer? gameTimer;
  Timer? targetTimer;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
  }

  void startGame() {
    setState(() {
      gameEnded = false;
      gameStarted = true;
      score = 0;
      timeLeft = 60;
      generateNewTarget();
      startTimers();
    });
  }

  void startTimers() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft <= 0) {
        timer.cancel();
        endGame();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });

    targetTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (!gameEnded && gameStarted) {
        generateNewTarget();
      }
    });
  }

  void endGame() {
    setState(() {
      gameEnded = true;
      gameStarted = false;
      Vibration.vibrate(duration: 500); // End game vibration
      gameTimer?.cancel();
      targetTimer?.cancel();
    });
  }

  void generateNewTarget() {
    final size = MediaQuery.of(context).size;
    setState(() {
      targetPosition = Offset(
        random.nextDouble() * (size.width - targetRadius * 2),
        random.nextDouble() * (size.height - targetRadius * 2 - 100) + 100,
      );
      targetRadius = random.nextDouble() * 10 + 10; // Varying target size
    });
  }

  void handleTap(TapDownDetails details) async {
    if (gameEnded || !gameStarted) return;

    double distance = (details.localPosition - targetPosition).distance;
    if (distance < targetRadius) {
      setState(() {
        score += (100 - distance).toInt();
        generateNewTarget();
      });

      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 50); // Successful placement vibration
      }
    } else {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 100); // Missed target vibration
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('O\'Connor Finger Dexterity Task')),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: handleTap,
            child: Stack(
              children: [
                if (gameStarted)
                  Positioned(
                    top: targetPosition.dy,
                    left: targetPosition.dx,
                    child: CircleAvatar(
                      radius: targetRadius,
                      backgroundColor: Colors.blue,
                    ),
                  ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: Text('Score: $score', style: TextStyle(fontSize: 24)),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: Text('Time Left: $timeLeft', style: TextStyle(fontSize: 24)),
                ),
                if (gameEnded)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Game Over', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        Text('Final Score: $score', style: TextStyle(fontSize: 24)),
                        SizedBox(height: 20),
                        Text('Tap "Play Again" to restart', style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: startGame,
                          child: Text('Play Again'),
                        ),
                      ],
                    ),
                  ),
                if (!gameStarted && !gameEnded)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Welcome to the O\'Connor Finger Dexterity Task', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        Text('Tap the blue circle as quickly and accurately as possible.', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20),
                        Text('The target will disappear if not tapped in time.', style: TextStyle(fontSize: 20)),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: startGame,
                          child: Text('Start Task'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    targetTimer?.cancel();
    super.dispose();
  }
}
