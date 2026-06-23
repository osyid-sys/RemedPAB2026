import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/article.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _favRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  Stream<QuerySnapshot> favoritesStream(String uid) {
    return _favRef(uid).orderBy('savedAt', descending: true).snapshots();
  }

  Future<bool> isFavorite(String uid, int articleId) async {
    final doc = await _favRef(uid).doc(articleId.toString()).get();
    return doc.exists;
  }

  Future<void> addFavorite(String uid, Article article) async {
    await _favRef(uid).doc(article.id.toString()).set({
      ...article.toMap(),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String uid, int articleId) async {
    await _favRef(uid).doc(articleId.toString()).delete();
  }
}
