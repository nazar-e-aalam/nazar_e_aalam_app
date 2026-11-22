// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/memorable_days_model.dart';
import '../widget/memorable_days_common.dart';
import '../widget/memorable_days_views.dart';
import 'modern_memorable_days_details_screen.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

class ModernMemorableDaysScreen extends StatelessWidget {
  final bool appBackButton;
  const ModernMemorableDaysScreen({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: memorableLabel('title')),
    body: MemorableMonthLoader(
      builder: (context, months) => MemorableMonthList(
        months: months,
        modern: true,
        onOpen: (MemorableMonth month) =>
            Get.to(() => ModernMemorableDaysDetailsScreen(month: month)),
      ),
    ),
  );
}
