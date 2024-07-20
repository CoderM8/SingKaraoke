import 'package:get/get.dart';

class MyRecordingController extends GetxController with GetSingleTickerProviderStateMixin {
  // RxInt tabIndex = 0.obs;
  // TabController? tabController;
  final RxBool isRefresh = false.obs;

  @override
  void onInit() {
    // tabController = TabController(length: 2, vsync: this);
    // tabController!.index = 0;
    // tabController!.addListener(smoothScrollToTop);
    super.onInit();
  }

  // smoothScrollToTop() {
  //   tabIndex.value = tabController!.index;
  // }
}