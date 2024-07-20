import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:sing_karaoke/Controller/searchcontroller.dart';
import 'package:sing_karaoke/ads/ads_manager.dart';
import 'package:sing_karaoke/constant.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final SearchSongController ss = Get.put(SearchSongController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 55.h,
        backgroundColor: blue,
        flexibleSpace: Container(
            height: 40,
            margin: EdgeInsets.only(top: 40.h, left: 15.w, right: 15.w),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: SvgPicture.asset(
                    'assets/icons/back.svg',
                    width: 17.w,
                    height: 17.w,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    textAlign: TextAlign.start,
                    controller: ss.search,
                    style: TextStyle(fontFamily: 'SB', color: white),
                    onChanged: (v) {
                      ss.isRefresh.value = !ss.isRefresh.value;
                    },
                    decoration: InputDecoration(
                        suffixIcon: InkWell(
                            onTap: () {
                              ss.search.clear();
                              ss.isRefresh.value = !ss.isRefresh.value;
                            },
                            child: Icon(
                              Icons.clear,
                              color: white,
                            )),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: UnderlineInputBorder(borderSide: BorderSide(color: white, width: 1), borderRadius: BorderRadius.circular(5)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: white, width: 1), borderRadius: BorderRadius.circular(5)),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: white,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(5)),
                        hintStyle: TextStyle(color: white, fontFamily: 'SB'),
                        hintText: "Search  Music"),
                  ),
                ),
              ],
            )),
      ),
      body: Obx(() {
        ss.isRefresh.value;
        return FutureBuilder<List<Music>>(
            future: ss.searchSongsByName(ss.search.text),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data!.isNotEmpty) {
                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 15.h),
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (con, i) {
                      final songs = snapshot.data![i];
                      return InkWell(
                        onTap: () async {
                          /// interstitial
                          showAd(
                              adUnitType: AdUnitType.interstitial,
                              type: MusicType.other,
                              id: songs.id,
                              title: songs.title,
                              navigateType: NavigateType.music,
                              path: songs.audioPath);

                          //  await loader(songName: songs.title).whenComplete(() => playSong(id: songs.id, name: songs.title, url: songs.audioPath)
                          //      .whenComplete(() => Get.to(() => PlayerScreen(musicType: MusicType.other))));
                        },
                        child: SizedBox(
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
                                width: 200.w,
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
                                    TextWidget(
                                        text: songs.album.isNotEmpty ? songs.album : '<unknown>',
                                        fontSize: 10.sp,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // PlayerBuilder.isPlaying(
                              //     player: assetsAudioPlayer,
                              //     builder: (context, isPlay) {
                              //       return isPlay
                              //           ? PlayerBuilder.current(
                              //               player: assetsAudioPlayer,
                              //               builder: (context, value) {
                              //                 return SvgPicture.asset(
                              //                     value.audio.audio.metas.id == songs.id.toString()
                              //                         ? 'assets/icons/pause.svg'
                              //                         : 'assets/icons/play.svg',
                              //                     width: 25.w,
                              //                     height: 25.w);
                              //               })
                              //           : SvgPicture.asset('assets/icons/play.svg', width: 25.w, height: 25.w);
                              //     }),
                              // StreamBuilder<MediaItem?>(
                              //     stream: audioHandler.mediaItem,
                              //     builder: (context, snapshot) {
                              //       final mediaItem = snapshot.data;
                              //       if (mediaItem == null) return SvgPicture.asset('assets/icons/play.svg', height: 25.w, width: 25.w);
                              //       return SvgPicture.asset(
                              //           mediaItem.extras!['id'] == songs.id ? 'assets/icons/pause.svg' : 'assets/icons/play.svg',
                              //           height: 25.w,
                              //           width: 25.w);
                              //     }),
                              //  SizedBox(width: 15.w),
                              Container(
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
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, i) {
                      return SizedBox(height: 15.h);
                    },
                  );
                } else {
                  return Center(
                    child: TextWidget(
                      text: 'No Song Found!',
                      fontFamily: 'B',
                      fontSize: 20.sp,
                    ),
                  );
                }
              } else {
                return Center(
                  child: TextWidget(
                    text: 'No Song Found!',
                    fontFamily: 'B',
                    fontSize: 20.sp,
                  ),
                );
              }
            });
      }),
    );
  }
}
