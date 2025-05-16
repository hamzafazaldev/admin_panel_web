import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // Create
  Future<void> addUser(String name, String email) {
    return users.add({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Read (Stream)
  Stream<QuerySnapshot> getUsers() {
    return users.orderBy('createdAt', descending: true).snapshots();
  }

  // Update
  Future<void> updateUser(String docId, String newName) {
    return users.doc(docId).update({'name': newName});
  }

  // Delete
  Future<void> deleteUser(String docId) {
    return users.doc(docId).delete();
  }
}
