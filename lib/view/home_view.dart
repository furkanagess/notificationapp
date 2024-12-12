import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:notificationapp/provider/home_view_model.dart';
import 'package:notificationapp/view/notification/notifications_view.dart';
import 'package:notificationapp/view/notification/notification_detail_view.dart';
import 'package:notificationapp/view/login/signin_view.dart';
import 'package:provider/provider.dart';
import 'login/signup_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF191C24),
          body: viewModel.user != null
              ? NotificationsView(viewModel: viewModel)
              : SigninView(viewModel: viewModel),
        );
      },
    );
  }
}

Widget _authUI(HomeViewModel viewModel, BuildContext context) {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/akademi_logo.png"),
          const SizedBox(height: 50),
          TextField(
            controller: emailController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "E-posta",
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: const OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Şifre",
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => viewModel.signInWithEmail(
                      emailController.text, passwordController.text),
                  child: const Text("Giriş Yap"),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.withOpacity(0.4),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpView()),
                  );
                },
                child: const Text(
                  "Kayıt Ol",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1.0),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.withOpacity(0.4),
            ),
            onPressed: viewModel.signInWithGoogle,
            label: const Text(
              "Google ile Giriş Yap",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: const FaIcon(
              FontAwesomeIcons.google,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _userInfo(HomeViewModel viewModel, BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Anasayfa"),
      centerTitle: true,
      backgroundColor: const Color(0xFF191C24),
    ),
    backgroundColor: const Color(0xFF191C24),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(viewModel.user?.email ?? "Unknown",
                style: const TextStyle(color: Colors.white, fontSize: 20)),
          ),
          const Divider(color: Colors.white),
          const SizedBox(
            height: 10,
          ),
          if (viewModel.fcmToken != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          viewModel.fcmToken!,
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.purple),
                        onPressed: () {
                          _copyToClipboard(context, viewModel.fcmToken!);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 10,
          ),
          const Divider(color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Gelen Bildirimler",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              if (viewModel.notifications.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red.withOpacity(0.4)),
                  onPressed: () => _showConfirmationDialog(context, viewModel),
                ),
            ],
          ),
          Expanded(
            child: viewModel.notifications.isEmpty
                ? const Center(
                    child: Text("Henüz bildirim yok",
                        style: TextStyle(color: Colors.white)))
                : ListView.builder(
                    itemCount: viewModel.notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                          context, viewModel.notifications[index]);
                    },
                  ),
          ),
          // Row(
          //   children: [
          //     Expanded(
          //       child: ElevatedButton(
          //         onPressed: viewModel.signOut2,
          //         style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.red.withOpacity(0.4)),
          //         child: const Text("Çıkış Yap",
          //             style: TextStyle(color: Colors.white)),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    ),
  );
}

void _copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("FCM Token kopyalandı!")),
  );
}

void _showConfirmationDialog(BuildContext context, HomeViewModel viewModel) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFF191C24),
        title: const Text(
          "Bildirimleri Temizle",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Tüm bildirimleri silmek istediğinize emin misiniz?",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dialogu kapat
            },
            child: Text(
              "İptal",
              style: TextStyle(color: Colors.red.withOpacity(0.4)),
            ),
          ),
          TextButton(
            onPressed: () {
              viewModel.clearNotifications();
              Navigator.of(context).pop(); // Dialogu kapat
            },
            child: const Text(
              "Tamam",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildNotificationCard(BuildContext context, String notification) {
  try {
    // JSON verisini parse et
    final Map<String, dynamic> notificationData = jsonDecode(notification);
    final String title = notificationData['title'] ?? "No Title";
    final String body = notificationData['body'] ?? "No Body";
    final String date = notificationData['date'] ?? "No Date";
    final Map<String, dynamic> data = notificationData['data'] ?? {};

    // Tarihi formatla
    String formattedDate =
        DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(date));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotificationDetailPage(notification: notification),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve tarih aynı satırda
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bildirim içeriği
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              // JSON verisi varsa göster
              if (data.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  "Ek Veriler:",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  data.toString(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  } catch (e) {
    final parts = notification.split(' - ');
    final date = parts.isNotEmpty ? parts[0] : "";

    final String title =
        parts.length > 1 ? parts[1].split(':')[0] : "Başlık Bulunamadı";
    final String body =
        parts.length > 1 ? parts[1].split(':')[1] : "İçerik Bulunamadı";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotificationDetailPage(notification: notification),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.grey[800]!),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
