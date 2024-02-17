import 'package:alzymer/scene/scene1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LevelSelectionScreen(),
    );
  }
}

class LevelSelectionScreen extends StatelessWidget {
  final int totalLevels = 20;
  final int levelsPerRow = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level Selection'),
      ),
      body: Center(
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: levelsPerRow,
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 16.0,
          ),
          itemCount: totalLevels,
          itemBuilder: (context, index) {
            return LevelButton(index + 1, index < totalLevels - 1);
          },
        ),
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int level;
  final bool hasNextLevel;

  LevelButton(this.level, this.hasNextLevel);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (level == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Scene1()),
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$level',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          if (level != 1)
            Positioned(
              child: Icon(
                Icons.lock,
                color: Colors.white,
                size: 30.0,
              ),
            ),
        ],
      ),
    );
  }
}
