import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notificationapp/constants/app_colors.dart';
import 'package:notificationapp/constants/app_strings.dart';
import 'package:notificationapp/provider/home_view_model.dart';
import 'package:notificationapp/view/home_view.dart';
import 'package:notificationapp/view/widgets/custom_snackbar.dart';

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
        title: const Text(AppStrings.settings),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Text(widget.viewModel.user?.email ?? AppStrings.noMail,
                  style: const TextStyle(color: AppColors.white, fontSize: 20)),
            ),
            const Divider(
              color: AppColors.white,
            ),
            const SizedBox(
              height: 20,
            ),
            if (widget.viewModel.fcmToken != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppStrings.fcmTokenLabel,
                    style: TextStyle(
                        color: AppColors.white,
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
                    child: const Text(AppStrings.signOut,
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
    CustomSnackbar.show(
        context: context,
        label: AppStrings.fcmTokenCopied,
        backgroundColor: AppColors.primary);
  }
}
