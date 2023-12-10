import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String username;
  final String email;
  final String age;
  final String weight;
  final String height;

  Profile({required this.username, required this.email, required this.age, required this.weight, required this.height});

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? '',
      weight: map['weight'] ?? '',
      height: map['height'] ?? '',
    );
  }

  factory Profile.fromSnapshot(DocumentSnapshot snapshot) {
    return Profile.fromMap(snapshot.data() as Map<String, dynamic>);
  }
}

Stream<Profile?> getUserProfileStream() {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) => Profile.fromSnapshot(snapshot));
  } else {
    return Stream.value(null);
  }
}