// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shareit/core/config/routes/routes.dart';
import 'package:shareit/core/utils/assets.dart';
import 'package:shareit/core/utils/common.dart';

class UserConfigPage extends StatefulWidget {
  const UserConfigPage({super.key});

  @override
  State<UserConfigPage> createState() => _UserConfigPageState();
}

class _UserConfigPageState extends State<UserConfigPage> {
  final TextEditingController _username = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 150.h,
              width: 150.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: NetworkImagePath.onboardingAvatar,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.w),
            child: CommonTextFormField(
              labelText: "Username",
              controller: _username,
            ),
          ),
          SizedBox(height: 30.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 60.w),
            child: ElevatedButton(
              onPressed: _onContinuePressed,
              child: Text(
                "Continue",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onContinuePressed() {
    Navigator.pushNamed(context, AppRoutes.shareMain);
  }
}
