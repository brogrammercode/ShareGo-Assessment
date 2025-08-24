// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shareit/core/config/theme/colors.dart';
import 'package:shareit/main.dart';

String timeAgo(DateTime dateTime) {
  final Duration diff = DateTime.now().difference(dateTime);

  if (diff.inSeconds < 60) {
    final secs = diff.inSeconds;
    return '$secs sec${secs == 1 ? '' : 's'}';
  } else if (diff.inMinutes < 60) {
    final mins = diff.inMinutes;
    return '$mins min${mins == 1 ? '' : 's'}';
  } else if (diff.inHours < 24) {
    final hours = diff.inHours;
    return '$hours hour${hours == 1 ? '' : 's'}';
  } else if (diff.inDays < 30) {
    final days = diff.inDays;
    return '$days day${days == 1 ? '' : 's'}';
  } else if (diff.inDays < 365) {
    final months = diff.inDays ~/ 30;
    return '$months month${months == 1 ? '' : 's'}';
  } else {
    final years = diff.inDays ~/ 365;
    return '$years year${years == 1 ? '' : 's'}';
  }
}

List<Widget> get commonEmpty {
  return [
    SizedBox(height: 200.h),
    CachedNetworkImage(
      height: 50.h,
      width: 50.h,
      fit: BoxFit.cover,
      imageUrl: "https://cdn-icons-png.flaticon.com/128/7486/7486760.png",
    ),
    SizedBox(height: 30.h),
    const Text(
      "It's quite in here...",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 10.h),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 70.w),
      child: Text(
        "You can explore our services, our trustworthy and professional useful features to get the best user experience.",
        style: Theme.of(navigatorKey.currentContext!).textTheme.bodyMedium!
            .copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    ),
  ];
}

List<Widget> get commonEmptySmall {
  return [
    CachedNetworkImage(
      height: 50.h,
      width: 50.h,
      fit: BoxFit.cover,
      imageUrl: "https://cdn-icons-png.flaticon.com/128/7486/7486760.png",
    ),
    SizedBox(height: 10.h),
    Text(
      "It's quite in here...",
      style: Theme.of(
        navigatorKey.currentContext!,
      ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
    ),
  ];
}

String? validationForEmpty({required String? value, String label = ""}) {
  if (value == null || value.isEmpty) {
    return "Please enter the $label";
  }
  return null;
}

class CommonTextFormField extends StatefulWidget {
  final EdgeInsetsGeometry? margin;
  final String labelText;
  final String? hintText;
  final TextEditingController controller;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool isEnabled;
  final TextInputType keyboardType;
  final IconData? suffixIcon;
  final void Function()? onTap;
  final String? Function(String?)? validator;

  const CommonTextFormField({
    super.key,
    this.margin,
    required this.labelText,
    this.hintText,
    required this.controller,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.isEnabled = true,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onTap,
    this.validator,
  });

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEmpty = widget.controller.text.isEmpty;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTap:
            widget.onTap ??
            () => FocusScope.of(context).requestFocus(_focusNode),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.labelText,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: widget.controller,
                              focusNode: _focusNode,
                              enabled: widget.isEnabled && widget.onTap == null,
                              maxLines: widget.maxLines,
                              minLines: widget.minLines,
                              maxLength: widget.maxLength,
                              keyboardType: widget.keyboardType,
                              validator: widget.validator,
                              onTap: widget.onTap,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                isCollapsed: true,
                                hintText: isEmpty ? widget.hintText : null,
                                hintStyle: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade400,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                  right: widget.suffixIcon != null ? 40.w : 0,
                                ),
                              ),
                            ),
                          ),
                          if (widget.suffixIcon != null) ...[
                            SizedBox(width: 20.w),
                            Icon(widget.suffixIcon, size: 20.r),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<DateTime?> pickDate({
  DateTime? initialDate,
  DateTime? lastDate,
  DateTime? firstDate,
}) async {
  final now = DateTime.now();
  return await showDatePicker(
    context: navigatorKey.currentContext!,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? DateTime(1900),
    lastDate: lastDate ?? now,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            backgroundColor: Colors.white,
            headerHeadlineStyle: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            headerHelpStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
            dividerColor: Colors.grey.withOpacity(.2),
            dayStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            weekdayStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            yearStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            rangePickerHeaderHeadlineStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            rangePickerHeaderHelpStyle: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            confirmButtonStyle: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.r),
                side: BorderSide(color: Colors.grey.withOpacity(.2)),
              ),
            ),
            cancelButtonStyle: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
        child: child!,
      );
    },
  );
}

