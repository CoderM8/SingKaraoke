import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee/marquee.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sing_karaoke/UI/mainscreen.dart';
import 'package:sing_karaoke/UI/microphonepermission.dart';
import 'package:sing_karaoke/ads/ads_manager.dart';
import 'package:video_storage_query/video_storage_query.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Color
const Color white = const Color(0xffFFFFFF);
const Color black = const Color(0xff000000);
const Color blue = const Color(0xff080833);
const Color pink = const Color(0xffFF296D);
const Color yellow = const Color(0xffFFBE5C);
const Color green = const Color(0xffAEFF5C);
const Color clay = const Color(0xff5CFFCE);
const Color purple = const Color(0xffAE5CFF);

/// Tab
bool isTab(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= 600 && MediaQuery.sizeOf(context).width < 2048;
}

/// WebViewController
WebViewController wc = WebViewController();

/// Ads
IAdIdManager adIdManager = AdsTestAdIdManager();

/// Listening to the callbacks
StreamSubscription? streamSubscription;

/// GetStorage
final box = GetStorage();

bool isNew = false;

/// open picker
bool isOpenPicker = false;
RxBool player = false.obs;
RxBool isLoading = false.obs;

/// Musics
RxList<Music> allMusics = <Music>[].obs;
RxList<Map> musics = <Map>[].obs;

/// Videos
RxList<Video> allVideos = <Video>[].obs;
RxList<Map> videos = <Map>[].obs;

OnAudioQuery onAudioQuery = OnAudioQuery();

/// Navigate Music Type
enum MusicType { artist, album, other }

/// Navigate Screen Type
enum NavigateType { music, video }

/// Audio & Audio MIX
AudioPlayer audioPlayer = AudioPlayer();
AudioPlayer audioPlayer2 = AudioPlayer();

/// Video & Audio MIX
final AudioPlayer audioMixPlayer = AudioPlayer();

/// Handle Multiple AudioPlayer
AudioPlayer set(isOne) {
  return isOne == false ? audioPlayer : audioPlayer2;
}

/// Get thumbnail image localStorage variable
bool isLocalStorage = false;

RefreshController refreshController = RefreshController(initialRefresh: false);
int startIndex = 0;

const String iosReview = 'https://itunes.apple.com/app/id6474890476?action=write-review';
const String IOSLink = 'https://apps.apple.com/us/app/sing-karaoke/id66474890476';
const String androidReview = '';
const String androidLink = '';

String get appReview {
  if (Platform.isAndroid) {
    return androidReview;
  } else {
    return iosReview;
  }
}

String get appShare {
  if (Platform.isAndroid) {
    return androidLink;
  } else {
    return IOSLink;
  }
}

/// Get Video From Phone Storage (Android)
Future<void> getVideoFromStorageAndroid() async {
  try {
    List<VideoItem> videos = await VideoStorageQuery().queryVideos();
    int count = 0; // Counter to limit the number of videos loaded
    for (var i = startIndex; i < videos.length; i++) {
      if (count >= 8) break; // Break loop if 8 videos are loaded
      var entity = videos[i];
      isLocalStorage = true;
      Uint8List image = await getVideoThumbImage(entity.path, isLocalStorage);
      allVideos.add(Video(title: basename(entity.name), videoImage: image, videoPath: entity.path, isLocalStorage: isLocalStorage));
      count++;
    }
    startIndex += 8;
    isLoading.value = false;
  } catch (e) {
    isLoading.value = false;
  }
}
// List<VideoItem> videos = await VideoStorageQuery().queryVideos();
// for (var entity in videos) {
//   isLocalStorage = true;
//   List<String> pathParts = entity.path.split('/');
//   String filename = pathParts.last;
//   String sanitizedFilename = filename.replaceAll(RegExp(r'[^\w\s.]+'), '');
//   String urlpath = entity.path.replaceFirst(filename, sanitizedFilename);
//   Uint8List image = await getVideoThumbImage(urlpath, isLocalStorage);
//   allVideos.add(Video(title: basename(entity.name), videoImage: image, videoPath: entity.path, isLocalStorage: isLocalStorage));
// }

