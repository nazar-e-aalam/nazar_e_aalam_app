// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Loading cheacker--->
    final widget = (Platform.isAndroid)
        ? const CircularProgressIndicator()
        : const CupertinoActivityIndicator();
    return Container(alignment: Alignment.center, child: widget);
  }
}
