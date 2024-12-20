import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notificationapp/base/constants/app_strings.dart';
import 'package:notificationapp/provider/firebase_messaging_background_handler.dart';
import 'package:notificationapp/provider/home_view_model.dart';
import 'package:notificationapp/view/home_view.dart';
import 'package:provider/provider.dart';
import 'package:notificationapp/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    return true;
  };
  runApp(
    ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<ScaffoldMessengerState> scaffoldMassgengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: ThemeData.dark(),
      home: const HomeView(),
    );
  }
}
