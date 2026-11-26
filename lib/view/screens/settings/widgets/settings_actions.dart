// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nazar_e_alam/view/base/custom_snackbar.dart';

class SettingsActions {
  static const youtube = 'https://www.youtube.com/@khankaheintekhabiya';
  static const facebook = 'https://www.facebook.com/khankah.e.intekhabiy';
  static const instagram = 'https://www.instagram.com/khankah_e_intekhabiya/';
  static const playStore =
      'https://play.google.com/store/apps/details?id=com.fazilshah.nazareaalam';
  static const appStore = '';
  static String store(BuildContext context) =>
      Theme.of(context).platform == TargetPlatform.iOS ? appStore : playStore;
  static Future<void> open(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !((uri.scheme == 'https' && uri.host.isNotEmpty) ||
              (uri.scheme == 'mailto' && uri.path.isNotEmpty)) ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        showCustomSnackBar('Link unavailable'.tr, isError: true);
      }
    } catch (_) {
      showCustomSnackBar('Unable to open link'.tr, isError: true);
    }
  }

  static Future<void> share(BuildContext context) async {
    final url = store(context);
    if (url.isEmpty) {
      showCustomSnackBar('Link unavailable'.tr, isError: true);
      return;
    }
    final box = context.findRenderObject();
    try {
      // ignore: deprecated_member_use
      await Share.share(
        url,
        sharePositionOrigin: box is RenderBox && box.hasSize
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (_) {
      showCustomSnackBar('Unable to share app'.tr, isError: true);
    }
  }
}
