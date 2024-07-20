// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sing_karaoke/Controller/myrecordingcontroller.dart';
import 'package:sing_karaoke/Services/database.dart';
import 'package:sing_karaoke/UI/playerscreen.dart';
import 'package:sing_karaoke/ads/ads_manager.dart';
import 'package:sing_karaoke/constant.dart';

class MyRecordingScreen extends StatelessWidget {
  MyRecordingScreen({super.key});

  final MyRecordingController mc = Get.put(MyRecordingController());

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
        title: TextWidget(text: 'My Recording', fontFamily: 'M', fontSize: 18.sp),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.only(bottom: 15.0),
        child: bannerAds(),
      ),
      body: Obx(() {
        mc.isRefresh.value;
        return FutureBuilder<List<RecordAudio>>(
            future: DatabaseHelper().getRecordSongs(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, i) {
                      final songs = snapshot.data![i];
                      print('audio path ---- ${songs.audioPath}');
                      return SizedBox(
                        height: 50.h,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 50.w,
                              width: 50.w,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: pink),
                              child: SvgPicture.asset('assets/icons/music.svg'),
                            ),
                            SizedBox(width: 10.w),
                            SizedBox(
                              width: 180.w,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextWidget(
                                    text: songs.title,
                                    fontFamily: 'M',
                                    fontSize: 16.sp,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                loader(songName: songs.title).whenComplete(() => playSong(id: songs.id, name: songs.title, url: songs.audioPath)
                                    .whenComplete(() => Get.to(() => PlayerScreen(musicType: MusicType.other, isRecord: true))));
                              },
                              child: Container(
                                height: 27.w,
                                width: 50.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r), color: Colors.transparent, border: Border.all(color: pink, width: 1.w)),
                                child: Center(
                                    child: TextWidget(
                                  text: 'Sing',
                                  fontSize: 12.sp,
                                  color: pink,
                                )),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            PopupMenuButton(
                                color: blue,
                                constraints: BoxConstraints(maxWidth: 120.w),
                                shape: RoundedRectangleBorder(side: BorderSide(width: 1.w, color: white), borderRadius: BorderRadius.circular(10.r)),
                                itemBuilder: (BuildContext bc) {
                                  return [
                                    PopupMenuItem(
                                      value: '1',
                                      onTap: () async {
                                        await DatabaseHelper().deleteRecord(songs.id);
                                        mc.isRefresh.value = !mc.isRefresh.value;
                                      },
                                      child: Row(
                                        children: [
                                          SvgPicture.asset('assets/icons/delete.svg', width: 25.w, height: 25.w, color: pink),
                                          SizedBox(width: 5.w),
                                          TextWidget(
                                            text: 'Delete',
                                            fontFamily: 'M',
                                            fontSize: 16.sp,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: '2',
                                      onTap: () async {
                                        if (isTab(context)) {
                                          Share.shareXFiles([XFile(songs.audioPath)],
                                              text: songs.title,
                                              sharePositionOrigin:
                                                  Rect.fromLTWH(0, 0, MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height / 2));
                                        } else {
                                          await Share.shareXFiles([XFile(songs.audioPath)], text: songs.title);
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.share, color: pink),
                                          SizedBox(width: 5.w),
                                          TextWidget(
                                            text: 'Share',
                                            fontFamily: 'M',
                                            fontSize: 16.sp,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                                child: Icon(Icons.more_vert, color: pink)),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, i) {
                      return SizedBox(height: 15.h);
                    },
                  );
                } else {
                  return Center(
                    child: TextWidget(text: 'No Recording Found!', fontFamily: 'SB', fontSize: 16.sp),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(color: pink),
                );
              }
            });
      }),

      // Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      //     SizedBox(
      //       height: 50.h,
      //       width: MediaQuery.sizeOf(context).width,
      //       child: Obx(() {
      //         return TabBar(
      //           indicatorColor: Colors.transparent,
      //           controller: mc.tabController,
      //           padding: EdgeInsets.zero,
      //           isScrollable: false,
      //           physics: const BouncingScrollPhysics(),
      //           overlayColor: MaterialStateProperty.all(Colors.transparent),
      //           labelColor: white,
      //           labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
      //           onTap: (index) {
      //             mc.tabIndex.value = index;
      //           },
      //           tabs: [
      //             Tab(
      //
      //               child: TextWidget(
      //                 text: 'Audios',
      //                 fontSize: 15.sp,
      //                 fontFamily: "SB",
      //                 color: mc.tabIndex.value == 0 ? white : Colors.grey,
      //               ),
      //             ),
      //             Tab(
      //
      //               child: TextWidget(
      //                 text: 'Videos',
      //                 fontSize: 15.sp,
      //                 fontFamily: "SB",
      //                 color: mc.tabIndex.value == 1 ? white : Colors.grey,
      //               ),
      //             ),
      //           ],
      //         );
      //       }),
      //     ),
      //     // const Divider(
      //     //   color: Colors.grey,
      //     // ),
      //     Expanded(
      //         child: TabBarView(physics: const BouncingScrollPhysics(), controller: mc.tabController, children: [
      //       RecordAudioScreen(mc: mc),
      //       RecordVideoScreen(mc: mc),
      //     ])),
      //   ],
      // ),
    );
  }
}

class RecordAudioScreen extends StatelessWidget {
  const RecordAudioScreen({super.key, required this.mc});

  final MyRecordingController mc;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      mc.isRefresh.value;
      return FutureBuilder<List<RecordAudio>>(
          future: DatabaseHelper().getRecordSongs(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, i) {
                    final songs = snapshot.data![i];
                    return SizedBox(
                      height: 50.h,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 50.w,
                            width: 50.w,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: pink),
                            child: SvgPicture.asset('assets/icons/music.svg'),
                          ),
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 180.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWidget(
                                  text: songs.title,
                                  fontFamily: 'M',
                                  fontSize: 16.sp,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              loader(songName: songs.title).whenComplete(() => playSong(id: songs.id, name: songs.title, url: songs.audioPath)
                                  .whenComplete(() => Get.to(() => PlayerScreen(musicType: MusicType.other, isRecord: true))));
                            },
                            child: Container(
                              height: 27.w,
                              width: 50.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r), color: Colors.transparent, border: Border.all(color: pink, width: 1.w)),
                              child: Center(
                                  child: TextWidget(
                                text: 'Sing',
                                fontSize: 12.sp,
                                color: pink,
                              )),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          PopupMenuButton(
                              color: blue,
                              itemBuilder: (BuildContext bc) {
                                return [
                                  PopupMenuItem(
                                    value: '1',
                                    onTap: () async {
                                      await DatabaseHelper().deleteRecord(songs.id);
                                      mc.isRefresh.value = !mc.isRefresh.value;
                                    },
                                    child: Row(
                                      children: [
                                        SvgPicture.asset('assets/icons/delete.svg', width: 25.w, height: 25.w, color: pink),
                                        SizedBox(width: 5.w),
                                        TextWidget(
                                          text: 'Delete',
                                          fontFamily: 'M',
                                          fontSize: 16.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: '2',
                                    onTap: () async {
                                      await Share.shareXFiles([XFile(songs.audioPath)], text: songs.title);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.share, color: pink),
                                        SizedBox(width: 5.w),
                                        TextWidget(
                                          text: 'Share',
                                          fontFamily: 'M',
                                          fontSize: 16.sp,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ];
                              },
                              child: Icon(Icons.more_vert, color: pink)),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, i) {
                    return SizedBox(height: 15.h);
                  },
                );
              } else {
                return Center(
                  child: TextWidget(text: 'No Recording Found!', fontFamily: 'SB', fontSize: 16.sp),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(color: pink),
              );
            }
          });
    });
  }
}

class RecordVideoScreen extends StatelessWidget {
  const RecordVideoScreen({super.key, required this.mc});

  final MyRecordingController mc;

  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
