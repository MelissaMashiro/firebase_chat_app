import 'package:firebase_chat_app/pages/chat/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//Al extender este controller type, nos deja acceder al controller WelcomeController,
// sin tener que crear uno nuevo dentro de esta vista
class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
