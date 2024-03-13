import 'package:flutter/material.dart';
import 'level_selection.dart';
import 'scene/M1/m1LevelSelection.dart';
import 'scene/M2/m2LevelSelection.dart'; 
import 'scene/M3/m3LevelSelection.dart'; 
import 'scene/M4/m4LevelSelection.dart'; 
import 'scene/M5/m5LevelSelection.dart'; 

class ModuleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module Selection'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5, // Number of modules
              (index) => ModuleButton(index + 1),
            ),
          ),
        ),
      ),
    );
  }
}

class ModuleButton extends StatelessWidget {
  final int module;

  ModuleButton(this.module);

  @override
  Widget build(BuildContext context) {
    // Custom names for the modules
    List<String> moduleNames = [
      'Module1',
      'Module2',
      'Module3',
      'Module4',
      'Module5',
    ];

    return InkWell(
      onTap: () {
        // Navigate to respective level selection screens based on module number
        if (module == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => M1LevelSelectionScreen(module: module,),
            ),
          );
        } else if (module == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => M2LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else if (module == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => M3LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else if (module == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => M4LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else if (module == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => M5LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else {
          // For other modules, navigate to LevelSelectionScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Container(
          width: double.infinity,
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: LinearGradient(
              colors: [
                Color(0xFF7F00FF).withOpacity(0.7), // Semi-transparent purple
                Color(0xFFE100FF).withOpacity(0.7), // Semi-transparent purple
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  moduleNames[module - 1], // Adjusted to use custom names
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
