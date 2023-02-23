import 'package:firebase_chat_app/pages/message/chat/index.dart';
 import 'package:get/get.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
