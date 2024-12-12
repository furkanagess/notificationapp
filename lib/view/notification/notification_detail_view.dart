import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:notificationapp/constants/app_colors.dart';
import 'package:notificationapp/constants/app_strings.dart';

class NotificationDetailPage extends StatelessWidget {
  final String notification;

  const NotificationDetailPage({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> notificationData;
    String title = AppStrings.noTitle;
    String body = AppStrings.noBody;
    String date = AppStrings.noDate;
    Map<String, dynamic> data = {};

    try {
      notificationData = jsonDecode(notification);
      title = notificationData['title'] ?? AppStrings.noTitle;
      body = notificationData['body'] ?? AppStrings.noBody;
      date = notificationData['date'] ?? AppStrings.noDate;
      data = notificationData['data'] ?? {};
      if (date.isNotEmpty) {
        DateTime parsedDate = DateTime.parse(date);
        date = DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
      }
    } catch (e) {
      final parts = notification.split(' - ');
      date = parts.isNotEmpty ? parts[0] : "";

      title = parts.length > 1 ? parts[1].split(':')[0] : AppStrings.noTitle;
      body = parts.length > 1 ? parts[1].split(':')[1] : AppStrings.noBody;
      if (date.isNotEmpty) {
        try {
          DateTime parsedDate = DateTime.parse(date);
          date = DateFormat('dd/MM/yyyy - HH:mm').format(parsedDate);
        } catch (e) {}
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notificationDetail),
        centerTitle: true,
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (date.isNotEmpty)
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 20),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // İçerik
            Text(
              body,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                AppStrings.dataTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: data.entries.length,
                  itemBuilder: (context, index) {
                    final entry = data.entries.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.white.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Key kısmı
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "${entry.key}:",
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
