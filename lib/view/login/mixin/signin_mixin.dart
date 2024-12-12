import 'package:flutter/material.dart';
import 'package:notificationapp/provider/firebase_service.dart';
import 'package:notificationapp/view/home_view.dart';
import 'package:notificationapp/view/widgets/custom_snackbar.dart';

mixin SigninMixin<T extends StatefulWidget> on State<T> {
  final FirebaseService _firebaseService = FirebaseService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? fcmToken;

  Future<void> handleSignIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomSnackbar.show(
          context: context,
          label: "E-posta ve şifre alanları boş bırakılamaz.");

      return;
    }

    final user =
        await _firebaseService.signInWithEmailAndPassword(email, password);
    if (user != null) {
      final token = await _firebaseService.getFCMToken();
      setState(() {
        fcmToken = token;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
    } else {
      CustomSnackbar.show(
          context: context,
          label:
              "Şifre en az 6 karakter olmalı ve yalnızca geçerli mail formatında olmalıdır.");
    }
  }
}
