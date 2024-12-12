import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notificationapp/provider/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  User? _user;
  String? _fcmToken;
  List<String> _notifications = [];
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  User? get user => _user;
  String? get fcmToken => _fcmToken;
  List<String> get notifications => _notifications;
  bool _isPasswordVisible = false;

  bool get isPasswordVisible => _isPasswordVisible;

  void toggleVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> initializeMessaging() async {
    _fcmToken = await _firebaseService.getFCMToken();
    _setupFirebaseMessagingListener();
  }

  Future<void> signInWithEmail(String email, String password) async {
    _user = await _firebaseService.signInWithEmailAndPassword(email, password);
    if (_user != null) {
      await initializeMessaging();
      await loadCachedNotifications();
    }
  }

  Future<void> signInWithGoogle() async {
    _user = await _firebaseService.signInWithGoogle();
    if (_user != null) {
      await initializeMessaging();
      await loadCachedNotifications();
    }
  }

  Future<void> _setupFirebaseMessagingListener() async {
    _fcmSubscription?.cancel(); // Mevcut dinleyici varsa iptal et
    _fcmSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        await cacheNotification(
          notification.title ?? "No Title",
          notification.body ?? "No Body",
          data,
        );
        await loadCachedNotifications();
      }
    });
  }

  Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_notifications');
    _notifications = [];
    notifyListeners();
  }

  Future<void> loadCachedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    _notifications = prefs.getStringList('cached_notifications') ?? [];
    notifyListeners();
  }

  Future<void> cacheNotification(
      String title, String body, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList('cached_notifications') ?? [];

    String formattedDate = DateTime.now().toString();
    String formattedNotification = jsonEncode({
      'date': formattedDate,
      'title': title,
      'body': body,
      'data': data,
    });

    notifications.add(formattedNotification);
    await prefs.setStringList('cached_notifications', notifications);
  }

  Future<void> signOut(VoidCallback onSuccess) async {
    await _firebaseService.signOut();
    _user = null;
    _fcmToken = null;
    _notifications = [];

    await _fcmSubscription?.cancel();
    _fcmSubscription = null;

    onSuccess();
    notifyListeners();
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }
}
