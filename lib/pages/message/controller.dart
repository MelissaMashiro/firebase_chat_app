import 'package:firebase_chat_app/common/entities/entities.dart';
import 'package:firebase_chat_app/common/store/store.dart';
import 'package:firebase_chat_app/common/utils/http.dart';
import 'package:firebase_chat_app/pages/message/state.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:location/location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageController extends GetxController {
  MessageController();

  final token = UserStore.to.token;
  final db = FirebaseFirestore.instance;
  final MessageState state = MessageState();

  var listener;

  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );

  @override
  void onReady() {
    super.onReady();
    print('ON READY MESSAGE CONTROLLER--->');
    getUserLocation();
    getFcmToken();
  }

  void onRefresh() {
    asyncLoadAllData().then((_) {
      // useing a refresh package
      refreshController.refreshCompleted(resetFooterState: true);
    }).catchError((_) {
      refreshController.loadFailed();
    });
  }

  void onLoading() {
    asyncLoadAllData().then((_) {
      // useing a refresh package
      refreshController.refreshCompleted(resetFooterState: true);
    }).catchError((_) {
      refreshController.loadFailed();
    });
  }

//to load all the data from firebase
  asyncLoadAllData() async {
    var from_messages = await db
        .collection("message")
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where(
          "from_uid",
          isEqualTo: token,
        )
        .get();

    var to_messages = await db
        .collection("message")
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where(
          "to_uid",
          isEqualTo: token,
        )
        .get();

    state.msgList.clear();
    if (from_messages.docs.isNotEmpty) {
      state.msgList.assignAll(from_messages.docs);
    }

    if (to_messages.docs.isNotEmpty) {
      state.msgList.assignAll(to_messages.docs);
    }
  }

//Guarda lad ata de locacion de el usuario que esta usando la app (yo)
  getUserLocation() async {
    try {
      print('Getting MY location--->');
      final location = await Location().getLocation();
      String address = "${location.latitude},${location.longitude}";
      print('my lcation is --->$address');
      String url =
          "https://maps.googleapis.com/maps/api/geocode/json?latlng=$address&key=AIzaSyDehNrwOAdYQUSlszONRSxfl_C6Gpe-ZoU";
      //custom request made with http and dio
      var response = await HttpUtil().get(url);
      MyLocation location_res = MyLocation.fromJson(response);
      print('location status is --->${location_res.status}');
      if (location_res.status == "OK") {
        print('mi loacion traida bien --->');
        String? myaddress = location_res.results?.first.formattedAddress;
        if (myaddress != null) {
          print('mi locacion es --->$myaddress');
          var user_location =
              await db.collection("users").where("id", isEqualTo: token).get();
          if (user_location.docs.isNotEmpty) {
            var doc_id = user_location.docs.first.id;
            //Updating collection with user location info
            await db
                .collection("users")
                .doc(doc_id)
                .update({"location": myaddress});
          }
        }
      }
    } catch (e) {
      print("Getting error ${e.toString()}");
    }
  }

//update user token
//fcm=firebase cloud message
//This token is very important for notifications
  getFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();

    if (fcmToken != null) {
      var user =
          await db.collection("users").where("id", isEqualTo: token).get();
      if (user.docs.isNotEmpty) {
        var doc_id = user.docs.first.id;
        await db.collection("users").doc(doc_id).update({"fcmtoken": fcmToken});
      }
    }
  }
}
