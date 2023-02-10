import 'package:firebase_chat_app/common/routes/routes.dart';
import 'package:firebase_chat_app/common/store/store.dart';
import 'package:firebase_chat_app/pages/welcome/state.dart';
import 'package:get/get.dart';

class WelcomeController extends GetxController {
  final state = WelcomeState();
  WelcomeController();
  changePage(int index) {
    state.index.value = index;
  }

  handleSignIn() async {
    //remember that our app has been open (by saving a bool variable to true if the user already join for first time to the app)
     
    await ConfigStore.to.saveAlreadyOpen(); 
    Get.offAndToNamed(AppRoutes.SIGN_IN);
  }
}
