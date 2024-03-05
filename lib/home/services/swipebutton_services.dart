import 'package:cloud_firestore/cloud_firestore.dart';

class SwipeButtonServices {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> changeStatus(bool isSwitched, uid) async {
    await firestore
        .collection('status')
        .doc(uid)
        .set({'disponivel': isSwitched});
  }

  Future<bool> getStatus(uid) async {
    final DocumentSnapshot doc =
        await firestore.collection('status').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>?;
      return data!['disponivel'];
    } else {
      return false;
    }
  }
}
