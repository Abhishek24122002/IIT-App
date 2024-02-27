import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'level_selection.dart';
import 'navigation.dart';

class HomePage extends StatelessWidget {
  final User? user;

  const HomePage({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((_) {
                Navigator.pushReplacement(context,
                    Navigation.generateRoute(RouteSettings(name: '/login')));
              }).catchError((error) {
                print("Sign out error: $error");
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String photoURL = userData['photoURL'] ?? '';
          int userScore = userData['score'] ?? 0;
          int level1Attempts = userData['level1Attempts'] ?? 0;

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.blue),
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.transparent,
                      backgroundImage: photoURL.isNotEmpty
                          ? NetworkImage(photoURL)
                          : AssetImage('assets/old_male_icon.jpg')
                              as ImageProvider,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Welcome, ${userData['name'] ?? 'User'}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LevelSelectionScreen(userScore: userScore),
                        ),
                      );
                    },
                    child: Text(
                      "Let's Play",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Attempts',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      // Dynamically create levels and attempts
                      for (int level = 1; level <= userScore; level++)
                        Row(
                          children: [
                            SizedBox(width: 20),
                            Text(
                              'Level $level: ',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${userData['level${level}Attempts'] ?? 0}',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: (userData['level${level}Attempts'] ?? 0) <= 3
                                    ? Colors.amber
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
