import 'package:firebase_chat_app/pages/application/index.dart';
import 'package:firebase_chat_app/pages/contact/controller.dart';
 import 'package:get/get.dart';

class ApplicationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApplicationController>(() => ApplicationController());
    //aca tambien se inicializa el de contact, ya que esa vista s eusa dentro de esta. Si no se hace esto da error
    Get.lazyPut<ContactController>(() => ContactController());
  }
}
