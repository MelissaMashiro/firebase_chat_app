 import 'package:firebase_chat_app/common/values/values.dart';
import 'package:firebase_chat_app/common/widgets/button.dart';
import 'package:firebase_chat_app/pages/sign_in/index.dart';
 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//Al extender este controller type, nos deja acceder al controller WelcomeController,
// sin tener que crear uno nuevo dentro de esta vista
class SignInPage extends GetView<SignInController> {
  const SignInPage({super.key});

  Widget _buildLogo() {
    return Container(
      width: 110.w,
      margin: EdgeInsets.only(top: 84.h),
      child: Column(
        children: [
          Container(
            height: 76.w,
            width: 76.w,
            margin: EdgeInsets.symmetric(horizontal: 15.w),
            child: Stack(
              children: [
                Positioned(
                  child: Container(
                    height: 76.h,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBackground,
                      boxShadow: [
                        Shadows.primaryShadow,
                      ],
                      borderRadius: BorderRadius.all(
                        Radius.circular(35),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  child: Image.asset(
                    "assets/images/ic_launcher.png",
                    width: 76.w,
                    height: 76.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
              top: 15.h,
              bottom: 15.h,
            ),
            child: Text(
              "Let's chat!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.thirdElement,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
                height: 1,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThirdPartyLogin() {
    return Container(
      margin: const EdgeInsets.only(bottom: 280.0),
      width: 295.w,
      child: Column(
        children: [
          Text(
            "Sign in with social networks",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 30.h,
              left: 50.w,
              right: 50.w,
            ),
            child: btnFlatButtonWidget(
              onPressed: () {
                controller.handleSignIn();
              },
              height: 55.h,
              title: "Google Login",
              width: 200.w,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            _buildLogo(),
            Spacer(),
            _buildThirdPartyLogin(),
          ],
        ),
      ),
    );
  }
}
