import 'dart:convert';

import 'package:firebase_chat_app/common/entities/entities.dart';
import 'package:firebase_chat_app/common/store/store.dart';
import 'package:get/get.dart';
import 'index.dart ';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactController extends GetxController {
  final state = ContactState();
  ContactController();
  final db = FirebaseFirestore.instance;
  final token = UserStore.to.token;

//este metodo de ready y los de init, no los llamo yo manualmente, s ellaman solos al inicializarse el controller
  @override
  void onReady() {
    super.onReady();
    print('on ready de contact list--->');
    asyncLoadAllData();
  }

  asyncLoadAllData() async {
    print('cargando users--->');
    var userbase = await db
        .collection("users")
        .where("id",
            isNotEqualTo:
                token) //tomando todos los usuarios del datastore, menos el usuario actual
        .withConverter(
          fromFirestore: UserData.fromFirestore,
          toFirestore: (UserData userData, options) => userData.toFirestore(),
        )
        .get();
    print('useers obtenidos --> ${userbase.docs}');

//obteniendo los perfiles de los contactos. y agregandolos a una lista observable
    for (var doc in userbase.docs) {
      print('NUMERO DE USUARIOS REGISTRADOS--->${userbase.docs.length}');
      state.contactList.add(doc.data());
      print(doc.toString());
    }
  }

  goChat(UserData to_userdata) async {
//Si tenemos mensajes previos (conversacion ya habia iniciado)------------------------------------------------>
    //ESTE SE USA SI MI PERSONA ES LA QUE INICIÓ NUESTRA  CONVERSACION (mmno)
    //con esto obtengo todos los mensajes que yo envié (para mi yo soy siempre el from user)
    var from_messages = await db
        .collection("message")
        .withConverter(
          fromFirestore: Msg
              .fromFirestore, //convierte el  json de firebase al objeto de message
          toFirestore: (Msg msg, options) => msg
              .toFirestore(), //convierte el objeto mesage al json para enviar a firebase
        )
        .where(
          "from_uid",
          isEqualTo:
              token, //le digo que el 'from' user sera el usuario con mi token(osea yo)
        )
        .where("to_uid",
            isEqualTo: to_userdata
                .id) //el 'to' user será el usuario al que va el mensaje
        .get();

    //ESTE SE USA SI LA OTRA PERSONA ES LA QUE INICIÓ NUESTRA  CONVERSACION
//con esto obtengo los mensajes que me envió el otro. (para mi, el siempre sera el 'to' user)
    var to_messages = await db
        .collection("message")
        .withConverter(
          fromFirestore: Msg
              .fromFirestore, //convierte el  json de firebase al objeto de message
          toFirestore: (Msg msg, options) => msg
              .toFirestore(), //convierte el objeto mesage al json para enviar a firebase
        )
        .where(
          "from_uid",
          isEqualTo: to_userdata
              .id, //le digo que el 'from' user sera el usuario al q le escribo
        )
        .where("to_uid", isEqualTo: token) //el 'to' user será mi usuario
        .get();
//<---------------------------------------------------------------------------------------

//Para iniciar el chat por primera vez---------------------------------------->

    if (from_messages.docs.isEmpty && to_messages.docs.isEmpty) {
      //si ninguno ha iniciado el chat aun:
      //Yo sere la 'from' user.
      String profile =
          await UserStore.to.getProfile(); //obtiene los datos en forma de json
      UserLoginResponseEntity userdata = UserLoginResponseEntity.fromJson(
          jsonDecode(profile)); //convierte los datos a objeto
      var msgdata = Msg(
        from_uid: userdata.accessToken,
        to_uid: to_userdata.id,
        from_name: userdata.displayName,
        to_name: to_userdata.name,
        from_avatar: userdata.photoUrl,
        to_avatar: to_userdata.photourl,
        last_msg: "",
        last_time: Timestamp.now(),
        msg_num:
            0, //si llego hasta aca es porque aun hay cero mensajes en el chat
      );

//apenas entre al chat, se creara el document entre esa persona y yo.
      db
          .collection("message")
          .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore(),
          )
          .add(msgdata)
          .then((value) {
        //value es el document creado
        Get.toNamed("/chat", parameters: {
          "doc_id":
              value.id, //el document del chat mio y de esa persona (unico)
          "to_uid": to_userdata.id ?? "",
          "to_name": to_userdata.name ?? "",
          "to_avatar": to_userdata.photourl ?? "",
        });
      });
    } else {
      //Si la conversacion no sta vacia:
      if (from_messages.docs.isNotEmpty) {
        Get.toNamed("/chat", parameters: {
          "doc_id": from_messages.docs.first.id,
          "to_uid": to_userdata.id ?? "",
          "to_name": to_userdata.name ?? "",
          "to_avatar": to_userdata.photourl ?? "",
        });
      }

      if (to_messages.docs.isNotEmpty) {
        Get.toNamed("/chat", parameters: {
          "doc_id": to_messages.docs.first.id,
          "to_uid": to_userdata.id ?? "",
          "to_name": to_userdata.name ?? "",
          "to_avatar": to_userdata.photourl ?? "",
        });
      }
    }
  }
}
