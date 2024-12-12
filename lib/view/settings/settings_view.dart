import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notificationapp/constants/app_colors.dart';
import 'package:notificationapp/provider/home_view_model.dart';
import 'package:notificationapp/view/home_view.dart';
import 'package:notificationapp/view/login/signin_view.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  final HomeViewModel viewModel;
  const SettingsView({super.key, required this.viewModel});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("Ayarlar"),
        centerTitle: true,
        backgroundColor: const Color(0xFF191C24),
      ),
      backgroundColor: const Color(0xFF191C24),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(widget.viewModel.user?.email ?? "Unknown",
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
            const Divider(
              color: Colors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            if (widget.viewModel.fcmToken != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "FCM Token",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      color: AppColors.softGrey,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.viewModel.fcmToken!,
                            style: const TextStyle(
                              color: AppColors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            _copyToClipboard(
                                context, widget.viewModel.fcmToken!);
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
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.viewModel.signOut(
                      () => Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const HomeView();
                      })),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softRed,
                    ),
                    child: const Text("Çıkış Yap",
                        style: TextStyle(color: AppColors.background)),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
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
}
