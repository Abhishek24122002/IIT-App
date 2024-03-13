import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class M2L4 extends StatefulWidget {
  @override
  _M2L4State createState() => _M2L4State();
}

class _M2L4State extends State<M2L4> {
  int m1l4Point = 0;
  int m1l4Attempts = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Access Firestore instance
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Fetch user document
        DocumentSnapshot<Map<String, dynamic>> userDocSnapshot =
            await firestore.collection('users').doc(user.uid).get();

        // Fetch 'score' document within the user document
        DocumentSnapshot<Map<String, dynamic>> scoreDocSnapshot =
            await userDocSnapshot.reference.collection('score').doc('M1').get();

        // Fetch 'attempt' document within the user document
        DocumentSnapshot<Map<String, dynamic>> attemptDocSnapshot =
            await userDocSnapshot.reference.collection('attempt').doc('M1').get();

        // Access 'M1L4Point' field from 'score' document
        m1l4Point = scoreDocSnapshot.get('M1L4Point');

        // Access 'M1L4Attempts' field from 'attempt' document
        m1l4Attempts = attemptDocSnapshot.get('M1L4Attempts');

        // Update the UI with fetched values
        setState(() {});
      } else {
        print('User not signed in.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Module 1 Level 4'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'M1L4 Point: $m1l4Point',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Text(
              'M1L4 Attempts: $m1l4Attempts',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Cleanup code here
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: M2L4(),
  ));
}
