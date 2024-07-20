import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sing_karaoke/UI/myrecordingscreen.dart';
import 'package:sing_karaoke/UI/privacypolicyscreen.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width / 1.4,
      elevation: 0,
      backgroundColor: blue,
      child: Column(
        children: [
          SizedBox(height: 35.h),
          TextWidget(text: 'Sing\nKaraoke', fontFamily: 'B', maxLines: 2, textAlign: TextAlign.center, fontSize: 30.sp),
          SizedBox(height: 30.h),
          const Divider(color: Colors.grey),
          ListTile(
              leading: SvgPicture.asset('assets/icons/music.svg'),
              title: const TextWidget(text: 'My Recordings'),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () {
                Get.to(() => MyRecordingScreen());
              }),
          ListTile(
              leading: SvgPicture.asset('assets/icons/privacy.svg', color: white),
              title: const TextWidget(text: 'Privacy Policy'),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () {
                Get.to(() => const PrivacyPolicyScreen());
              }),
          ListTile(
              leading: SvgPicture.asset('assets/icons/star.svg', color: white),
              title: const TextWidget(text: 'Rate App'),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () async {
                await launchUrl(Uri.parse(appReview));
              }),
          ListTile(
              leading: SvgPicture.asset('assets/icons/share.svg', color: white),
              title: const TextWidget(text: 'Share App'),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              onTap: () async {
                if (isTab(context)) {
                  await Share.share("Sing Karaoke \n$appShare",
                      sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height / 2));
                } else {
                  await Share.share("Sing karaoke \n$appShare");
                }
              }),
        ],
      ),
    );
  }
}