/// Get video from thumbnail Image (Android & IOS)
/// Method => Android : VideoStorageQuery().getVideoThumbnail || IOS : VideoThumbnail.thumbnailFile
getVideoThumbImage(videoPathUrl, isLocalStorage) async {
  if (isLocalStorage == true) {
    try {
      Uint8List image = await VideoStorageQuery().getVideoThumbnail(videoPathUrl);
      return image;
    } catch (e, t) {
      print('VideoThumbnail Storage Error ----- ${e}');
      print('VideoThumbnail Storage Trace ----- ${t}');
      return 'ERROR';
    }
  } else {
    try {
      String tempPath = (await getApplicationDocumentsDirectory()).path;
      String? image = await VideoThumbnail.thumbnailFile(
        video: videoPathUrl,
        thumbnailPath: tempPath,
        imageFormat: ImageFormat.JPEG,
        quality: 75,
      );
      return image ?? 'ERROR';
    } catch (e, t) {
      print('VideoThumbnail File Error ----- ${e}');
      print('VideoThumbnail File Trace ----- ${t}');
      return 'ERROR';
    }
  }
}

Future<void> playSong({required int id, required String url, required String name}) async {
  player.value = false;
  set(player.value);
  final AudioSource audioSource = AudioSource.file(url, tag: AudioMetadata(title: name, id: id.toString()));
  AudioSource concatenatingAudioSource = ConcatenatingAudioSource(children: [audioSource], useLazyPreparation: false);
  audioPlayer.setAudioSource(concatenatingAudioSource);
  audioPlayer.setLoopMode(LoopMode.one);
  audioPlayer.setVolume(1.0);
  audioPlayer.play();
}

Future<void> playMultipleSong({required int id, required String url, required String name}) async {
  player.value = true;
  set(player.value);
  audioPlayer.stop();
  final AudioSource audioSource = AudioSource.file(url, tag: AudioMetadata(title: name, id: id.toString()));
  AudioSource concatenatingAudioSource = ConcatenatingAudioSource(children: [audioSource], useLazyPreparation: false);
  audioPlayer2.setAudioSource(concatenatingAudioSource);
  audioPlayer2.setLoopMode(LoopMode.one);
  audioPlayer2.setVolume(1.0);
  audioPlayer2.play();
}

/// Toast
showToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    fontSize: 18.sp,
  );
}

Future showPermission({required PerType type}) {
  return Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20.h),
              TextWidget(text: 'Permission', color: blue, fontSize: 20.sp, fontFamily: 'B'),
              SizedBox(height: 20.h),
              TextWidget(
                text: 'Allow access to your xxx. Tap Settings > Permissions, and turn the xxx on.'.replaceAll('xxx', type.name),
                fontSize: 16.sp,
                color: black,
                maxLines: 3,
                fontFamily: 'M',
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 40.h,
                        alignment: Alignment.center,
                        child: TextWidget(text: 'Cancel', fontSize: 16.sp, color: black),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        await openAppSettings();
                        Get.back();
                      },
                      child: Container(
                        height: 40.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: pink, borderRadius: BorderRadius.circular(10.r)),
                        child: TextWidget(text: 'Settings', fontSize: 16.sp, fontFamily: 'B'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ));
}

enum PerType { Tracking, Microphone }

Future<bool> allPermissionIOS({required PerType type, bool isVisit = false}) async {
  switch (type) {
    case PerType.Tracking:
      {
        final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await AppTrackingTransparency.requestTrackingAuthorization();
        } else if (status == TrackingStatus.denied) {
          await showPermission(type: type);
        }
        if (status == TrackingStatus.authorized) {
          await AppTrackingTransparency.getAdvertisingIdentifier();
        }
        if (isVisit) {
          Get.offAll(() => MicrophonePermission());
        }
        return status == TrackingStatus.authorized;
      }
    case PerType.Microphone:
      {
        PermissionStatus status = await Permission.microphone.request();
        if (status.isPermanentlyDenied && !isVisit) {
          await showPermission(type: type);
        }
        if (isVisit) {
          Get.offAll(() => MainScreen());
        }
        return status.isGranted;
      }
  }
}

Future<void> allPermissionAndroid() async {
  /// Storage & Microphone
  if (isAndroidVersionUp13) {
    PermissionStatus audio = await Permission.audio.status;
    PermissionStatus videos = await Permission.videos.status;
    PermissionStatus microphone = await Permission.microphone.status;
    if (audio == PermissionStatus.denied ||
        audio == PermissionStatus.permanentlyDenied ||
        videos == PermissionStatus.denied ||
        videos == PermissionStatus.permanentlyDenied ||
        microphone == PermissionStatus.denied ||
        microphone == PermissionStatus.permanentlyDenied) {
      await [
        Permission.audio,
        Permission.videos,
        Permission.microphone,
      ].request();
    }
  } else {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.microphone,
    ].request();
    if (statuses[Permission.storage]!.isGranted && statuses[Permission.microphone]!.isGranted) {
    } else {
      await openAppSettings();
    }
  }
}

