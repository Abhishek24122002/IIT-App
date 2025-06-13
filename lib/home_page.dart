import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'module_page.dart';
import 'navigation.dart';

class HomePage extends StatelessWidget {
  final User? user;

  const HomePage({Key? key, this.user}) : super(key: key);

  // Fetch all trophy and point data
  Future<Map<String, dynamic>> fetchAllScores(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final modules = ['M1', 'M2', 'M3', 'M4'];
    int totalTrophies = 0;
int totalPoints = 0;

for (String module in modules) {
  final doc = await firestore
      .collection('users')
      .doc(uid)
      .collection('score')
      .doc(module)
      .get();

  final data = doc.data();
  if (data != null) {
    // Add trophy after ensuring it's casted to int
    final trophy = data['${module}Trophy'];
    if (trophy is num) {
      totalTrophies += trophy.toInt();
    }

    // Sum all MxLxPoint fields safely
    data.forEach((key, value) {
      if (key.startsWith('${module}L') && key.endsWith('Point')) {
        if (value is num) {
          totalPoints += value.toInt();
        }
      }
    });
  }
}


    return {
      'totalTrophies': totalTrophies,
      'totalPoints': totalPoints,
    };
  }

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
                Navigator.pushReplacement(
                  context,
                  Navigation.generateRoute(RouteSettings(name: '/login')),
                );
              }).catchError((error) {
                print("Sign out error: $error");
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }

          var userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          if (userData == null) {
            return Center(child: Text('No user data available'));
          }

          String photoURL = userData['photoURL'] ?? '';
          String username = userData['name'] ?? 'User';
          String capitalizedUsername =
              '${username[0].toUpperCase()}${username.substring(1)}';

          return FutureBuilder<Map<String, dynamic>>(
            future: fetchAllScores(user!.uid),
            builder: (context, scoreSnapshot) {
              if (scoreSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (scoreSnapshot.hasError) {
                return Center(child: Text('Error: ${scoreSnapshot.error}'));
              }

              final scoreData = scoreSnapshot.data!;
              final totalTrophies = scoreData['totalTrophies'];
              final totalPoints = scoreData['totalPoints'];

              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 60),
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
                            'Welcome, $capitalizedUsername',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildCard(Icons.emoji_events,
                                  '$totalTrophies', Colors.amber),
                              SizedBox(width: 20),
                              buildCard(Icons.star, '$totalPoints',
                                  Colors.yellow),
                            ],
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ModuleSelectionScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Let's Play",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Helper card widget
  Widget buildCard(IconData icon, String value, Color color) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 50, color: color),
              SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
