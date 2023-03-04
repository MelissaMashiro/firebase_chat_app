import 'dart:io';

import 'index.dart ';
import 'package:firebase_chat_app/common/entities/entities.dart';
import 'package:firebase_chat_app/common/store/store.dart';
import 'package:firebase_chat_app/common/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final state = ChatState();
  ChatController();

  var doc_id = null;
  final textController = TextEditingController();
  ScrollController msgScrolling = ScrollController();
  FocusNode contentNode = FocusNode();
  final user_id = UserStore.to.token;
  final db = FirebaseFirestore.instance;
  var listener;
  var user_profile = UserStore.to.profile;

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      //Enviar imagena  firebase
      await uploadFile();
    } else {
      print("No image selected");
    }
  }

  Future _getImageUrl(String name) async {
    final spaceRef = FirebaseStorage.instance.ref("chat").child(name);
    //.getDownloadUrl es una url qwue genera firebase para poder usar la imagen que fue almacenada alli.
    var str = await spaceRef.getDownloadURL();
    return str;
  }

  sendImageMessage(String url) async {
    final content = Msgcontent(
      uid: user_id,
      content: url,
      type: "image",
      addtime: Timestamp.now(),
    );

    await db
        .collection("message")
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .add(content)
        .then((DocumentReference doc) {
      print("Document snapshot added with id,  ${doc.id}");
      textController.clear();
      Get.focusScope?.unfocus();
    });

    await db.collection("message").doc(doc_id).update(
      {
        "last_msg": "【image】",
        "last_time": Timestamp.now(),
      },
    );
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = getRandomString(15) + extension(_photo!.path);
    print('My name is ---> $fileName');
    try {
      //This "chat" instance is a new firebase 'Storage' instance.(diferent to the 'Firebase Databse' instance that we had)

//.ref crea un folder en firebase.
//.child crea el un archivo(copia) de la imaggen en firebase
      final ref = FirebaseStorage.instance.ref("chat").child(fileName);
      //ref ahora mismo es un objeto que tiene la locacion del archivo recien creado en  firebase apra guardar la imagen
      //con putFile lo subimos a ese objeto en firebase
      ref.putFile(_photo!).snapshotEvents.listen((event) async {
        //escuchamos al storage de firebase (folder '/chat') para ver si la iamgen se subió correctamente
        switch (event.state) {
          case TaskState.running:
            break;
          case TaskState.paused:
            break;
          case TaskState.success:
            //si la imagen se subio correctamente, enviamos/creamos el mensaje
            String imgUrl = await _getImageUrl(fileName);
            sendImageMessage(imgUrl);
            break;
          default:
        }
      });
    } catch (e) {
      print("There's an error $e");
    }
  }

  @override
  void onInit() {
    super.onInit();
    //Al cargar este cotroller, se actualizara con la data recibida de los argumentos
    // del get.pushnamed que lo trajo ahsta esta pantalla de chat.
    var data = Get.parameters;
    doc_id = data['doc_id'];
    state.to_uid.value = data['to_uid'] ?? "";
    state.to_name.value = data['to_name'] ?? "";
    state.to_avatar.value = data['to_avatar'] ?? "";
  }

  sendMessage() async {
    String sendContent = textController.text;
    final content = Msgcontent(
      uid: user_id,
      content: sendContent,
      type: "text",
      addtime: Timestamp.now(),
    );

//Para que todos los mensajes enviados se manden a la misma coleccion de este chat:
//creando nuevos records(documents) para la coleccion 'msglist'
    await db
        .collection("message")
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .add(content)
        .then((DocumentReference doc) {
      print("Document snapshot added with id,  ${doc.id}");
      textController.clear();
      Get.focusScope?.unfocus();
    });

    if (doc_id == null) {
      print("dommed...");
    }
    await db.collection("message").doc(doc_id).update(
      {
        "last_msg": sendContent,
        "last_time": Timestamp.now(),
      },
    );

    //notfiication message stuffs
    await db.collection("message").doc(doc_id).update({
      "last_msg": sendContent,
      "last_time": Timestamp.now(),
    });

//getting all the informationof the user we are sending messages to
//Actually this usually sneding notirficactionshoudmbwe done on backend,
// but we dont have backend on this implementation.
    var userbase = await db
        .collection("users")
        .withConverter(
          fromFirestore: UserData.fromFirestore,
          toFirestore: (UserData userData, options) => userData.toFirestore(),
        )
        .where("id", isEqualTo: state.to_uid.value)
        .get();

    if (userbase.docs.isNotEmpty) {
      var title = "Message send by ${user_profile.displayName} (me)";
      var body = sendContent;
      var token = userbase.docs.first.data().fcmtoken;
      if (token != null) {
        sendNotification(title, body, token);
      }
    }
  }

  Future<void> sendNotification(
    String title,
    String bodyMsg,
    String token,
  ) async {
    const String url = "https://fcm.googleapis.com/fcm/send";

    var notification = '{'
        '"notification": '
        '{'
        '"body":"$bodyMsg",'
        '"title": "${title}",'
        '"content_available":"true"'
        '},'
        '"priority": "high",'
        '"to": "$token",'
        '"data":' //Data necesaria para abrir el chat correpsondiente desde la notificacion
        '{'
        '"to_uid":"${user_id}",'
        '"doc_id":"${doc_id}",' //doc_id del usuario al q va el mensaje
        '"to_name": "${user_profile.displayName}",'
        '"to_avatar":"${user_profile.photoUrl}"'
        '},'
        '}';

    /* var notification2 = '{ "notification": {"body":"$bodyMsg",'
        '"title": "${title}",'
        '"content_available":"true"},'
        '"priority": "high",'
        '"to": "$token"'
        '}';
        */

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'keep-Alive': 'timeout = 5',
        'Authorization':
            'key=AAAAQwP61A4:APA91bGqKd4iYcou3GbHB9yDruVfhfJjTQpaUFRLpaC5Sh2rLvtKNHpfmgGv0SmEQyx7iP-Ib8k0XDo24peCLXA0o0zgRNFsY6WljFH-GjdmSlk7cPzdUOaTJ-SRe3mltF6aLqmOq05R',
      },
      body: notification,
    );
    print(response.body);
  }

  @override
  Future<void> onReady() async {
    super.onReady();

//obteniendo todoslos mensjes de ese chat
    var messages = db
        .collection("message")
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .orderBy(
          "addtime",
          descending: false,
        );

    state.msgcontentList.clear();

    //Escuchando todos los cambios en el chat/conversacion/document

    listener = messages.snapshots().listen(
      (event) {
        print("current data: ${event.docs}");
        print("current data1: ${event.metadata.hasPendingWrites}");
        for (var change in event.docChanges) {
          switch (change.type) {
            //AL añadir nueva data(mensaje)
            case DocumentChangeType.added:
              //Si el mensaje no es vacio, agregalo a la lista local
              if (change.doc.data() != null) {
                state.msgcontentList.insert(0, change.doc.data()!);
              }
              break;
            //If data have been modify
            case DocumentChangeType.modified:
              break;
            //If data have been removed
            case DocumentChangeType.removed:
              break;
          }
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );

    await getLocation();
  }

//obtener la info de locacion de la OTRA persona con la que tengo el chat
  getLocation() async {
    try {
      print('Getting othr person location--->');
      print('ID PERSONAA BUSCAR: ${state.to_uid.value}');
      var userInfo = await db
          .collection("users")
          .where("id", isEqualTo: state.to_uid.value)
          .withConverter(
              fromFirestore: UserData.fromFirestore,
              toFirestore: (UserData userData, options) =>
                  userData.toFirestore())
          .get();

      print('user traido--->$userInfo');
      var userlocation3 = userInfo.docs;
      print('DATA--->$userlocation3');

      var userlocation = userInfo.docs.first.data().location;
      print("locacion ed la otra persona es---> $userlocation");

      if (userlocation != "") {
        state.to_location.value = userlocation ?? "Unknown";
      }
    } catch (e) {
      print("We have error $e");
    }
  }

  @override
  void dispose() {
    msgScrolling.dispose();
    listener.cancel();
    super.dispose();
  }
}
