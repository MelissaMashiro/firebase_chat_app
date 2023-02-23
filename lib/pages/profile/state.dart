import 'package:firebase_chat_app/common/entities/entities.dart';
import 'package:get/get.dart';

//El state es como el state que maejabamos en abastible arriba de todo
class ProfileState {

var  head_detail = Rx<UserLoginResponseEntity?>(null);
RxList<MeListItem> meListItem = <MeListItem>[].obs;
  
}
