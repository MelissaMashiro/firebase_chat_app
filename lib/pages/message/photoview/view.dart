import 'package:firebase_chat_app/common/values/colors.dart';
import 'package:firebase_chat_app/pages/message/photoview/controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoImageViewPage extends GetView<PhotoImageViewController> {
  const PhotoImageViewPage({super.key});

  AppBar _buildAppbar() {
    return AppBar(
      bottom: PreferredSize(
        child: Container(
          color: AppColors.secondaryElement,
          height: 2.0,
        ),
        preferredSize: Size.fromHeight(1.0),
      ),
      title: Text(
        "Photoview",
        style: TextStyle(
          color: AppColors.primaryText,
          fontSize: 16.0.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(controller.state.url.value),
        ),
      ),
    );
  }
}
