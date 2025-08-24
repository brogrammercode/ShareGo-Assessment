import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shareit/core/utils/assets.dart';
import 'package:shareit/core/utils/common.dart';
import 'package:shareit/features/share/data/models/device_info_model.dart';
import 'package:shareit/features/share/data/models/file_info_model.dart';
import 'package:shareit/features/share/presentation/cubit/share_cubit.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShareCubit, ShareState>(
      builder: (context, state) {
        return Scaffold(
          appBar: _appBar(context),
          bottomNavigationBar: _bottomNavigationBar(
            context: context,
            onTap: state.selectedFiles.isEmpty
                ? null
                : () => _sendFile(
                    context: context,
                    devices: state.discoveredDevices,
                  ),
          ),
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sendTile(
                    context: context,
                    label: 'Images',
                    imagePath: NetworkImagePath.imageImage,
                    onTap: () => context.read<ShareCubit>().selectImages(),
                  ),
                  _sendTile(
                    context: context,
                    label: 'Videos',
                    imagePath: NetworkImagePath.videoImage,
                    onTap: () => context.read<ShareCubit>().selectVideos(),
                  ),
                  _sendTile(
                    context: context,
                    label: 'Files',
                    imagePath: NetworkImagePath.fileImage,
                    onTap: () => context.read<ShareCubit>().selectFiles(),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              Expanded(
                child: ListView.builder(
                  itemCount: state.selectedFiles.length,
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final file = state.selectedFiles[index];
                    return _fileItem(context: context, file: file);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(
        'Send Files',
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  _sendTile({
    required BuildContext context,
    required String label,
    required String imagePath,
    required void Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Image.network(imagePath, height: 40.h, fit: BoxFit.contain),
            SizedBox(height: 10.h),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  _fileItem({required BuildContext context, required FileInfo file}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.w,
            backgroundColor: file.isImage
                ? Colors.blue.shade100
                : file.isVideo
                ? Colors.red.shade100
                : Colors.green.shade100,
            child: Icon(
              file.isImage
                  ? Icons.image
                  : file.isVideo
                  ? Icons.videocam
                  : Icons.insert_drive_file,
              color: file.isImage
                  ? Colors.blue
                  : file.isVideo
                  ? Colors.red
                  : Colors.green,
              size: 20.r,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${file.formattedSize} • ${file.type.toUpperCase()}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          SizedBox(width: 20.w),
          IconButton(
            onPressed: () => context.read<ShareCubit>().removeFile(file.id),
            icon: Icon(Icons.remove, color: Colors.red),
          ),
        ],
      ),
    );
  }

  _bottomNavigationBar({
    required BuildContext context,
    void Function()? onTap,
  }) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(color: Colors.white),
        child: onTap != null
            ? ElevatedButton(
                onPressed: onTap,
                child: Text(
                  "Send File",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : Container(height: 10.h),
      ),
    );
  }

  void _sendFile({
    required BuildContext context,
    required List<DeviceInfo> devices,
  }) {
    if (devices.isEmpty) {
      showSnack(text: "No devices found", backgroundColor: Colors.red);
      return;
    }
    openBottomSheet(
      child: Column(
        children: [
          ...devices.map(
            (e) => bottomSheetTile(
              context: context,
              icon: _getPlatformIcon(e.platform),
              title: e.name,
              subtitle: e.ipAddress,
              onTap: () {
                Navigator.pop(context);
                context.read<ShareCubit>().sendFilesToDevice(e);
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'android':
        return Icons.android;
      case 'ios':
        return Icons.phone_iphone;
      
      default:
        return Icons.devices;
    }
  }
}
