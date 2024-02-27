import 'package:flutter/material.dart';

import 'scene/one.dart';
import 'scene/two.dart';

class LevelSelectionScreen extends StatelessWidget {
  final int totalLevels = 20;
  final int levelsPerRow = 4;
  final int userScore;

  LevelSelectionScreen({required this.userScore});

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
            bool isUnlocked = index <= userScore;
            return LevelButton(index + 1, isUnlocked);
          },
        ),
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int level;
  final bool isUnlocked;

  LevelButton(this.level, this.isUnlocked);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isUnlocked) {
          // Navigate to different scenes based on the selected level
          // Example: Level 1 goes to 'one()' and Level 2 goes to 'two()'
          // You can customize this based on your scene structure
          // Add more conditions for other levels
          if (level == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => one()),
            );
          } else if (level == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => two()),
            );
          }
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
              color: isUnlocked ? Colors.blue : Colors.grey,
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
          if (!isUnlocked)
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

