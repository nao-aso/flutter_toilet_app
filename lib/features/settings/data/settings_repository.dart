import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/settings_model.dart';
import 'package:flutter/foundation.dart';

class SettingsRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 匿名ログイン
  Future<User?> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      debugPrint('匿名ログインエラー: $e');
      return null;
    }
  }

  User? get currentUser => _auth.currentUser;

  /// Firestoreに設定を保存
  Future<void> saveSettings(SettingsModel settings) async {
    if (currentUser == null) return;
    final uid = currentUser!.uid;

    await _firestore.collection('users').doc(uid)
        .set(settings.toMap(), SetOptions(merge: true));
  }

  /// Firestoreから設定を取得
  Future<SettingsModel?> loadSettings() async {
    if (currentUser == null) return null;
    final uid = currentUser!.uid;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    return SettingsModel.fromMap(doc.data()!);
  }
}
