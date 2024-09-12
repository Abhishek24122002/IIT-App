import 'package:flutter/material.dart';
import 'dart:async';

class M4L4 extends StatefulWidget {
  @override
  _M4L4State createState() => _M4L4State();
}

class _M4L4State extends State<M4L4> {
  int tapCount = 0;
  bool isGameStarted = false;
  int timeLeft = 10;
  Timer? timer;

  void startGame() {
    setState(() {
      tapCount = 0;
      timeLeft = 10;
      isGameStarted = true;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });
      if (timeLeft == 0) {
        timer.cancel();
        setState(() {
          isGameStarted = false;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tapping Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Taps: $tapCount', style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            Text('Time left: $timeLeft', style: TextStyle(fontSize: 32)),
            SizedBox(height: 50),
            isGameStarted
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        tapCount++;
                      });
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.blue,
                      child: Center(
                        child: Text('Tap Me', style: TextStyle(fontSize: 24, color: Colors.white)),
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: startGame,
                    child: Text('Start Game'),
                  ),
          ],
        ),
      ),
    );
  }
}
