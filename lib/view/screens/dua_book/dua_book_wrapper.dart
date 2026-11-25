import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'dua_book_screen.dart';
import 'modern/modern_dua_book_screen.dart';

class DuaBookWrapper extends StatelessWidget {
  final bool? appBackButton;
  const DuaBookWrapper({super.key, this.appBackButton});
  @override
  Widget build(BuildContext context) => Obx(() {
    final modern =
        Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: modern
          ? ModernDuaBookScreen(
              key: const ValueKey('modern'),
              appBackButton: appBackButton,
            )
          : DuaBookScreen(
              key: const ValueKey('classic'),
              appBackButton: appBackButton,
            ),
    );
  });
}
