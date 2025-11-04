import 'package:flutter/material.dart';
import 'package:alzymer/scene/M1/m1LevelSelection.dart';
import 'package:alzymer/scene/M2/m2LevelSelection.dart';
import 'package:alzymer/scene/M3/m3LevelSelection.dart';
import 'package:alzymer/scene/M4/m4LevelSelection.dart';
import 'package:alzymer/scene/M5/m5LevelSelection.dart';

class ModuleSelectionScreen extends StatefulWidget {
  @override
  _ModuleSelectionScreenState createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
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
            children: List.generate(3, (index) => ModuleButton(module: index + 1)),
          ),
        ),
      ),
    );
  }
}

class ModuleButton extends StatelessWidget {
  final int module;
  final List<String> moduleNames = [
    'Module 1',
    'Module 2',
    'Module 3',
    // 'Module 4',
    // 'Module 5',
  ];

  ModuleButton({required this.module});

  void navigateToModule(BuildContext context) {
    final Map<int, Widget Function()> moduleScreens = {
      1: () => M1LevelSelectionScreen(module: module, userScore: 0),
      2: () => M2LevelSelectionScreen(module: module, userScore: 0),
      3: () => M3LevelSelectionScreen(module: module, userScore: 0),
      // 4: () => M4LevelSelectionScreen(module: module, userScore: 0),
      // 5: () => M5LevelSelectionScreen(module: module, userScore: 0),
    };

    if (moduleScreens.containsKey(module)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => moduleScreens[module]!()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => navigateToModule(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Container(
          width: double.infinity,
          height: 100.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: LinearGradient(
              colors: [
                Color(0xFF7F00FF).withOpacity(0.7),
                Color(0xFFE100FF).withOpacity(0.7),
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
                  moduleNames[module - 1],
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

void main() {
  runApp(MaterialApp(
    home: ModuleSelectionScreen(),
  ));
}
