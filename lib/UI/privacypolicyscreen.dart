import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: InkWell(
            onTap: () {
              Get.back();
            },
            child: SvgPicture.asset(
              'assets/icons/back.svg',
              width: 25.w,
              height: 25.w,
            ),
          ),
        ),
        leadingWidth: 35.w,
        automaticallyImplyLeading: false,
        title: TextWidget(text: 'Privacy Policy', fontFamily: 'M', fontSize: 18.sp),
        centerTitle: true,
      ),
      body: WebViewWidget(
        controller: wc,
      ),
    );
  }
}
