import 'package:alzymer/scene/M1/m1L1.dart';
import 'package:alzymer/scene/M1/m1L2.dart';
import 'package:alzymer/scene/M1/m1L3.dart';
import 'package:alzymer/scene/M1/m1L4.dart';
import 'package:alzymer/scene/M1/m1L5.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class M1LevelSelectionScreen extends StatelessWidget {
  final int totalLevels = 5;
  final int levelsPerRow = 2;
  final int module;
  int m1Trophy = 0;
  late Stream<DocumentSnapshot> userDataStream;

  M1LevelSelectionScreen({required this.module, required int userScore}) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? user = _auth.currentUser;

    userDataStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        // .collection('attempt') //to access attempt collection only 1 is working now need to access both in future
        .collection('score')
        .doc('M1')
        .snapshots();
  }
  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  void updateFirebaseData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      String userUid = getCurrentUserUid();

      if (userUid.isNotEmpty) {
        // Reference to the user's document
        DocumentReference userDocRef =
            firestore.collection('users').doc(userUid);

        // Reference to the 'score' document with document ID 'M1'
        DocumentReference M1TrophyDocRef =
            userDocRef.collection('score').doc('M1');

        // Update the fields in the 'score' document

        await M1TrophyDocRef.update({
          'M1Trophy': m1Trophy,
          'userAnswer': [],
        });
      }
    } catch (e) {
      print('Error updating data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Selection - Module $module'),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: userDataStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text('Document does not exist');
            }
            final data = snapshot.data!.data() as Map<String, dynamic>?;

            int M1L1Point = data?['M1L1Point'] ?? 0;
            int M1L2Point = data?['M1L2Point'] ?? 0;
            int M1L3Point = data?['M1L3Point'] ?? 0;
            int M1L4Point = data?['M1L4Point'] ?? 0;
            int M1L5Point = data?['M1L5Point'] ?? 0;

            // int M1L1Attempts = data?['M1L1Attempts'] ?? 0;
            // int M1L2Attempts = data?['M1L2Attempts'] ?? 0;

            int TotalPoints =
                M1L1Point + M1L2Point + M1L3Point + M1L4Point + M1L5Point;
            if (TotalPoints == 5) {
              m1Trophy = 1;
              updateFirebaseData();
            }
            return Stack(
              alignment: Alignment.topLeft,
              children: [
                GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: levelsPerRow,
                    mainAxisSpacing: 16.0,
                    crossAxisSpacing: 16.0,
                  ),
                  itemCount: totalLevels,
                  itemBuilder: (context, index) {
                    int level = index + 1;
                    bool isUnlocked = isLevelUnlocked(level,
                        TotalPoints); // totalPoints is assumed to be accessible here
                    return LevelButton(module, level, isUnlocked);
                  },
                ),
                Positioned(
                  top: 5,
                  right: 16,
                  child: Row(
                    children: [
                      Text(
                        '$TotalPoints',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 10),
                      Image.asset(
                        'assets/star.png',
                        width: 40,
                        height: 40,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                // Positioned(
                //   top: 5,
                //   left: 16,
                //   child: Row(
                //     children: [
                //       Text(
                //         'Attempts: $M1L1Attempts',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.green,
                //         ),
                //       ),
                //       SizedBox(width: 10),
                //     ],
                //   ),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}

bool isLevelUnlocked(int level, totalPoints) {
  // Level 1 is always unlocked
  if (level == 1) {
    return true;
  }
  // For levels greater than 1, check if the total points meet the unlocking condition
  else {
    return totalPoints >= level - 1;
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
          switch (level) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => M1L1()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => M1L2()),
              );
              break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => M1L3()),
              );
              break;
            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => M1L4()),
              );
              break;
            case 5:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => M1L5()),
              );
              break;
            default:
              break;
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

void main() {
  runApp(MaterialApp(
    home: M1LevelSelectionScreen(
      module: 1,
      userScore: 0,
    ),
  ));
}
