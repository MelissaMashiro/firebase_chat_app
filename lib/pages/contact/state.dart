import 'package:firebase_chat_app/common/entities/user.dart';
import 'package:get/get.dart';

//El state es como el state que maejabamos en abastible arriba de todo
class ContactState {
  var count = 0.obs;
  //Create a list similar to List<T>, pero esta e suna lista que es OBSRVABLE
  //esto viene con el paquete de getx
  RxList<UserData> contactList = <UserData>[].obs;
}
