// module_selection.dart
import 'package:flutter/material.dart';

import 'level_selection.dart';

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
      'Temporal Understanding',
      'Memory',
      'Problem-Solving',
      'Perception',
      'Module 5',
      
    ];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LevelSelectionScreen(module: module, userScore: 0,),
          ),
        );
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