class CommonFloatingActionButton extends StatelessWidget {
  final void Function() onPressed;
  final IconData icon;
  final bool loading;
  const CommonFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: FloatingActionButton(
        onPressed: onPressed,
        shape: const CircleBorder(),
        foregroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(1),
        child: loading
            ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.sp)
            : Icon(icon, color: Colors.white),
      ),
    );
  }
}

Future<void> openPopUp({
  required BuildContext context,
  required String? networkImage,
  required File? profileImage,
}) async {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          children: [
            // Blur background
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                // color: Colors.black.withOpacity(0.2),
              ),
            ),
            // Circular image
            if (networkImage != null) ...[
              Center(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: networkImage,
                    placeholder: (context, url) => CircularProgressIndicator(
                      strokeWidth: 1,
                      color: Colors.black.withOpacity(.1),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ] else if (profileImage != null) ...[
              Center(
                child: ClipOval(
                  child: Image.file(
                    profileImage,
                    width: 300,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

void showSnack({
  BuildContext? context,
  Color backgroundColor = Colors.green,
  required String text,
  bool sticky = false,
}) {
  final BuildContext? buildContext = context ?? navigatorKey.currentContext;

  if (buildContext == null) {
    debugPrint("❌ ERROR: No valid context found for Snackbar!");
    return;
  }

  ScaffoldMessenger.of(buildContext).clearSnackBars();
  ScaffoldMessenger.of(buildContext)
    ..hideCurrentSnackBar()
    ..showSnackBar(
    SnackBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      padding: EdgeInsets.zero,
      duration: sticky ? const Duration(days: 365) : const Duration(seconds: 3),
      content: Container(
        height: 30.h,
        alignment: Alignment.center,
        child: Center(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(buildContext).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

void clearAllSnack({BuildContext? context}) {
  final BuildContext? buildContext = context ?? navigatorKey.currentContext;

  if (buildContext == null) {
    debugPrint("❌ ERROR: No valid context found to clear SnackBars!");
    return;
  }

  ScaffoldMessenger.of(buildContext).clearSnackBars();
}

Future<T?> openBottomSheet<T>({
  Widget child = const SizedBox(),
  double minChildSize = 0.25,
  double initialChildSize = 0.5,
  double maxChildSize = 0.9,
}) async {
  final BuildContext context = navigatorKey.currentContext!;
  return await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8.h),
                  Container(
                    height: 4.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: child,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

InkWell bottomSheetTile({
  required BuildContext context,
  required IconData icon,
  IconData? actionIcon,
  required String title,
  required String subtitle,
  required void Function() onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (actionIcon != null) ...[SizedBox(width: 20.w), Icon(actionIcon)],
        ],
      ),
    ),
  );
}

void openStatusBottomSheet({
  required BuildContext context,
  double minChildSize = 0.1,
  double initialChildSize = 0.15,
  double maxChildSize = 0.9,
  required String title,
  String subtitle = "",
  IconData icon = CupertinoIcons.check_mark,
  Color color = AppColors.green600,
  String primaryButtonText = "",
  String secondaryButtonText = "",
  bool loading = false,
  required Function() onPrimaryTap,
}) {
  showModalBottomSheet(
    context: context,
    isDismissible: !loading,
    isScrollControlled: true,
    enableDrag: !loading,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async {
          if (loading) {
            return false;
          } else {
            return true;
          }
        },
        child: DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: AbsorbPointer(
                absorbing: loading,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 8.h),
                      Container(
                        height: 4.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                  child: loading
                                      ? SizedBox(
                                          height: 15.r,
                                          width: 15.r,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                        )
                                      : Icon(
                                          icon,
                                          color: Colors.white,
                                          size: 15.r,
                                        ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
