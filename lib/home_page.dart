import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'level_selection.dart';
import 'login_page.dart'; // Import your LoginPage component

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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Redirect to LoginPage
                );
              }).catchError((error) {
                print("Sign out error: $error");
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          String photoURL = userData['photoURL'] ?? ''; // Handle null case
          return Center(
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
                    backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : AssetImage('assets/default_image.jpg') as ImageProvider,
 // Provide a default avatar image
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome, ${userData['name'] ?? 'User'}', // Handle null case
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle Let's Play button press
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LevelSelectionScreen(),
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
          );
        },
      ),
    );
  }
}
