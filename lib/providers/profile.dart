import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateProfile(String field, String value) async {
  User? user = FirebaseAuth.instance.currentUser;
  String uid = user?.uid ?? '';

  if (uid.isNotEmpty) {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        field: value,
      });
    } catch (e) {
      print('Error updating profile: $e');
    }
  }
}
