import 'package:firebase_chat_app/common/values/colors.dart';
import 'package:firebase_chat_app/common/values/values.dart';
import 'package:firebase_chat_app/pages/application/index.dart';
import 'package:firebase_chat_app/pages/contact/view.dart';
 import 'package:flutter/material.dart';
import 'package:get/get.dart';

//Al extender este controller type, nos deja acceder al controller WelcomeController,
// sin tener que crear uno nuevo dentro de esta vista
class ApplicationPage extends GetView<ApplicationController> {
  const ApplicationPage({super.key});

  Widget _buildPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: controller.pageController,
      onPageChanged: controller.handlePageChanged,
      children: const [
        Center(
          child: Text("Chat"),
        ),
        ContactPage(),
        Center(
          child: Text("Profile"),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(
      () => BottomNavigationBar(
        items: controller.bottomTabs,
        currentIndex: controller.state.page,
        type: BottomNavigationBarType.fixed,
        onTap: controller.handleNavBarTap,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        unselectedItemColor: AppColors.tabBarElement,
        selectedItemColor: AppColors.thirdElementText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageView(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
