import 'package:flutter/material.dart';

import 'scene/one.dart';
import 'scene/three.dart';
import 'scene/two.dart';

class LevelSelectionScreen extends StatelessWidget {
  final int totalLevels = 5; // Assuming each module has 5 levels
  final int levelsPerRow = 2;
  final int module;

  LevelSelectionScreen({required this.module, required int userScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level Selection - Module $module'),
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
            int level = index + 1;
            bool isUnlocked = true; //logic missing
            return LevelButton(module, level, isUnlocked);
          },
        ),
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int module;
  final int level;
  final bool isUnlocked;

  LevelButton(this.module, this.level, this.isUnlocked);

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
              MaterialPageRoute(builder: (context) => One()),
            );
          } else if (level == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Two()),
            );
          } else if (level == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Three()),
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

