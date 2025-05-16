import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';

class FirestoreExtendedService extends FirestoreService {
  // Residents collection
  final CollectionReference residents =
      FirebaseFirestore.instance.collection('residents');

  Future<void> addResident(Map<String, dynamic> residentData) {
    return residents.add({
      ...residentData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getResidents() {
    return residents.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateResident(String docId, Map<String, dynamic> residentData) {
    return residents.doc(docId).update(residentData);
  }

  Future<void> deleteResident(String docId) {
    return residents.doc(docId).delete();
  }

  // Payments collection (financial_transactions)
  final CollectionReference payments =
      FirebaseFirestore.instance.collection('financial_transactions');

  Future<void> _updatePaymentsSummary() async {
    QuerySnapshot snapshot = await payments.get();
    double totalReceived = 0;
    double pendingPayments = 0;

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double amount = (data['amount'] ?? 0).toDouble();
      String status = (data['status'] ?? '').toString().toLowerCase();
      if (status == 'received' || amount > 0) {
        totalReceived += amount;
      } else if (status == 'pending' || amount < 0) {
        pendingPayments += amount.abs();
      }
    }

    await payments.doc('summary').set({
      'totalReceived': totalReceived,
      'pendingPayments': pendingPayments,
    });
  }

  Future<void> addPayment(Map<String, dynamic> paymentData) async {
    await payments.add({
      ...paymentData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _updatePaymentsSummary();
  }

  Stream<QuerySnapshot> getPayments() {
    return payments.orderBy('date', descending: true).snapshots();
  }

  Future<void> updatePayment(String docId, Map<String, dynamic> paymentData) async {
    await payments.doc(docId).update(paymentData);
    await _updatePaymentsSummary();
  }

  Future<void> deletePayment(String docId) async {
    await payments.doc(docId).delete();
    await _updatePaymentsSummary();
  }

  // Complaints collection
  final CollectionReference complaints =
      FirebaseFirestore.instance.collection('complaints');

  Future<void> addComplaint(Map<String, dynamic> complaintData) {
    return complaints.add({
      ...complaintData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getComplaints() {
    // Firestore does not support nullsLast parameter, so remove ordering to include all complaints
    return complaints.snapshots();
  }

  Future<void> updateComplaint(String docId, Map<String, dynamic> complaintData) {
    return complaints.doc(docId).update(complaintData);
  }

  Future<void> deleteComplaint(String docId) {
    return complaints.doc(docId).delete();
  }

  // Announcements collection
  final CollectionReference announcements =
      FirebaseFirestore.instance.collection('Announcements');

  Future<void> addAnnouncement(Map<String, dynamic> announcementData) {
    return announcements.add({
      ...announcementData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAnnouncements() {
    return announcements.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> updateAnnouncement(String docId, Map<String, dynamic> announcementData) {
    return announcements.doc(docId).update(announcementData);
  }

  Future<void> deleteAnnouncement(String docId) {
    return announcements.doc(docId).delete();
  }
}