bool isAndroidVersionUp13 = false;

/// Get Android Version
Future<void> getDeviceInfo() async {
  String? firstPart;
  final deviceInfoPlugin = DeviceInfoPlugin();
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  final allInfo = deviceInfo.data;
  if (allInfo['version']["release"].toString().contains(".")) {
    int indexOfFirstDot = allInfo['version']["release"].indexOf(".");
    firstPart = allInfo['version']["release"].substring(0, indexOfFirstDot);
  } else {
    firstPart = allInfo['version']["release"];
  }
  int intValue = int.parse(firstPart!);
  if (intValue >= 13) {
    isAndroidVersionUp13 = true;
  } else {
    isAndroidVersionUp13 = false;
  }
}

/// Text Widget
class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.letterSpacing,
    this.height,
    this.fontFamily,
    this.textDecoration,
  });

  final String text;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;
  final FontWeight? fontWeight;
  final Color? color;
  final String? fontFamily;
  final TextDecoration? textDecoration;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines ?? 1,
      overflow: overflow,
      softWrap: true,
      style: TextStyle(
          fontSize: fontSize ?? 14.sp / MediaQuery.of(context).textScaleFactor,
          fontWeight: fontWeight ?? FontWeight.normal,
          color: color ?? white,
          letterSpacing: letterSpacing,
          height: height,
          fontFamily: fontFamily ?? "B",
          decoration: textDecoration),
    );
  }
}

/// MaybeMarqueeText
class MaybeMarqueeText extends StatelessWidget {
  final String text;

  const MaybeMarqueeText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (_willTextOverflow(context, text: text)) {
      return SizedBox(
        height: 30.h,
        width: MediaQuery.sizeOf(context).width,
        child: Marquee(
          text: text,
          style: TextStyle(
            fontSize: 20.sp / MediaQuery.of(context).textScaleFactor,
            color: white,
            fontFamily: 'M',
          ),
          velocity: 30,
          blankSpace: MediaQuery.sizeOf(context).width / 5,
        ),
      );
    } else {
      return SizedBox(
        height: 30.h,
        width: MediaQuery.sizeOf(context).width,
        child: TextWidget(
          text: text,
          fontFamily: 'M',
          textAlign: TextAlign.center,
          fontSize: 20.sp,
        ),
      );
    }
  }

  bool _willTextOverflow(context, {required String text}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 20.sp, color: white, fontFamily: 'M')),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: MediaQuery.sizeOf(context).width);
    return textPainter.didExceedMaxLines;
  }
}

Future<void> loader({required String songName}) async {
  Get.dialog(
      barrierDismissible: false,
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(text: 'Audio Processing...', fontFamily: 'M', fontSize: 16.sp, color: black),
              Lottie.asset('assets/images/loader.json', width: 130.w),
              TextWidget(text: 'Please Wait...', fontFamily: 'M', fontSize: 16.sp, color: black),
              TextWidget(text: songName, maxLines: 2, fontFamily: 'SB', fontSize: 14.sp, color: black, textAlign: TextAlign.center),
            ],
          ),
        ),
      ));
  await Future.delayed(Duration(seconds: 4));
  Get.back();
}

class AudioMetadata {
  final String title;
  final String id;

  AudioMetadata({
    required this.title,
    required this.id,
  });
}

class Video {
  final String title;
  final dynamic videoImage;
  final String videoPath;
  final bool isLocalStorage;

  Video({required this.title, this.videoImage, required this.videoPath, required this.isLocalStorage});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoImage': videoImage,
      'videoPath': videoPath,
      'isLocalStorage': isLocalStorage,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      title: map['title'],
      videoImage: map['videoImage'],
      videoPath: map['videoPath'],
      isLocalStorage: map['isLocalStorage'],
    );
  }
}

class Music {
  final int id;
  final String title;
  final String audioPath;
  final String album;

  Music({required this.id, required this.title, required this.audioPath, required this.album});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audioPath': audioPath,
      'album': album,
    };
  }

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      id: map['id'],
      title: map['title'],
      audioPath: map['audioPath'],
      album: map['album'],
    );
  }
}

class RecordAudio {
  final int id;
  final String title;
  final String audioPath;
  final String? time;

  RecordAudio({required this.id, required this.title, required this.audioPath,this.time});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'audioPath': audioPath,
      'time': time,
    };
  }

  factory RecordAudio.fromMap(Map<String, dynamic> map) {
    return RecordAudio(
      id: map['id'],
      title: map['title'],
      audioPath: map['audioPath'],
      time: map['time'] ?? DateTime.now().toIso8601String(),
    );
  }
}
