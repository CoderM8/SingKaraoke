import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sing_karaoke/constant.dart';

class SearchSongController extends GetxController {

  TextEditingController search = TextEditingController();
  RxBool isRefresh = false.obs;

  Future<List<Music>> searchSongsByName(String searchTerm) async {
    return allMusics.where((song) => song.title.toLowerCase().contains(searchTerm.toLowerCase())).toList();
  }
}
