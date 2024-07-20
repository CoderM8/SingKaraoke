// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sing_karaoke/Controller/homecontroller.dart';
import 'package:sing_karaoke/UI/albumsongscreen.dart';
import 'package:sing_karaoke/UI/artistsongscreen.dart';
import 'package:sing_karaoke/UI/drawerscreen.dart';
import 'package:sing_karaoke/UI/mainscreen.dart';
import 'package:sing_karaoke/UI/searchscreen.dart';
import 'package:sing_karaoke/ads/ads_manager.dart';
import 'package:sing_karaoke/constant.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController hc = Get.put(HomeController());
  final drawerkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: drawerkey,
      drawerEnableOpenDragGesture: true,
      drawer: const DrawerScreen(),
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: InkWell(
            onTap: () {
              drawerkey.currentState!.openDrawer();
            },
            child: SvgPicture.asset('assets/icons/drawer.svg', width: 25.w, height: 25.w),
          ),
        ),
        elevation: 0,
        leadingWidth: 35.w,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Get.offAll(() => MainScreen());
              },
              child: SvgPicture.asset('assets/icons/home.svg', width: 25.w, height: 25.w, color: white),
            ),
            const Spacer(),
            TextWidget(text: 'Sing karaoke Offline', fontFamily: 'M', fontSize: 18.sp),
            const Spacer(),
          ],
        ),
        centerTitle: true,
        actions: [
          if (Platform.isIOS) ...[
            InkWell(
                onTap: () {
                  switch (hc.tabIndex.value) {
                    case 0:
                      hc.getAllMusicsIOS();
                      break;
                    case 1:
                      hc.getAllVideosIOS();
                      break;
                  }
                },
                child: Icon(Icons.file_open_outlined, color: white)),
            SizedBox(width: 16.w)
          ],
          InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                Get.to(() => SearchScreen());
              },
              child: SvgPicture.asset('assets/icons/search.svg')),
          SizedBox(width: 16.w)
        ],
      ),
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.only(bottom: 15.0),
        child: bannerAds(),
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          SvgPicture.asset('assets/images/polygon.svg', height: 300.w, width: 250.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 110.h,
                width: MediaQuery.sizeOf(context).width,
                child: Obx(() {
                  return TabBar(
                    indicatorColor: Colors.transparent,
                    controller: hc.tabController,
                    padding: EdgeInsets.zero,
                    isScrollable: false,
                    physics: const BouncingScrollPhysics(),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    labelColor: white,
                    labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
                    onTap: (index) {
                      hc.tabIndex.value = index;
                    },
                    tabs: [
                      Tab(
                        height: 98.h,
                        child: Column(
                          children: [
                            Container(
                              height: 70.h,
                              width: 70.h,
                              padding: const EdgeInsets.all(15),
                              decoration: ShapeDecoration.fromBoxDecoration(BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r), color: hc.tabIndex.value == 0 ? yellow : yellow.withOpacity(0.5))),
                              child: SvgPicture.asset('assets/icons/track.svg'),
                            ),
                            TextWidget(
                              text: 'Track',
                              fontSize: 14.sp,
                              fontFamily: "R",
                              color: hc.tabIndex.value == 0 ? white : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                      if (Platform.isAndroid) ...[
                        Tab(
                          height: 98.h,
                          child: Column(
                            children: [
                              Container(
                                height: 70.w,
                                width: 70.w,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: hc.tabIndex.value == 1 ? green : green.withOpacity(0.5), borderRadius: BorderRadius.circular(10.r)),
                                child: SvgPicture.asset('assets/icons/artist.svg'),
                              ),
                              TextWidget(
                                text: 'Artist',
                                fontSize: 14.sp,
                                fontFamily: "R",
                                color: hc.tabIndex.value == 1 ? white : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          height: 98.h,
                          child: Column(
                            children: [
                              Container(
                                height: 70.w,
                                width: 70.w,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                    color: hc.tabIndex.value == 2 ? clay : clay.withOpacity(0.5), borderRadius: BorderRadius.circular(10.r)),
                                child: SvgPicture.asset('assets/icons/album.svg'),
                              ),
                              TextWidget(
                                text: 'Album',
                                fontSize: 14.sp,
                                fontFamily: "R",
                                color: hc.tabIndex.value == 2 ? white : Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ],
                      Tab(
                        height: 98.h,
                        child: Column(
                          children: [
                            Container(
                              height: 70.w,
                              width: 70.w,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                  color: hc.tabIndex.value == (Platform.isAndroid ? 3 : 1) ? purple : purple.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10.r)),
                              child: SvgPicture.asset('assets/icons/video.svg'),
                            ),
                            TextWidget(
                              text: 'Videos',
                              fontSize: 14.sp,
                              fontFamily: "R",
                              color: hc.tabIndex.value == (Platform.isAndroid ? 3 : 1) ? white : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
              // const Divider(
              //   color: Colors.grey,
              // ),
              Expanded(
                  child: TabBarView(physics: const BouncingScrollPhysics(), controller: hc.tabController, children: [
                AllSong(hc: hc),
                if (Platform.isAndroid) ...[
                  const Artist(),
                  const Album(),
                ],
                AllVideo(hc: hc)
              ])),
            ],
          ),
        ],
      ),
    );
  }
}

class AllSong extends StatelessWidget {
  const AllSong({super.key, required this.hc});

  final HomeController hc;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return allMusics.isNotEmpty
          ? SingleChildScrollView(
              key: UniqueKey(),
              physics: const BouncingScrollPhysics(),
              child: ListView.separated(
                itemCount: allMusics.length,
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (con, i) {
                  final Music songs = allMusics[i];
                  return InkWell(
                    onTap: () async {
                      /// interstitial
                      showAd(
                          adUnitType: AdUnitType.interstitial,
                          navigateType: NavigateType.music,
                          id: songs.id,
                          title: songs.title,
                          path: songs.audioPath,
                          type: MusicType.other);

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
                                TextWidget(
                                    text: songs.album.isNotEmpty ? songs.album : '<unknown>',
                                    fontSize: 10.sp,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),

                          SizedBox(width: 10.w),

                          // StreamBuilder<IcyMetadata?>(stream: audioPlayer.icyMetadataStream, builder: (context,snapshot){
                          //         final mediaItem = snapshot.data;
                          //         if (mediaItem == null) return SvgPicture.asset('assets/icons/play.svg', height: 25.w, width: 25.w);
                          //         return SvgPicture.asset( == songs.id ? 'assets/icons/pause.svg' : 'assets/icons/play.svg',
                          //             height: 25.w, width: 25.w);
                          // }),

                          // StreamBuilder<PlayerState>(
                          //   stream: audioPlayer.playerStateStream,
                          //   builder: (context, snapshot) {
                          //     final playerState = snapshot.data;
                          //     final processingState = playerState?.processingState;
                          //     final playing = playerState?.playing;
                          //     if (processingState == ProcessingState.loading) {
                          //       return Container(
                          //         margin: const EdgeInsets.all(8.0),
                          //         width: 55.w,
                          //         height: 55.w,
                          //         child: CircularProgressIndicator(color: pink),
                          //       );
                          //     } else if (playing != true) {
                          //       return InkWell(onTap: () async {}, child: SvgPicture.asset('assets/icons/play.svg', height: 25.w, width: 25.w));
                          //     } else {
                          //       return InkWell(onTap: () async {}, child: SvgPicture.asset('assets/icons/pause.svg', height: 25.w, width: 25.w));
                          //     }
                          //   },
                          // ),

                          SvgPicture.asset('assets/icons/play.svg', height: 25.w, width: 25.w),

                          // StreamBuilder<MediaItem?>(
                          //     stream: audioHandler.mediaItem,
                          //     builder: (context, snapshot) {
                          //       final mediaItem = snapshot.data;
                          //       if (mediaItem == null) return SvgPicture.asset('assets/icons/play.svg', height: 25.w, width: 25.w);
                          //       return SvgPicture.asset(mediaItem.extras!['id'] == songs.id ? 'assets/icons/pause.svg' : 'assets/icons/play.svg',
                          //           height: 25.w, width: 25.w);
                          //     }),
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
              ),
            )
          : Center(
              child: TextWidget(
                text: 'No Track Found!',
                fontFamily: 'B',
                fontSize: 20.sp,
              ),
            );
    });
  }
}

class Artist extends StatelessWidget {
  const Artist({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: onAudioQuery.queryArtists(),
        builder: (context, snapshot) {
          if (snapshot.hasData || snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isNotEmpty || snapshot.data != null) {
              return SingleChildScrollView(
                key: UniqueKey(),
                physics: const BouncingScrollPhysics(),
                child: ListView.separated(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, i) {
                    final artist = snapshot.data![i];
                    return InkWell(
                      onTap: () {
                        Get.to(() => ArtistSongScreen(artistId: artist.id, artistName: artist.artist));
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
                                    text: artist.artist,
                                    fontFamily: 'M',
                                    fontSize: 17.sp,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextWidget(
                                      text: '${artist.numberOfTracks.toString()}  Song',
                                      fontSize: 12.sp,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, i) {
                    return SizedBox(height: 15.h);
                  },
                ),
              );
            } else {
              return Center(
                child: TextWidget(
                  text: 'No Artist Found!',
                  fontFamily: 'B',
                  fontSize: 20.sp,
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator(color: pink));
          }
        });
  }
}

class Album extends StatelessWidget {
  const Album({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: onAudioQuery.queryAlbums(),
        builder: (context, snapshot) {
          if (snapshot.hasData || snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data!.isNotEmpty || snapshot.data != null) {
              return SingleChildScrollView(
                key: UniqueKey(),
                physics: const BouncingScrollPhysics(),
                child: ListView.separated(
                  itemCount: snapshot.data!.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, i) {
                    final album = snapshot.data![i];
                    return InkWell(
                      onTap: () {
                        Get.to(() => AlbumSongScreen(albumId: album.id, albumName: album.album));
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
                                    text: album.album,
                                    fontFamily: 'M',
                                    fontSize: 17.sp,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  TextWidget(
                                      text: '${album.numOfSongs.toString()}  Song',
                                      fontSize: 12.sp,
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, i) {
                    return SizedBox(height: 15.h);
                  },
                ),
              );
            } else {
              return Center(
                child: TextWidget(
                  text: 'No Album Found!',
                  fontFamily: 'B',
                  fontSize: 20.sp,
                ),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator(color: pink));
          }
        });
  }
}

class AllVideo extends StatelessWidget {
  const AllVideo({super.key, required this.hc});

  final HomeController hc;

  void loadVideos() async {
    // await getVideoFromStorageAndroid();
    refreshController.loadComplete();
  }

  void refresh() async {
    refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return allVideos.isNotEmpty
          ? SmartRefresher(
              controller: refreshController,
              enablePullUp: true,
              header: MaterialClassicHeader(color: pink, backgroundColor: blue),
              onLoading: loadVideos,
              scrollDirection: Axis.vertical,
              onRefresh: refresh,
              physics: const BouncingScrollPhysics(),
              child: GridView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 10.h),
                itemCount: allVideos.length,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisSpacing: 10.r, mainAxisSpacing: 10.r, childAspectRatio: 1, crossAxisCount: 2),
                itemBuilder: (context, index) {
                  print('all video link ------ ${allVideos[index].videoPath}');
                  if (!allVideos[index].videoImage!.contains('ERROR')) {
                    return InkWell(
                      onTap: () async {
                        print('video link ------ ${allVideos[index].videoPath}');

                        /// interstitial
                         showAd(adUnitType: AdUnitType.interstitial, navigateType: NavigateType.video, path: allVideos[index].videoPath);

                        //  Get.to(() => VideoPlayerScreen(link: allVideos[index].videoPath));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10.r),
                            image: allVideos[index].isLocalStorage == true
                                ? DecorationImage(image: MemoryImage(allVideos[index].videoImage!), fit: BoxFit.cover)
                                : DecorationImage(image: FileImage(File(allVideos[index].videoImage!)), fit: BoxFit.cover)),
                        child: Center(
                          child: Container(
                            height: 50.w,
                            width: 50.w,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(shape: BoxShape.circle, color: black.withOpacity(0.4)),
                            child: Center(child: SvgPicture.asset('assets/icons/playvideo.svg')),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      onTap: () {
                        /// interstitial
                        showAd(adUnitType: AdUnitType.interstitial, navigateType: NavigateType.video, path: allVideos[index].videoPath);
                        //  Get.to(() => VideoPlayerScreen(link: allVideos[index].videoPath));
                      },
                      child: Container(
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).width,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.image, color: Colors.grey, size: 120.w),
                            Center(
                              child: Container(
                                height: 50.w,
                                width: 50.w,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: black.withOpacity(0.4)),
                                child: Center(child: SvgPicture.asset('assets/icons/playvideo.svg')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            )
          : Center(
              child: TextWidget(
                text: 'No Video Found!',
                fontFamily: 'B',
                fontSize: 20.sp,
              ),
            );
    });
  }
}
