// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:shareit/core/config/routes/routes.dart';
import 'package:shareit/core/utils/assets.dart';
import 'package:shareit/core/utils/common.dart';
import 'package:shareit/features/share/data/models/transfer_session_model.dart';
import '../cubit/share_cubit.dart';

class ShareMainPage extends StatefulWidget {
  const ShareMainPage({super.key});

  @override
  State<ShareMainPage> createState() => _ShareMainPageState();
}

class _ShareMainPageState extends State<ShareMainPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShareCubit>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ShareCubit, ShareState>(
      listenWhen: (previous, current) =>
          previous.isReceiving != current.isReceiving ||
          previous.transferProgress != current.transferProgress ||
          previous.statusMessage != current.statusMessage,
      listener: (context, state) {
        if (state.statusMessage.isNotEmpty) {
          showSnack(text: state.statusMessage);
        }
        if (state.isReceiving && state.transferProgress < 100) {
          showSnack(
            text: 'Receiving... ${state.transferProgress.toStringAsFixed(0)}%',
          );
        }
        if (!state.isReceiving && state.transferProgress == 100) {
          showSnack(
            text: 'File received successfully!',
            backgroundColor: Colors.green,
          );
        }
      },
      builder: (context, state) {
        final transferStatus = state.currentStatus;
        final noDevices =
            state.discoveredDevices.isEmpty &&
            transferStatus != TransferStatus.discovering;

        return Scaffold(
          appBar: _appBar(context),
          body: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: SizedBox(
                      height: 300.h,
                      width: 300.h,
                      child: ClipOval(
                        child: noDevices
                            ? Image.network(NetworkImagePath.noDeviceImage)
                            : Lottie.network(
                                NetworkLottiePath.discoverLottie,
                                height: 300.h,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                  if (!noDevices)
                    ...state.discoveredDevices.asMap().entries.map((entry) {
                      final index = entry.key;
                      final device = entry.value;

                      final angle =
                          (2 * pi * index) / state.discoveredDevices.length;
                      final radius = 120.0;
                      final dx = radius * cos(angle);
                      final dy = radius * sin(angle);

                      return Positioned(
                        left: 150.h + dx.toDouble(),
                        top: 150.h + dy.toDouble(),
                        child: Column(
                          children: [
                            ClipOval(
                              child: Container(
                                height: 55.h,
                                width: 55.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 15,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    NetworkImagePath.onboardingAvatar,
                                    height: 50.h,
                                    width: 50.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              device.ipAddress,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),

              SizedBox(height: 30.h),
              Text(
                noDevices
                    ? "No devices found"
                    : "Discovering nearby devices...",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
              if (noDevices)
                TextButton(
                  onPressed: retryOnNoDevice,
                  child: Text(
                    "Retry",
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              SizedBox(height: 100.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sendTile(
                    context: context,
                    label: "Send",
                    imagePath: NetworkImagePath.sendGif,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.send),
                  ),
                  _sendTile(
                    context: context,
                    label: "Receive",
                    imagePath: NetworkImagePath.receiveGif,
                    onTap: () {
                      showSnack(text: "Try receiving from another device...");
                    },
                  ),
                ],
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
        'ShareIt',
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
      child: Column(
        children: [
          ClipOval(
            child: Image.network(imagePath, height: 70.h, fit: BoxFit.cover),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void retryOnNoDevice() {
    context.read<ShareCubit>().startDeviceDiscovery();
  }
}
