import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sing_karaoke/Controller/maincontroller.dart';
import 'package:sing_karaoke/UI/homescreen.dart';
import 'package:sing_karaoke/UI/myrecordingscreen.dart';
import 'package:sing_karaoke/constant.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final MainController mc = Get.put(MainController());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
              actionsPadding: EdgeInsets.only(right: 15.w, bottom: 10.h),
              title: TextWidget(
                text: 'Are you sure?',
                fontSize: 20.sp,
                fontFamily: 'M',
                color: black,
              ),
              content: TextWidget(
                text: 'Are you sure you want to leave this app?',
                fontSize: 15.sp,
                maxLines: 2,
                fontFamily: 'M',
                color: black,
              ),
              actions: <Widget>[
                TextButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(BorderSide(width: 1.w, color: pink)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)))),
                  child: TextWidget(
                    text: 'No',
                    fontSize: 15.sp,
                    fontFamily: 'M',
                    color: pink,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                      side: MaterialStateProperty.all(BorderSide(width: 1.w, color: pink)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)))),
                  child: TextWidget(
                    text: 'Yes',
                    fontSize: 15.sp,
                    fontFamily: 'M',
                    color: pink,
                  ),
                  onPressed: () {
                    exit(0);
                  },
                ),
              ],
            );
          },
        );
      },
      child: Scaffold(
        body: Obx(() {
          isLoading.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/main.jpg'), fit: BoxFit.fill)),
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: 'Sing Karaoke',
                        fontSize: 30.sp,
                      ),
                      SizedBox(height: 70.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              if (Platform.isAndroid) {
                                if (allVideos.isEmpty) {
                                  isLoading.value = true;
                                  await getVideoFromStorageAndroid().then((value) => Get.to(() => HomeScreen()));
                                } else {
                                  Get.to(() => HomeScreen());
                                }
                              } else {
                                Get.to(() => HomeScreen());
                              }
                            },
                            child: Container(
                              height: 130.w,
                              width: isTab(context) ? 180.w : 130.w,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: pink,
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/images/mic.png',
                                    height: 80.w,
                                    width: 80.w,
                                  ),
                                  SizedBox(height: 5.h),
                                  TextWidget(
                                    text: 'Karaoke',
                                    fontSize: 16.sp,
                                    fontFamily: 'M',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: isTab(context) ? 40.w : 20.w),
                          InkWell(
                            onTap: () {
                              Get.to(() => MyRecordingScreen());
                            },
                            child: Container(
                              height: 130.w,
                              width: isTab(context) ? 180.w : 130.w,
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: pink,
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset('assets/images/speaker.png', height: 80.w, width: 80.w),
                                  SizedBox(height: 5.h),
                                  TextWidget(
                                    text: 'Recordings',
                                    fontSize: 16.sp,
                                    fontFamily: 'M',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading.value)
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: pink),
                    SizedBox(height: 10.h),
                    TextWidget(
                      text: 'Fetching Data...',
                      fontSize: 16.sp,
                      fontFamily: 'M',
                    ),
                  ],
                )),
            ],
          );
        }),
      ),
    );
  }
}
