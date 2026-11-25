// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import 'widget/shijra_image_viewer.dart';
import 'widget/shijra_items.dart';

class ShijraDetailsScreen extends StatelessWidget {
  final ShijraItem item;

  const ShijraDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: item.titleKey.tr, isBackButtonExist: true),
      body: SafeArea(child: ShijraImageViewer(imagePath: item.imagePath)),
    );
  }
}
