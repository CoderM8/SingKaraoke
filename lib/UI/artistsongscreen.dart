import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:sing_karaoke/ads/ads_manager.dart';
import 'package:sing_karaoke/constant.dart';

class ArtistSongScreen extends StatelessWidget {
  const ArtistSongScreen({super.key, required this.artistId, required this.artistName, this.isBack = false});

  final int artistId;
  final String artistName;
  final bool? isBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: InkWell(
            onTap: () {
              if (isBack == true) {
                Get.back();
                Get.back();
                Get.back();
              } else {
                Get.back();
              }
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
        title: TextWidget(text: artistName, fontFamily: 'M', fontSize: 18.sp),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.only(bottom: 15.0),
        child: bannerAds(),
      ),
      body: FutureBuilder<List<SongModel>>(
          future: onAudioQuery.queryAudiosFrom(AudiosFromType.ARTIST_ID, artistId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isNotEmpty) {
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (con, i) {
                    final songs = snapshot.data![i];
                    return InkWell(
                      onTap: () async {
                        /// interstitial
                         showAd(adUnitType: AdUnitType.interstitial,
                            navigateType: NavigateType.music,
                            id: songs.id,
                            title: songs.title,
                            path: songs.data,
                            type: MusicType.artist,pid: artistId,pname: artistName);


                       // await loader(songName: songs.title).whenComplete(() => playSong(id: songs.id, name: songs.title, url: songs.data)
                       //     .whenComplete(() => Get.to(() => PlayerScreen(musicType: MusicType.artist, id: artistId, name: artistName))));
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
                            Expanded(
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
                                  TextWidget(text: songs.album!, fontSize: 10.sp, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            SvgPicture.asset('assets/icons/play.svg', width: 25.w, height: 25.w),
                            SizedBox(width: 15.w),
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
                    text: 'No Artist Song Found!',
                    fontFamily: 'B',
                    fontSize: 18.sp,
                  ),
                );
              }
            } else {
              return Center(child: CircularProgressIndicator(color: pink));
            }
          }),
    );
  }
}
