import 'package:firebase_chat_app/pages/message/chat/index.dart';
import 'package:firebase_chat_app/pages/profile/controller.dart';
 import 'package:get/get.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
