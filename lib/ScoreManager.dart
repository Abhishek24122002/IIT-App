import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreManager {
  static Future<void> updateUserScore(int level) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userData = await userDoc.get();

      // Check if the document exists
      if (userData.exists) {
        // Check if the 'score' field exists
        if (!userData.data()!.containsKey('score')) {
          // If 'score' field doesn't exist, initialize it with 1
          await userDoc.set({'score': 1, 'currentLevel': level}, SetOptions(merge: true));
        } else {
          int currentScore = userData['score'] ?? 0;

          // Check if the 'currentLevel' field exists
          if (userData.data()!.containsKey('currentLevel')) {
            int storedLevel = userData['currentLevel'] ?? 0;

            // Update the score only if the current level is greater than the stored level
            if (level > storedLevel) {
              await userDoc.update({'score': currentScore + 1, 'currentLevel': level});
            }
          } else {
            // If 'currentLevel' field doesn't exist, update it with the current level
            await userDoc.update({'score': currentScore + 1, 'currentLevel': level});
          }
        }
      }
    }
  }

  
}
