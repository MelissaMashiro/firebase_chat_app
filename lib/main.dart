import 'package:firebase_chat_app/common/routes/pages.dart';
import 'package:firebase_chat_app/common/services/storage.dart';
import 'package:firebase_chat_app/common/store/store.dart';
import 'package:firebase_chat_app/common/utils/notification_helper.dart';
import 'package:firebase_chat_app/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  print(
      '---> on background: ${message.notification?.title} ${message.notification?.body}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

//injectando dependencias
//Initializing the localStorage.
  await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<ConfigStore>(ConfigStore());
  Get.put<UserStore>(UserStore());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.getInitialMessage();
  try {
    await NotificationHelper.initialize();
    //this very important to listen notifications in background
    FirebaseMessaging.onBackgroundMessage(myBackgroundMessageHandler);
  } catch (e) {
    print("could not init --->$e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) => GetMaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
        // home: Container(child: const Text('Prpject started')),
      ),
    );
  }
}
