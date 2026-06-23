import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize(String uid) async {
    await _messaging.requestPermission();
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'fcmToken': token});
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _saveNotification(uid, message);
    });

    _messaging.onTokenRefresh.listen((newToken) {
      _firestore.collection('users').doc(uid).update({'fcmToken': newToken});
    });
  }

  Future<void> _saveNotification(String uid, RemoteMessage message) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      'title': message.notification?.title ?? 'SpaceNews Update',
      'body': message.notification?.body ?? '',
      'data': message.data,
      'receivedAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<QuerySnapshot> notificationsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('receivedAt', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String uid, String notifId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .update({'isRead': true});
  }

  Future<void> addDemoNotification(String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .add({
      'title': 'Welcome to SpaceNews Core! 🚀',
      'body':
          'Stay updated with the latest space exploration news from around the world.',
      'data': {},
      'receivedAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
