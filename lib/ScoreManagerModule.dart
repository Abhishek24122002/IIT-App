import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScoreManager {
  // Singleton instance for managing scores across the app
  static final ScoreManager _instance = ScoreManager._internal();
  factory ScoreManager() => _instance;
  ScoreManager._internal();

  Future<void> initializeScore(String level) async {
    String userUid = getCurrentUserUid();
    if (userUid.isEmpty) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference scoreDocRef = firestore.collection('users').doc(userUid).collection('score').doc('M2');

    // Initialize the score field if it does not exist
    // scoreDocRef.get().then((doc) {
    //   if (!doc.exists) {
    //     scoreDocRef.set({
    //       level: 0,
    //     });
    //   } else if (!doc.data()!.containsKey(level)) {
    //     scoreDocRef.update({
    //       level: 0,
    //     });
    //   }
    // });
  }

  // Generic function to update the score for the specific level
  Future<void> updateUserScore(String level, int score) async {
    try {
      String userUid = getCurrentUserUid();
      if (userUid.isEmpty) return;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference scoreDocRef = firestore.collection('users').doc(userUid).collection('score').doc('M2');

      await scoreDocRef.update({
        level: score,
      });
    } catch (e) {
      print('Error updating score: $e');
    }
  }

  // Fetch current user's UID
  String getCurrentUserUid() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }
}
