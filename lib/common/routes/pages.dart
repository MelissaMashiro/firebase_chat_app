import 'package:firebase_chat_app/common/middlewares/middlewares.dart';
import 'package:firebase_chat_app/pages/message/chat/index.dart';
import 'package:firebase_chat_app/pages/contact/index.dart';
import 'package:firebase_chat_app/pages/application/index.dart';
import 'package:firebase_chat_app/pages/message/photoview/index.dart';
import 'package:firebase_chat_app/pages/profile/index.dart';
import 'package:firebase_chat_app/pages/sign_in/index.dart';
import 'package:firebase_chat_app/pages/welcome/index.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static const APPlication = AppRoutes.Application;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
      middlewares: [
        RouteWelcomeMiddleware(priority: 1),
      ],
    ),
    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),

    // check if needed to login or not
    GetPage(
      name: AppRoutes.Application,
      page: () => const ApplicationPage(),
      binding: ApplicationBinding(),
      middlewares: [
        // RouteAuthMiddleware(priority: 1),
      ],
    ),

    // 最新路由
    // 首页
    GetPage(
      name: AppRoutes.Contact,
      page: () => const ContactPage(),
      binding: ContactBinding(),
    ),

    //聊天详情
    GetPage(
      name: AppRoutes.Chat,
      page: () => const ChatPage(),
      binding: ChatBinding(),
    ),

    /*
    //消息
    GetPage(
        name: AppRoutes.Message,
        page: () => MessagePage(),
        binding: MessageBinding()),
    */
    //我的
    GetPage(
        name: AppRoutes.Me,
        page: () => ProfilePage(),
        binding: ProfileBinding()),

    GetPage(
      name: AppRoutes.Photoimgview,
      page: () => PhotoImageViewPage(),
      binding: PhotoImageViewBinding(),
    ),
  ];
}
