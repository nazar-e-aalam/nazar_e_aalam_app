// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

import 'model/kalima_model.dart';
import 'widget/kalima_content.dart';

class KalimaDetailsScreen extends StatelessWidget {
  final KalimaModel kalima;

  const KalimaDetailsScreen({
    super.key,
    required this.kalima,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: kalima.localizedTitle(kalimaLanguage()),
        isBackButtonExist: true,
      ),
      body: SafeArea(
        child: KalimaDetailsContent(kalima: kalima),
      ),
    );
  }
}
