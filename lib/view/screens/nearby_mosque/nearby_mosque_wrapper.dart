// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/screens/nearby_mosque/modern/modern_nearby_mosque_screen.dart';
import 'package:nazar_e_alam/view/screens/nearby_mosque/nearby_mosque_screen.dart';

/// Routes to the classic or modern Nearby Mosque screen based on the saved
/// layout preference.
class NearbyMosqueWrapper extends StatefulWidget {
  final bool appBackButton;
  const NearbyMosqueWrapper({super.key, required this.appBackButton});

  @override
  State<NearbyMosqueWrapper> createState() => _NearbyMosqueWrapperState();
}

class _NearbyMosqueWrapperState extends State<NearbyMosqueWrapper> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final layout = Get.find<HomeLayoutController>().currentLayout.value;
      final modern = layout == HomeLayoutController.modern;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: modern
            ? ModernNearbyMosqueScreen(
                key: const ValueKey('modern'),
                appBackButton: widget.appBackButton,
              )
            : NearbyMosque(
                key: const ValueKey('classic'),
                appBackButton: widget.appBackButton,
              ),
      );
    });
  }
}
