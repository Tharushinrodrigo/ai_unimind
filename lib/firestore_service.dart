import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // SAVE USER DATA

  Future<void> saveUserData({
    required String uid,
    required String name,
    required String gender,
    required String age,
    required String village,
    required String country,
    required String residence,
    required String degree,
    required String uniTime,
    required String job,
    required String jobTime,
    required String lifestyle,
  }) async {

    await _firestore
        .collection("users")
        .doc(uid)
        .set({

      "name": name,
      "gender": gender,
      "age": age,
      "village": village,
      "country": country,
      "residence": residence,
      "degree": degree,
      "uniTime": uniTime,
      "job": job,
      "jobTime": jobTime,
      "lifestyle": lifestyle,

      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  // UPDATE SINGLE FIELD

  Future<void> updateField({
    required String uid,
    required String field,
    required dynamic value,
  }) async {

    await _firestore
        .collection("users")
        .doc(uid)
        .update({
      field: value,
    });
  }
}