// ignore_for_file: deprecated_member_use

// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
// import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:nazar_e_alam/view/screens/language/language_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/notification/notification_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/prayer_settings/prayer_calculation_settings.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/home_layout_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/item_widgets.dart';

/// Modern Settings screen — glass surface wrapping classic sub-widgets.
class ModernSettingsScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernSettingsScreen({super.key, required this.appBackButton});

  @override
  State<ModernSettingsScreen> createState() => _ModernSettingsScreenState();
}

class _ModernSettingsScreenState extends State<ModernSettingsScreen> {
  /// Store link for the current platform (null when not available).
  String? _storeUrl(SettingsController c) {
    // final data = c.mosqueSettingsApiData?.data;
    // if (data == null) return null;
    // final url = Platform.isIOS ? data.appStoreUrl : data.playStoreUrl;
    // final s = url?.toString();
    return 'https://play.google.com/store/apps/details?id=com.fazilshah.nazareaalam&pcampaignid=web_share';
  }

  Future<void> _share(String url) async {
    if (Uri.tryParse(url) != null) {
      await Share.share(url);
    } else {
      showCustomSnackBar('invalid_URL'.tr, isError: true);
    }
  }

  Future<void> _rate(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('invalid_URL'.tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final modern =
        Get.find<HomeLayoutController>().currentLayout.value ==
            HomeLayoutController.modern;
    final bottomPad = (modern && !widget.appBackButton) ? 120.0 : 16.0;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: 'settings'.tr,
        isBackButtonExist: widget.appBackButton,
      ),
      body: SafeArea(
        child: GetBuilder<SettingsController>(
          builder: (settingsController) {
            final storeUrl = _storeUrl(settingsController);

            return ModernGlassPanel(
              color: dark
                  ? const Color(0x0AFFFFFF)
                  : AppColorModern.glassFill,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  Dimensions.PADDING_SIZE_EXTRA_SMALL,
                  bottomPad,
                ),
                child: Column(
                  children: [
                    const PrayerTimeCalculationSettings(),
                    const NofificationDWWidget(),
                    const LanguageDWWidget(),
                    const HomeLayoutDWWidget(),
                    if (storeUrl != null) ...[
                      SettingsItem(
                        leadingIcon: Icons.share,
                        imagePath: Images.Icon_share_app,
                        title: 'share'.tr,
                        onTap: () => _share(storeUrl),
                      ),
                      const SizedBox(height: 12),
                      SettingsItem(
                        leadingIcon: Icons.rate_review,
                        imagePath: Images.Icon_rate_app,
                        title: 'rate_us'.tr,
                        onTap: () => _rate(storeUrl),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
