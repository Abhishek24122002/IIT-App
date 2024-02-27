// ScoreManager.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreManager {
  static Future<void> updateUserScore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      // Check if the document exists
      if (userData.exists) {
        // Check if the 'score' field exists
        if (!userData.data()!.containsKey('score')) {
          // If 'score' field doesn't exist, initialize it with 1
          await userDoc.set({'score': 1}, SetOptions(merge: true));
        } else {
          int currentScore = userData['score'] ?? 0;
          // Update the score only if it's 0
          if (currentScore == 0) {
            await userDoc.update({'score': currentScore + 1});
          }
        }
      }
    }
  }
}
