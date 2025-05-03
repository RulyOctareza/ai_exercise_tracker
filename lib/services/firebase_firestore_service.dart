import 'package:ai_exercise_tracker/core/constants/firebase_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FirebaseFirestoreService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get collection reference
  CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  // Get document reference
  DocumentReference document(String path) {
    return _firestore.doc(path);
  }

  // Get user document reference
  DocumentReference userDocument(String userId) {
    return _firestore.collection(FirebaseConstants.usersCollection).doc(userId);
  }

  // Get a document by ID
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Add a document to a collection
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await _firestore.collection(collection).add(data);
  }

  // Set a document with ID
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    return await _firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  // Update a document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    return await _firestore.collection(collection).doc(docId).update(data);
  }

  // Delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).delete();
  }

  // Get documents from a collection with query
  Future<QuerySnapshot> getDocuments(
    String collection, {
    List<List<dynamic>>? whereConditions,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query query = _firestore.collection(collection);

    // Apply where conditions if provided
    if (whereConditions != null) {
      for (var condition in whereConditions) {
        if (condition.length == 3) {
          query = query.where(
            condition[0],
            isEqualTo: condition[1] == '==' ? condition[2] : null,
          );
          query = query.where(
            condition[0],
            isGreaterThan: condition[1] == '>' ? condition[2] : null,
          );
          query = query.where(
            condition[0],
            isLessThan: condition[1] == '<' ? condition[2] : null,
          );
          // Add more conditions as needed
        }
      }
    }

    // Apply order by if provided
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit if provided
    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }
}
