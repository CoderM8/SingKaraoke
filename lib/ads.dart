// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:sing_karaoke/UI/playerscreen.dart';
// import 'package:sing_karaoke/UI/videoplayer.dart';
// import 'package:sing_karaoke/constant.dart';
//
// String bannerIOS = 'ca-app-pub-3940256099942544/2934735716';
// String bannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
// String interstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
// String interstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
// InterstitialAd? interstitialAd;
//
// getAdData() async {
//   MobileAds.instance.initialize();
//   try {
//     // final request = http.MultipartRequest('POST', Uri.parse(Api.mainApi));
//     // request.fields['data'] = '{"method_name":"app_details"}';
//     // http.Response response = await http.Response.fromStream(await request.send());
//     // if (response.statusCode == 200) {
//     //   var finalres = json.decode(response.body);
//     //   bannerIOS = finalres['AUDIO_BOOK'][0]['ios_banner_ad_id'];
//     //   bannerAndroid = finalres['AUDIO_BOOK'][0]['banner_ad_id'];
//     //   interstitialAndroid = finalres['AUDIO_BOOK'][0]['interstital_ad_id'];
//     //   interstitialIOS = finalres['AUDIO_BOOK'][0]['ios_interstital_ad_id'];
//     // }
//     admobads().createInterstitialAd();
//     admobads().bannerads();
//   } catch (e) {
//     debugPrint('error in get data $e');
//   }
// }
//
// String get getBannerAdUnitId {
//   if (Platform.isIOS) {
//     return bannerAndroid;
//   } else if (Platform.isAndroid) {
//     return bannerIOS;
//   }
//   return 'Platform Exception';
// }
//
// String get interstitalAd {
//   if (Platform.isIOS) {
//     return interstitialIOS;
//   } else if (Platform.isAndroid) {
//     return interstitialAndroid;
//   }
//   return 'Platform Exception';
// }
//
// class admobads {
//   /// Banner Ads
//
//   Widget bannerads() {
//     final googleBannerAd = BannerAd(
//       adUnitId: getBannerAdUnitId,
//       size: AdSize.banner,
//       listener: BannerAdListener(
//         onAdFailedToLoad: (ad, err) {
//           debugPrint('Hello onAdFailedToLoad ::::: $err');
//           ad.dispose();
//         },
//       ),
//       request: AdRequest(),
//     )..load();
//     return Container(
//       color: Colors.black12,
//       alignment: Alignment.center,
//       width: googleBannerAd.size.width.toDouble(),
//       height: googleBannerAd.size.height.toDouble(),
//       child: AdWidget(ad: googleBannerAd),
//     );
//   }
//
//   /// Interstitial Ads
//
//   int maxFailedLoadAttempts = 3;
//   int numInterstialAdLoadAttempt = 0;
//
//   static final AdRequest request = AdRequest(
//     keywords: ['foo', 'bar'],
//     contentUrl: 'http://foo.com/bar.html',
//     nonPersonalizedAds: true,
//   );
//
//   InterstitialAd? createInterstitialAd() {
//     try {
//       InterstitialAd.load(
//           adUnitId: interstitalAd,
//           request: request,
//           adLoadCallback: InterstitialAdLoadCallback(
//             onAdLoaded: (InterstitialAd ad) {
//               interstitialAd = ad;
//               maxFailedLoadAttempts = 0;
//               interstitialAd!.setImmersiveMode(true);
//             },
//             onAdFailedToLoad: (LoadAdError error) {
//               numInterstialAdLoadAttempt += 1;
//               if (numInterstialAdLoadAttempt < maxFailedLoadAttempts) {
//                 admobads().createInterstitialAd();
//               }
//             },
//           ));
//     } catch (e) {}
//     return null;
//   }
//
//   Future<void> showInterstitialAd(
//       {required NavigateType navigateType,
//       BuildContext? context,
//       int? id,
//       String? title,
//       int? pid,
//       String? pname,
//       required String path,
//       MusicType? type}) async {
//     if (interstitialAd == null) {
//       if (navigateType == NavigateType.music) {
//         await loader(context, songName: title!).whenComplete(
//             () => playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
//       } else {
//         Get.to(() => VideoPlayerScreen(link: path));
//       }
//       return;
//     }
//     interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
//         onAdShowedFullScreenContent: (InterstitialAd ad) {},
//         onAdDismissedFullScreenContent: (InterstitialAd ad) async {
//           if (navigateType == NavigateType.music) {
//             await loader(context, songName: title!).whenComplete(() =>
//                 playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
//           } else {
//             Get.to(() => VideoPlayerScreen(link: path));
//           }
//           ad.dispose();
//           createInterstitialAd();
//         },
//         onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) async {
//           if (navigateType == NavigateType.music) {
//             await loader(context, songName: title!).whenComplete(() =>
//                 playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
//           } else {
//             Get.to(() => VideoPlayerScreen(link: path));
//           }
//           ad.dispose();
//           createInterstitialAd();
//         },
//         onAdWillDismissFullScreenContent: (InterstitialAd ad) async {
//           // if (navigateType == NavigateType.music) {
//           //   await loader(context, songName: title!).whenComplete(() =>
//           //       playSong(id: id!, name: title, url: path).whenComplete(() => Get.to(() => PlayerScreen(musicType: type!, id: pid, name: pname))));
//           // } else {
//           //   Get.to(() => VideoPlayerScreen(link: path));
//           // }
//           // ad.dispose();
//           // createInterstitialAd();
//         });
//     interstitialAd!.show();
//     interstitialAd = null;
//   }
// }
