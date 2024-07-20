// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_id/flutter_device_id.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sing_karaoke/Notification/local_notification_services.dart';
import 'package:sing_karaoke/UI/splashscreen.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:sing_karaoke/firebase_options.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// automatically get breadcrumb logs to understand user actions leading up to a crash, non-fatal, or ANR event
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  /// This data can help you understand basic interactions, such as how many times your app was opened, and how many users were active in a chosen time period.
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

  /// INITIALIZE LOCAL NOTIFICATION FOR [IOS]
  await NotificationService.init();
  await NotificationService.cancelAllNotifications();

  if (Platform.isAndroid) {
    await getDeviceInfo();
  }
  await GetStorage.init();

  /// Musics
  List saved = box.read('Musics') ?? [];
  for (var element in saved) {
    allMusics.add(Music.fromMap(element));
  }

  /// Videos
  List videos = box.read('Videos') ?? [];
  for (var element in videos) {
    allVideos.add(Video.fromMap(element));
  }

  if (Platform.isAndroid) {
    await allPermissionAndroid();
  }

  wc = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://vocsyapp.com/SingKaraoke/privacyPolicy.php'));

  /// Ads Initialize
  final flutterDeviceIdPlugin = FlutterDeviceId();
  String? deviceId = await flutterDeviceIdPlugin.getDeviceId() ?? '';
  print("DEVICE ID ::: $deviceId");
  EasyAds.instance.initialize(
    isShowAppOpenOnAppStateChange: false,
    adIdManager,
    adMobAdRequest: const AdRequest(),
    admobConfiguration: RequestConfiguration(testDeviceIds: [deviceId]),
    fbTestMode: true,
    showAdBadge: Platform.isIOS,
    fbiOSAdvertiserTrackingEnabled: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: isTab(context) ? const Size(585, 812) : Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            title: 'Sing Karaoke',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              splashColor: Colors.transparent,
              useMaterial3: false,
              bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: blue),
              highlightColor: Colors.transparent,
              appBarTheme: AppBarTheme(color: blue, elevation: 0),
              scaffoldBackgroundColor: blue,
            ),
            home: const SplashScreen(),
          );
        });
  }
}
