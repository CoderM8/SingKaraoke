import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sing_karaoke/Services/database.dart';
import 'package:sing_karaoke/constant.dart';
import 'package:uuid/uuid.dart';

class PlayerController extends GetxController {
  RxDouble music = 1.0.obs;
  RxDouble record = 1.0.obs;
  RxBool playAudio = false.obs;
  RxBool playVideo = false.obs;
  RxBool restart = false.obs;
  late Timer timer;
  RxInt time = 0.obs;
  late Record audioRecord;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onClose() {
    audioPlayer.stop();
    audioPlayer2.stop();
    audioRecord.dispose();
    super.onClose();
  }

  void init() async {
    audioRecord = Record();
  }

  Future<void> startRecord() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isGranted) {
      await audioRecord.start();
      playAudio.value = true;
      timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        time.value++;
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
    time.value = 0;
    playAudio.value = false;
    String title = basename(path);
    restart.value = true;

    await DatabaseHelper().addRecordSong(RecordAudio(id: id.hashCode, title: title, audioPath: file.path));
    showToast(message: 'Recording save Successfully');

    await playMultipleSong(id: 1, url: file.path, name: title);
  }

  String formatDuration(int s) {
    Duration duration = Duration(seconds: s);
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
