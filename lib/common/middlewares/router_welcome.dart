import 'package:flutter/material.dart';
import 'package:firebase_chat_app/common/routes/routes.dart';
import 'package:firebase_chat_app/common/store/store.dart';

import 'package:get/get.dart';

/// First Time open
class RouteWelcomeMiddleware extends GetMiddleware {
  // priority the smaller the more important
  @override
  int? priority = 0;

  RouteWelcomeMiddleware({required this.priority});

  @override
  RouteSettings? redirect(String? route) {
    print(ConfigStore.to.isFirstOpen);
    if (ConfigStore.to.isFirstOpen == false) {
                  print('ES PRIMERA VEZ LOGUEANDO--->');

      return null;
    } else if (UserStore.to.isLogin == true) {
      print('YA HA LOGUEADO--->');
      return const RouteSettings(name: AppRoutes.Application);
    } else {
            print('NO HA LOGUEADO--->');

      return const RouteSettings(name: AppRoutes.SIGN_IN);
    }
  }
}
