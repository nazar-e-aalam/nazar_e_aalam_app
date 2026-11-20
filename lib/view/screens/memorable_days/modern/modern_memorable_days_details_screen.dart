// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../model/memorable_days_model.dart';
import '../widget/memorable_days_common.dart';
import '../widget/memorable_days_views.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';

class ModernMemorableDaysDetailsScreen extends StatelessWidget {
  final MemorableMonth month;
  const ModernMemorableDaysDetailsScreen({super.key, required this.month});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: localizedValue(month.name, memorableLanguage())),
    body: MemorableDayContent(month: month, modern: true),
  );
}
