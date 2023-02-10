import 'package:firebase_chat_app/common/values/colors.dart';
import 'package:firebase_chat_app/common/values/values.dart';
import 'package:firebase_chat_app/common/widgets/app.dart';
 import 'package:firebase_chat_app/pages/contact/index.dart';
import 'package:firebase_chat_app/pages/contact/widgets/contact_list.dart';
 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//Al extender este controller type, nos deja acceder al controller WelcomeController,
// sin tener que crear uno nuevo dentro de esta vista
class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  AppBar _buildAppBar(){
    return transparentAppBar(
      title: Text(
        "Contact",
        style: TextStyle(
          color: AppColors.primaryBackground,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: const ContactList(),
    );
  }
}
