import 'package:firebase_chat_app/common/entities/entities.dart';
import 'package:firebase_chat_app/common/routes/routes.dart';
import 'package:firebase_chat_app/common/store/store.dart';
import 'package:firebase_chat_app/common/widgets/toast.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'index.dart ';

class SignInController extends GetxController {
  static SignInController get to => Get.find();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'openid',
    ],
  );

  final state = SignInState();
  SignInController();

  final db = FirebaseFirestore.instance;

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

//si ingresas con google, creara tu usuario en firebase con esa data de google,
//si entras con facebook igual pero con la data de facebook
//Si tu cuenta de facebook y google usan el mismo email, solo te dejara logear con una de esas dos cuentas(la rpimera q uses)
  Future<void> handleSignIn(String type) async {
    try {
      if (type == 'google') {
        var user = await _googleSignIn.signIn();
        if (user != null) {
          final gAuthentication = await user.authentication;

          final credential = GoogleAuthProvider.credential(
            idToken: gAuthentication.idToken,
            accessToken: gAuthentication.accessToken,
          );

          await FirebaseAuth.instance.signInWithCredential(credential);

          String displayName = user.displayName ?? user.email;
          String email = user.email;
          String id = user.id;
          String photoUrl = user.photoUrl ?? "";
          UserLoginResponseEntity userProfile = UserLoginResponseEntity();
          userProfile.email = email;
          userProfile.accessToken = id;
          userProfile.displayName = displayName;
          userProfile.photoUrl = photoUrl;
          userProfile.type = "google";

          UserStore.to.saveProfile(userProfile);
          var userbase = await db
              .collection("users")
              .withConverter(
                fromFirestore: UserData.fromFirestore,
                toFirestore: (UserData userdata, option) =>
                    userdata.toFirestore(),
              )
              .where("id", isEqualTo: id)
              .get();

          if (userbase.docs.isEmpty) {
            final data = UserData(
              id: id,
              name: displayName,
              photourl: photoUrl,
              location: "",
              fcmtoken: "",
              addtime: Timestamp.now(),
            );
            //saving new data inuser found
            await db
                .collection("users")
                .withConverter(
                  fromFirestore: UserData.fromFirestore,
                  toFirestore: (UserData userdata, option) =>
                      userdata.toFirestore(),
                )
                .add(data);
          }
          toastInfo(
              msg:
                  "login success"); //un plugin instalado para mostrar esots mensajes
          Get.offAndToNamed(AppRoutes.Application);
        }
      } else {
        var auth = await signInWithFacebook();
        if (auth.user != null) {
          final user = auth.user;

          String? displayName = user?.displayName;
          String? email = user?.email;
          String? id = user?.uid; //en facebook este id se llama  uid
          String? photoUrl = user?.photoURL ?? "";
          UserLoginResponseEntity userProfile = UserLoginResponseEntity();
          userProfile.email = email;
          userProfile.accessToken = id;
          userProfile.displayName = displayName;
          userProfile.photoUrl = photoUrl;
          userProfile.type = "facebook";

          UserStore.to.saveProfile(userProfile);
          var userbase = await db
              .collection("users")
              .withConverter(
                fromFirestore: UserData.fromFirestore,
                toFirestore: (UserData userdata, option) =>
                    userdata.toFirestore(),
              )
              .where("id", isEqualTo: id)
              .get();

          if (userbase.docs.isEmpty) {
            final data = UserData(
              id: id,
              name: displayName,
              photourl: photoUrl,
              location: "",
              fcmtoken: "",
              addtime: Timestamp.now(),
            );
            //saving new data inuser found
            await db
                .collection("users")
                .withConverter(
                  fromFirestore: UserData.fromFirestore,
                  toFirestore: (UserData userdata, option) =>
                      userdata.toFirestore(),
                )
                .add(data);
          }
          toastInfo(
              msg:
                  "login success"); //un plugin instalado para mostrar esots mensajes
          Get.offAndToNamed(AppRoutes.Application);
        }
      }
    } catch (e) {
      toastInfo(msg: "login error");

      print(e);
    }
  }

  @override
  void onReady() {
    super.onReady();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print("User is currently logged out");
      } else {
        print("User is logged in");
      }
    });
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
