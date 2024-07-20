import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:uuid/uuid.dart';

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  RxInt tabIndex = 0.obs;
  TabController? tabController;
  final Directory videoDir = Directory('/storage/emulated/0');
  RxBool isRefresh = false.obs;

  /// All Songs
  RxList<SongModel> allSongs = <SongModel>[].obs;

  @override
  void onInit() {
    tabController = TabController(length: Platform.isAndroid ? 4 : 2, vsync: this);
    tabController!.index = 0;
    tabController!.addListener(smoothScrollToTop);
    // if (isOpenPicker == false) {
    //   getAllMusicsIOS();
    // }
    if (Platform.isAndroid) {
      getMusicFromStorage();
    }
    super.onInit();
  }

  smoothScrollToTop() {
    tabIndex.value = tabController!.index;
  }

  /// Get Music From Phone Storage (All Songs, Artist, Album) (Android)
  Future<void> getMusicFromStorage() async {
    allSongs.value = await onAudioQuery.querySongs();
    for (var e in allSongs) {
      allMusics.add(Music(id: e.id, title: e.title, audioPath: e.data, album: e.album!));
    }
  }

  /// Get Musics From Phone Storage (IOS)
  Future<void> getAllMusicsIOS() async {
    if (Platform.isIOS) {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['mp3', 'wav', 'aac', 'm4a']);
      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        for (File element in files) {
          String audioPath = element.path;
          String audioName = basename(audioPath);
          const uuid = Uuid();
          String id = uuid.v1();
          if (allMusics.isEmpty) {
            musics.add(Music(id: id.hashCode, title: audioName, audioPath: audioPath, album: '<unknown>').toMap());
            await box.write("Musics", musics);
            List saved = box.read('Musics');
            for (var element in saved) {
              allMusics.add(Music.fromMap(element));
            }
          } else {
            allMusics.add(Music(id: id.hashCode, title: audioName, audioPath: audioPath, album: '<unknown>'));
            List<Map> musics = <Map>[];
            for (Music element in allMusics) {
              musics.add(element.toMap());
            }
            await box.write("Musics", musics);
          }
        }
      }
      // isOpenPicker = true;
      // box.write('isOpenPicker', isOpenPicker);
      // isOpenPicker = box.read('isOpenPicker');
      isRefresh.value = !isRefresh.value;
    }
  }

  /// Get Videos From Phone Storage (IOS)
  Future<void> getAllVideosIOS() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowMultiple: true, allowedExtensions: ['mp4']);
    if (result != null) {
      List<File> files = result.paths.map((path) => File(path!)).toList();
      for (File element in files) {
        String videoPath = element.path;
        String videoName = basename(videoPath);
        // List<String> pathParts = videoPath.split('/');
        // String filename = pathParts.last;
        // String sanitizedFilename = filename.replaceAll(RegExp(r'[^\w\s.]+'), '');
        // String urlpath = videoPath.replaceFirst(filename, sanitizedFilename).removeAllWhitespace;
        String image = await getVideoThumbImage(videoPath, isLocalStorage);
        if (allVideos.isEmpty) {
          videos.add(Video(title: videoName, videoPath: videoPath, videoImage: image, isLocalStorage: isLocalStorage).toMap());
          await box.write("Videos", videos);
          List saved = box.read('Videos');
          for (var element in saved) {
            allVideos.add(Video.fromMap(element));
          }
        } else {
          allVideos.add(Video(title: videoName, videoPath: videoPath, videoImage: image, isLocalStorage: isLocalStorage));
          List<Map> videos = <Map>[];
          for (Video element in allVideos) {
            videos.add(element.toMap());
          }
          await box.write("Videos", videos);
        }
      }
    }
    isRefresh.value = !isRefresh.value;
  }
}
