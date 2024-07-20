import 'dart:io';

import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sing_karaoke/UI/playerscreen.dart';
import 'package:sing_karaoke/UI/videoplayer.dart';
import 'package:sing_karaoke/constant.dart';

String? googleAppId = 'ca-app-pub-1031554205279977~6760213721';
String? facebookAppId = '1510688529802552';

String? googleBannerAndroid;
String? googleBannerIOS = 'ca-app-pub-1031554205279977/8065169491';
String? facebookBannerAndroid;
String? facebookBannerIOS = '7186704254769627_7186707641435955';

String? googleInterstitialAndroid;
String? googleInterstitialIOS = 'ca-app-pub-1031554205279977/3598863765';
String? facebookInterstitialAndroid;
String? facebookInterstitialIOS = '7186704254769627_7186707941435925';

String? googleRewardedAndroid;
String? googleRewardedIOS = 'ca-app-pub-1031554205279977/5067572699';
String? facebookRewardedAndroid;
String? facebookRewardedIOS = '7186704254769627_7186708844769168';

class AdsTestAdIdManager extends IAdIdManager {
  AdsTestAdIdManager();

  @override
  AppAdIds? get fbAdIds => AppAdIds(
        appId: facebookAppId!,
        bannerId: Platform.isIOS ? facebookBannerIOS : facebookBannerAndroid,
        interstitialId: Platform.isIOS ? facebookInterstitialIOS : facebookInterstitialAndroid,
        rewardedId: Platform.isIOS ? facebookRewardedIOS : facebookRewardedAndroid,
      );

  @override
  AppAdIds? get admobAdIds => AppAdIds(
        appId: googleAppId!,
        bannerId: Platform.isIOS ? googleBannerIOS : googleBannerAndroid,
        interstitialId: Platform.isIOS ? googleInterstitialIOS : googleInterstitialAndroid,
        rewardedId: Platform.isIOS ? googleRewardedIOS : googleRewardedAndroid,
      );

  @override
  AppAdIds? get unityAdIds => null;

  @override
  AppAdIds? get appLovinAdIds => null;
}

/// Banner Ads
Widget bannerAds() {
  return EasySmartBannerAd(
    priorityAdNetworks: [AdNetwork.facebook, AdNetwork.admob],
    adSize: AdSize.banner,
  );
}

/// Interstitial & Rewarded Ads
 showAd(
    {required AdUnitType adUnitType,
    required NavigateType navigateType,
    int? id,
    String? title,
    int? pid,
    String? pname,
    required String path,
    MusicType? type}) async {
  if (adUnitType == AdUnitType.interstitial) {
    streamSubscription?.cancel();
    if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.facebook)) {
      streamSubscription = EasyAds.instance.onEvent.listen((event) async {
        if (event.adUnitType == adUnitType && event.type == AdEventType.adDismissed) {
          print('dismissed ----------> Facebook interstitial');
          if (navigateType == NavigateType.music) {
            await loader(songName: title!).whenComplete(() =>
                playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
          } else {
            Get.to(() => VideoPlayerScreen(link: path));
          }
        }
      });
    } else if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.admob)) {
      streamSubscription = EasyAds.instance.onEvent.listen((event) async {
        if (event.adUnitType == adUnitType && event.type == AdEventType.adDismissed) {
          print('dismissed ----------> Google interstitial');
          if (navigateType == NavigateType.music) {
            await loader(songName: title!).whenComplete(() =>
                playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
          } else {
            Get.to(() => VideoPlayerScreen(link: path));
          }
        }
      });
    }
  } else if (adUnitType == AdUnitType.rewarded) {
    streamSubscription?.cancel();
    if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.facebook)) {
      streamSubscription = EasyAds.instance.onEvent.listen((event) async {
        if (event.adUnitType == adUnitType && event.type == AdEventType.adDismissed) {
          print('dismissed ----------> Facebook rewarded');
          if (navigateType == NavigateType.music) {
            await loader(songName: title!).whenComplete(() =>
                playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
          } else {
            Get.to(() => VideoPlayerScreen(link: path));
          }
        }
      });
    } else if (EasyAds.instance.showAd(adUnitType, adNetwork: AdNetwork.admob)) {
      streamSubscription = EasyAds.instance.onEvent.listen((event) async {
        if (event.adUnitType == adUnitType && event.type == AdEventType.adDismissed) {
          print('dismissed ----------> Google rewarded');
          if (navigateType == NavigateType.music) {
            await loader(songName: title!).whenComplete(() =>
                playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
          } else {
            Get.to(() => VideoPlayerScreen(link: path));
          }
        }
      });
    }
  }
}
