import 'package:alzymer/scene/M2/M2L1.dart';
import 'package:alzymer/scene/M2/M2L2.dart';
import 'package:alzymer/scene/M2/M2L3.dart';
import 'package:alzymer/scene/M2/M2L4.dart';
import 'package:alzymer/scene/M2/m2L5.dart';
import 'package:flutter/material.dart';



class M2LevelSelectionScreen extends StatelessWidget {
  final int totalLevels = 5; // Assuming each module has 5 levels
  final int levelsPerRow = 2;
  final int module;

  M2LevelSelectionScreen({required this.module, required int userScore});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Selection - Module $module'),
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
         
          if (level == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => M2L1()),
            );
          } else if (level == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => M2L2()),
            );
          } else if (level == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => M2L3()),
            );
          }else if (level == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => M2L4()),
            );
          }
          else if (level == 5) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => M2L5()),
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

