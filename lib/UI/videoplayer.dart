// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sing_karaoke/Services/audio_play_services.dart';
import 'package:sing_karaoke/Services/database.dart';
import 'package:sing_karaoke/UI/positionSeekWidget.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String link;

  const VideoPlayerScreen({super.key, required this.link});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> with WidgetsBindingObserver {
  VideoPlayerController? controller;
  int _currentPosition = 0;
  int _duration = 0;
  double music = 1.0;
  double record = 1.0;
  bool playAudio = false;
  bool playVideo = false;
  bool recordAudio = false;
  bool restart = false;
  late Timer timer;
  int time = 0;
  Record audioRecord = Record();

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
  //     setState(() {
  //       controller!.pause();
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = VideoPlayerController.file(File(widget.link), videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    attachListenerToController();
    controller!.setLooping(true);
    controller!.setVolume(1.0);
    controller!.initialize().then((_) => setState(() {}));
    controller!.play();
  }

  Future<void> startRecord() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) {
      await audioRecord.start();
      playAudio = true;
      setState(() {
        timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
          time++;
        });
      });
    } else {
      await showPermission(type: PerType.Microphone);
    }
  }

  Future<void> stopRecord() async {
    String? path = await audioRecord.stop();
    String localPath = path!.replaceAll('file://', '');
    Uint8List test = await File(localPath).readAsBytes();
    const uuid = Uuid();
    String id = uuid.v1();
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    File file = await File('${appDocumentsDir.path}/recordedAudio$id.m4a').create();
    await file.writeAsBytes(test);
    timer.cancel();
    time = 0;
    playAudio = false;
    String title = basename(path);
    restart = true;

    await DatabaseHelper().addRecordSong(RecordAudio(id: id.hashCode, title: title, audioPath: file.path));
    showToast(message: 'Recording save Successfully');
    recordAudio = true;
    await playRecordSong(id: id.hashCode, url: file.path, name: title);
  }

  Future<void> playRecordSong({required int id, required String url, required String name}) async {
    final AudioSource audioSource = AudioSource.file(url, tag: AudioMetadata(title: name, id: id.toString()));
    AudioSource concatenatingAudioSource = ConcatenatingAudioSource(children: [audioSource], useLazyPreparation: false);
    audioMixPlayer.setAudioSource(concatenatingAudioSource);
    audioMixPlayer.setLoopMode(LoopMode.one);
    audioMixPlayer.setVolume(1.0);
    audioMixPlayer.play();
    controller!.play();
  }

  String formatDuration(int s) {
    Duration duration = Duration(seconds: s);
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  attachListenerToController() {
    controller!.addListener(
      () {
        if (mounted) {
          setState(() {
            _currentPosition = controller!.value.duration.inMilliseconds == 0 ? 0 : controller!.value.position.inMilliseconds;
            _duration = controller!.value.duration.inMilliseconds;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller!.dispose();
    audioMixPlayer.stop();
    super.dispose();
  }

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
        title: TextWidget(text: 'Sing Karaoke Offline', fontFamily: 'M', fontSize: 18.sp),
        centerTitle: true,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 25.h),
              Center(child: SizedBox(width: MediaQuery.sizeOf(context).width / 1.1, height: 250.h, child: VideoPlayer(controller!))),
              SizedBox(height: 30.h),
              recordAudio == true
                  ? StreamBuilder<PositionData>(
                      stream: videoPositionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data ?? PositionData(Duration.zero, Duration.zero, Duration.zero);
                        return PositionSeekWidget(
                          duration: positionData.duration,
                          currentPosition: positionData.position,
                          seekTo: (newPosition) {
                            audioMixPlayer.seek(newPosition);
                          },
                          bgColor: blue,
                        );
                      },
                    )
                  : PositionSeekWidget(
                      currentPosition: Duration(milliseconds: _currentPosition),
                      duration: Duration(milliseconds: _duration),
                      seekTo: (v) {
                        controller!.seekTo(v);
                      }),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (restart == true) ...[
                    const Spacer(),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          restart = false;
                          recordAudio = false;
                          controller!.play();
                          playVideo = false;
                          audioMixPlayer.stop();
                        });
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
                  IconButton(
                    icon: SvgPicture.asset(playVideo == false ? 'assets/icons/pauseicon.svg' : 'assets/icons/playicon.svg'),
                    iconSize: 85.w,
                    onPressed: () {
                      setState(() {
                        playVideo = !playVideo;
                        playVideo ? {controller!.pause(), audioMixPlayer.pause()} : {controller!.play(), audioMixPlayer.play()};
                      });
                    },
                  ),
                  if (restart == true)
                    const Spacer(
                      flex: 2,
                    )
                ],
              ),
              SizedBox(height: 35.h),
              Container(
                height: 58.w,
                padding: EdgeInsets.symmetric(horizontal: isTab(context) ? 20.w : 20.w),
                margin: EdgeInsets.symmetric(horizontal: isTab(context) ? 50.w : 20.w),
                decoration: BoxDecoration(color: pink, borderRadius: BorderRadius.circular(10.r)),
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          setState(() {
                            playAudio = !playAudio;
                            if (playAudio) startRecord();
                            if (!playAudio) stopRecord();
                          });
                        },
                        child: SvgPicture.asset(playAudio ? 'assets/icons/recordpause.svg' : 'assets/icons/recordplay.svg')),
                    SizedBox(width: 11.w),
                    TextWidget(
                      text: 'Recording',
                      fontFamily: 'R',
                      fontSize: 14.sp,
                    ),
                    const Spacer(),
                    TextWidget(
                      text: formatDuration(time),
                      fontFamily: 'M',
                      fontSize: 16.sp,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 18.h),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      constraints: BoxConstraints(maxHeight: 260.h, minWidth: MediaQuery.sizeOf(context).width),
                      context: context,
                      backgroundColor: white,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
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
                                SizedBox(height: 30.h),
                                TextWidget(text: 'Vocal Volume', fontFamily: 'M', color: black, fontSize: 14.sp),
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/icons/mute.svg'),
                                    Expanded(
                                      child: Slider(
                                        min: 0,
                                        max: 1,
                                        value: record,
                                        activeColor: black,
                                        inactiveColor: Colors.grey,
                                        onChanged: (double value) {
                                          setState(() {
                                            record = value;
                                            audioMixPlayer.setVolume(value);
                                          });
                                        },
                                      ),
                                    ),
                                    SvgPicture.asset('assets/icons/volume.svg'),
                                  ],
                                ),
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
                                      child: Slider(
                                        min: 0,
                                        max: 1,
                                        value: music,
                                        activeColor: black,
                                        inactiveColor: Colors.grey,
                                        onChanged: (double value) {
                                          setState(() {
                                            music = value;
                                            controller!.setVolume(value);
                                          });
                                        },
                                      ),
                                    ),
                                    SvgPicture.asset('assets/icons/volume.svg'),
                                  ],
                                ),
                              ],
                            ),
                          );
                        });
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
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}

String durationFormatter(int milliSeconds) {
  int seconds = milliSeconds ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  var minutes = seconds ~/ 60;
  seconds = seconds % 60;
  final hoursString = hours >= 10
      ? '$hours'
      : hours == 0
          ? '00'
          : '0$hours';
  final minutesString = minutes >= 10
      ? '$minutes'
      : minutes == 0
          ? '00'
          : '0$minutes';
  final secondsString = seconds >= 10
      ? '$seconds'
      : seconds == 0
          ? '00'
          : '0$seconds';
  final formattedTime = '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';
  return formattedTime;
}
