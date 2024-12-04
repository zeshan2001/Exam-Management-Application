import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getmaxAttempt(String docId) async {
    // Reference the Firestore document
    final docRef = _db.collection('exams').doc(docId);
    return docRef.get().then((snapshots) {
      return snapshots.data()?['maxAttempts'] ?? 0;
    });

    // int numAttempt = 0;

    // try {
    //   // Fetch the document
    //   final snapshot = await docRef.get();

    //   if (snapshot.exists) {
    //     // Access the field 'numattempt'
    //     numAttempt = snapshot.data()?['maxAttempts'] ?? 0;
    //     // return snapshot.data()?['maxAttempts'] ?? 0;
    //     //print("Number of Attempts: $numAttempt");
    //   } else {
    //     print("Document does not exist!");
    //   }
    // } catch (e) {
    //   print("Error fetching document: $e");
    // }
    // return numAttempt;
  }

  Future<void> updatemaxAttempt(String docId, int maxattempts) async {
    // Reference the Firestore document
    final docRef = _db.collection('exams').doc(docId);
    docRef.update(
      {'maxAttempts': maxattempts},
    );
  }

  Future<void> appendMultipleToArray(
      String docId, List<Map<String, dynamic>> newItems) async {
    try {
      // Get the existing document
      final docSnapshot = await _db.collection('exams').doc(docId).get();

      if (docSnapshot.exists) {
        // Retrieve the current array or initialize it as empty
        List<dynamic> currentArray = docSnapshot.data()?['userAnswers'] ?? [];

        // Add all new items to the array
        currentArray.addAll(newItems);

        // Write the updated array back to Firestore
        await _db.collection('exams').doc(docId).update(
          {'userAnswers': currentArray},
        );
      } else {
        print("Document does not exist!");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

// Delete data
  Future<void> deleteuseranswers(String id) async {
    await _db.collection('exams').doc(id).update(
      {'userAnswers': FieldValue.delete()},
    );
  }

  // Get data stream
  Stream<List<Map<String, dynamic>>> getData() {
    return _db.collection('exams').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }
}
