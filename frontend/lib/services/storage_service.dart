import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docuverse/models/document_model.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadFile(String path, String fileName) async {
    try {
      final ref = _storage.ref().child(path).child(fileName);
      final uploadTask = ref.putFile(File(fileName));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveDocumentMetadata(Document document, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(document.id)
          .set(document.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Document>> getUserDocuments(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .get();

      return snapshot.docs
          .map((doc) => Document.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDocument(String userId, String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}