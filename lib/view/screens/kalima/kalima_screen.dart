// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import 'widget/kalima_content.dart';
import 'kalima_details_screen.dart';

class KalimaScreen extends StatelessWidget {
  final bool? appBackButton;

  const KalimaScreen({super.key, this.appBackButton});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Kalima Sharif',
        isBackButtonExist: appBackButton == true,
      ),
      body: SafeArea(
        child: KalimaListContent(
          onSelected: (kalima) {
            Get.to(() => KalimaDetailsScreen(kalima: kalima));
          },
        ),
      ),
    );
  }
}
