import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sing_karaoke/constant.dart';

class MicrophonePermission extends StatelessWidget {
  const MicrophonePermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        color: blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset("assets/images/microphone_permission.png", height: 222.w, width: 222.w, color: white),
            SizedBox(height: 50.h),
            TextWidget(
              text: "Microphone permission needed",
              fontFamily: 'B',
              maxLines: 2,
              textAlign: TextAlign.center,
              fontSize: 20.sp,
            ),
            SizedBox(height: 40.h),
            TextWidget(
              text:
                  "This app needs access to your microphone, which is required to record the audio. If you don't feel comfortable with this permission, you can go to Settings > Permissions and modify it at any time.",
              fontFamily: 'M',
              textAlign: TextAlign.center,
              maxLines: 5,
            ),
            Spacer(),
            InkWell(
              onTap: () async {
                isNew = true;
                box.write('new', isNew);
                await allPermissionIOS( type: PerType.Microphone, isVisit: true);
              },
              child: Container(
                height: 56.w,
                width: MediaQuery.sizeOf(context).width,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r), color: pink),
                child: TextWidget(
                  text: "Continue",
                  fontFamily: 'M',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
