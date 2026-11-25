// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/audio/modern/modern_audio_list_screen.dart';
import 'package:nazar_e_alam/view/screens/audio/audio_list.dart';

/// Routes to the classic or modern Audio List screen based on the saved
/// layout preference.
class AudioListWrapper extends StatefulWidget {
  final bool? appBackButton;
  const AudioListWrapper({super.key, this.appBackButton});

  @override
  State<AudioListWrapper> createState() => _AudioListWrapperState();
}

class _AudioListWrapperState extends State<AudioListWrapper> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layout = Get.find<HomeLayoutController>().currentLayout.value;
      final modern = layout == HomeLayoutController.modern;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: modern
            ? ModernAudioListScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : AudioPlayerView(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
