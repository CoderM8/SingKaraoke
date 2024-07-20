// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sing_karaoke/Controller/playercontroller.dart';
import 'package:sing_karaoke/Services/audio_play_services.dart';
import 'package:sing_karaoke/constant.dart';
import 'albumsongscreen.dart';
import 'artistsongscreen.dart';
import 'positionSeekWidget.dart';

class PlayerScreen extends StatelessWidget {
  PlayerScreen({super.key, required this.musicType, this.id, this.name, this.isRecord = false});

  final MusicType musicType;
  final int? id;
  final String? name;
  final bool? isRecord;

  final PlayerController pc = Get.put(PlayerController());

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
        title: TextWidget(text: 'Sing karaoke Offline', fontFamily: 'M', fontSize: 16.sp),
        centerTitle: true,
        actions: [
          if (isRecord == false) ...[
            InkWell(
                onTap: () {
                  switch (musicType) {
                    case MusicType.artist:
                      Get.to(() => ArtistSongScreen(artistId: id!, artistName: name!, isBack: true));
                      break;
                    case MusicType.album:
                      Get.to(() => AlbumSongScreen(albumId: id!, albumName: name!, isBack: true));
                      break;
                    case MusicType.other:
                      Get.back();
                      break;
                    default:
                      Get.back();
                  }
                },
                child: SvgPicture.asset('assets/icons/music.svg')),
            SizedBox(width: 16.w)
          ]
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/playerbg.png',
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            fit: BoxFit.fill,
          ),
          Obx(() {
            player.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 SizedBox(height: 20.h),
                Container(
                  height: 268.w,
                  width: 268.w,
                  padding: const EdgeInsets.all(50),
                  decoration: BoxDecoration(color: pink, borderRadius: BorderRadius.circular(30.r)),
                  child: SvgPicture.asset('assets/icons/music.svg'),
                ),
                SizedBox(height: 20.h),
                StreamBuilder<SequenceState?>(
                    stream: set(player.value).sequenceStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state?.sequence.isEmpty ?? true) {
                        return const SizedBox.shrink();
                      }
                      final metadata = state!.currentSource!.tag as AudioMetadata;
                      return MaybeMarqueeText(metadata.title);
                    }),
                SizedBox(height: 20.h),
                StreamBuilder<PositionData>(
                  stream: positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ?? PositionData(Duration.zero, Duration.zero, Duration.zero);
                    return PositionSeekWidget(
                      duration: positionData.duration,
                      currentPosition: positionData.position,
                      seekTo: (newPosition) {
                        set(player.value).seek(newPosition);
                      },
                      bgColor: blue,
                    );
                  },
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (pc.restart.value == true) ...[
                        const Spacer(),
                        InkWell(
                          onTap: () async {
                            audioPlayer2.stop();
                            audioPlayer.play();
                            player.value = false;
                            pc.restart.value = false;
                          },
                          child: Container(
                            height: 50.w,
                            width: 50.w,
                            decoration: BoxDecoration(color: white, shape: BoxShape.circle),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset('assets/icons/restart.svg', color: pink),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                      ],
                      StreamBuilder<PlayerState>(
                        stream: set(player.value).playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 55.w,
                              height: 55.w,
                              child: CircularProgressIndicator(color: pink),
                            );
                          } else if (playing != true) {
                            return IconButton(
                              icon: SvgPicture.asset('assets/icons/playicon.svg'),
                              iconSize: 85.w,
                              onPressed: set(player.value).play,
                            );
                          } else {
                            return IconButton(
                              icon: SvgPicture.asset('assets/icons/pauseicon.svg'),
                              iconSize: 85.w,
                              onPressed: set(player.value).pause,
                            );
                          }
                        },
                      ),
                      if (pc.restart.value == true)
                        const Spacer(
                          flex: 2,
                        )
                    ],
                  );
                }),
                SizedBox(height: 25.h),
                if (isRecord == false)
                  Container(
                    height: 58.w,
                    padding: EdgeInsets.symmetric(horizontal: isTab(context) ? 20.w : 20.w),
                    margin: EdgeInsets.symmetric(horizontal: isTab(context) ? 50.w : 20.w),
                    decoration: BoxDecoration(color: pink, borderRadius: BorderRadius.circular(10.r)),
                    child: Row(
                      children: [
                        Obx(() {
                          pc.playAudio.value;
                          return InkWell(
                              onTap: () async {
                                pc.playAudio.value = !pc.playAudio.value;
                                if (pc.playAudio.value) pc.startRecord();
                                if (!pc.playAudio.value) pc.stopRecord();
                              },
                              child: SvgPicture.asset(pc.playAudio.value ? 'assets/icons/recordpause.svg' : 'assets/icons/recordplay.svg'));
                        }),
                        SizedBox(width: 11.w),
                        TextWidget(
                          text: 'Recording',
                          fontFamily: 'R',
                          fontSize: 14.sp,
                        ),
                        const Spacer(),
                        Obx(() {
                          return TextWidget(
                            text: pc.formatDuration(pc.time.value),
                            fontFamily: 'M',
                            fontSize: 16.sp,
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            );
          }),
          Positioned(
              bottom: 15.h,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    constraints: BoxConstraints(maxHeight: isRecord == false ? 260.h : 160.h, minWidth: MediaQuery.sizeOf(context).width),
                    context: context,
                    backgroundColor: white,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                        child: Column(
                          children: [
                            TextWidget(
                              text: 'Volume Setting',
                              fontFamily: 'SB',
                              color: black,
                              fontSize: 18.sp,
                            ),
                            if (isRecord == false) ...[
                              SizedBox(height: 30.h),
                              TextWidget(text: 'Vocal Volume', fontFamily: 'M', color: black, fontSize: 14.sp),
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/mute.svg'),
                                  Expanded(
                                    child: Obx(() {
                                      pc.record.value;
                                      return Slider(
                                        min: 0,
                                        max: 1,
                                        value: pc.record.value,
                                        activeColor: black,
                                        inactiveColor: Colors.grey,
                                        onChanged: (double value) {
                                          pc.record.value = value;
                                          audioPlayer2.setVolume(value);
                                        },
                                      );
                                    }),
                                  ),
                                  SvgPicture.asset('assets/icons/volume.svg'),
                                ],
                              ),
                            ],
                            SizedBox(height: 25.h),
                            TextWidget(
                              text: 'Music Volume',
                              fontFamily: 'M',
                              color: black,
                              fontSize: 14.sp,
                            ),
                            Row(
                              children: [
                                SvgPicture.asset('assets/icons/mute.svg'),
                                Expanded(
                                  child: Obx(() {
                                    pc.music.value;
                                    return Slider(
                                      min: 0,
                                      max: 1,
                                      value: pc.music.value,
                                      activeColor: black,
                                      inactiveColor: Colors.grey,
                                      onChanged: (double value) {
                                        pc.music.value = value;
                                        audioPlayer.setVolume(value);
                                      },
                                    );
                                  }),
                                ),
                                SvgPicture.asset('assets/icons/volume.svg'),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Column(
                  children: [
                    SvgPicture.asset('assets/icons/up.svg'),
                    SizedBox(height: 3.h),
                    TextWidget(
                      text: 'Volume Setting',
                      fontFamily: 'M',
                      fontSize: 12.sp,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
