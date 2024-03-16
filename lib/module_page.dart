import 'package:alzymer/scene/M2/m2LevelSelection.dart';
import 'package:alzymer/scene/M3/m3LevelSelection.dart';
import 'package:alzymer/scene/M4/m4LevelSelection.dart';
import 'package:alzymer/scene/M5/m5LevelSelection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'level_selection.dart';
import 'scene/M1/m1LevelSelection.dart';

class ModuleSelectionScreen extends StatefulWidget {
  @override
  _ModuleSelectionScreenState createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  late int m1Trophy;

  @override
  void initState() {
    super.initState();
    m1Trophy = 0;
    fetchTrophy();
  }

  void fetchTrophy() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;
    final DocumentReference<Map<String, dynamic>> docRef = FirebaseFirestore
        .instance
        .collection('users')
        .doc(user!.uid)
        .collection('score')
        .doc('M1');

    final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();
    if (snapshot.exists) {
      setState(() {
        m1Trophy = snapshot.data()!['M1Trophy'];
      });
    } else {
      // If document doesn't exist, create one with initial data
      await docRef.set({'M1Trophy': 0});
      setState(() {
        m1Trophy = 0;
      });
    }
  }

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
              (index) {
                if (index == 0) {
                  // For Module1, display M1Trophy value
                  return ModuleButton(
                    module: index + 1,
                    m1Trophy: m1Trophy,
                  );
                } else {
                  return ModuleButton(
                    module: index + 1,
                    // For other modules, set trophy value to 0 or any default value
                    m1Trophy: 0,
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ModuleButton extends StatelessWidget {
  final int module;
  final int m1Trophy;

  ModuleButton({required this.module, required this.m1Trophy});

  List<String> moduleNames = [
    'Module 1',
    'Module 2',
    'Module 3',
    'Module 4',
    'Module 5',
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to respective level selection screens based on module number
        if (module == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => M1LevelSelectionScreen(
                module: module,
                userScore: 0,
              ),
            ),
          );
        } else if (module == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  M2LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else if (module == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  M3LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else if (module == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  M4LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else if (module == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  M5LevelSelectionScreen(module: module, userScore: 0),
            ),
          );
        } else {
          // For other modules, navigate to LevelSelectionScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LevelSelectionScreen(module: module, userScore: 0),
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
              if (module == 1 && m1Trophy == 1) // Only show trophy for Module1
                Positioned(
                  top: 20,
                  right: 5,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/trophy.png',
                        width: 60,
                        height: 60,
                      ),
                      SizedBox(width: 10),
                    ],
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
