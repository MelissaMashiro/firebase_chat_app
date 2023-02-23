import 'package:firebase_chat_app/common/entities/entities.dart';
import 'package:get/get.dart';

//El state es como el state que maejabamos en abastible arriba de todo
class ChatState {

RxList<Msgcontent> msgcontentList = <Msgcontent>[].obs;

var to_uid =  "".obs;
var to_name = "".obs;
var to_avatar = "".obs;
var to_location = "unknown".obs;
  
}
