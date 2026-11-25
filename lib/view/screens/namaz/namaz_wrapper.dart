import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'namaz_screen.dart';
import 'modern/modern_namaz_screen.dart';

class NamazWrapper extends StatelessWidget {
  final bool? appBackButton;
  const NamazWrapper({super.key, this.appBackButton});
  @override
  Widget build(BuildContext context) => Obx(() {
    final modern =
        Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: modern
          ? ModernNamazScreen(
              key: const ValueKey('modern'),
              appBackButton: appBackButton,
            )
          : NamazScreen(
              key: const ValueKey('classic'),
              appBackButton: appBackButton,
            ),
    );
  });
}
