import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sing_karaoke/UI/mainscreen.dart';
import 'package:sing_karaoke/UI/trackingpermission.dart';
import 'package:sing_karaoke/constant.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    isNew = box.read('new') ?? false;
    Future.delayed(const Duration(seconds: 3), () async {
      Get.off(() => isNew == true ? MainScreen() : TrackingPermission());
    });
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/splash.jpg'), fit: BoxFit.fill)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 100.w,
                  width: 100.w,
                )),
            SizedBox(height: 30.h),
            TextWidget(
              text: 'Sing Karaoke',
              fontSize: 24.sp,
            )
          ],
        ),
      ),
    );
  }
}
