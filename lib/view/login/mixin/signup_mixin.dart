import 'package:flutter/material.dart';

import 'package:notificationapp/provider/firebase_service.dart';
import 'package:notificationapp/view/home_view.dart';
import 'package:notificationapp/view/widgets/custom_snackbar.dart';

mixin SignUpMixin<T extends StatefulWidget> on State<T> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? fcmToken;

  Future<void> handleSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      CustomSnackbar.show(
          context: context,
          label: "E-posta ve şifre alanları boş bırakılamaz.");
      return;
    }

    if (password != confirmPassword) {
      CustomSnackbar.show(
          context: context,
          label: "Şifreler eşleşmiyor. Lütfen şifreleri kontrol edin.");
      return;
    }

    final user =
        await _firebaseService.signUpWithEmailAndPassword(email, password);
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
