import 'package:medi_minder/entity/medication.dart';

// Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference<Object?>> addUserMedication(String uid, Medication medication) async {
    // Check if the user exists in Firebase Authentication
    User? user = _auth.currentUser;
    if (user != null && user.uid == uid) {
      // Reference to the user's document in the 'users' collection
      DocumentReference userDoc = _firestore.collection('users').doc(uid);

      // Reference to the user's 'medications' sub-collection
      CollectionReference userMedications = userDoc.collection('medications');

      // Add the medication document to Firestore
      return userMedications.add(medication.toMap());
    } else {
      throw Exception('User not found or UID does not match the current user.');
    }
  }

  // Future<List<Medication>> getUserMedications(String uid) async {
  //   User? user = _auth.currentUser;
  //   if (user != null && user.uid == uid) {
  //     QuerySnapshot querySnapshot = await _firestore
  //         .collection('users')
  //         .doc(uid)
  //         .collection('medications')
  //         .get();
  //
  //     List<Medication> medicationList = querySnapshot.docs
  //         .map((doc) => Medication.fromMap(doc.data() as Map<String, dynamic>, uid))
  //         .toList();
  //
  //     return medicationList;
  //   } else {
  //     throw Exception('User not found or UID does not match the current user.');
  //   }
  // }

  Stream<List<Medication>> getUserMedicationsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> removeUserMedication(String uid, String medicationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('medications')
        .doc(medicationId)
        .delete();
  }

  // Future<Medication> getUserMedicationById(String uid, String medicationId) async {
  //   User? user = _auth.currentUser;
  //   if (user != null && user.uid == uid) {
  //     DocumentSnapshot documentSnapshot = await _firestore
  //         .collection('users')
  //         .doc(uid)
  //         .collection('medications')
  //         .doc(medicationId)
  //         .get();
  //
  //     if (documentSnapshot.exists) {
  //       return Medication.fromMap(documentSnapshot.data() as Map<String, dynamic>);
  //     } else {
  //       throw Exception('Medication not found.');
  //     }
  //   } else {
  //     throw Exception('User not found or UID does not match the current user.');
  //   }
  // }
}
