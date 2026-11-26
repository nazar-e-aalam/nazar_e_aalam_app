// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/home_layout_controller.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/screens/language/language_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/notification/notification_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/prayer_settings/prayer_calculation_settings.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/home_layout_dw_widget.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/settings_actions.dart';
import 'package:nazar_e_alam/view/screens/settings/widgets/settings_content.dart';

class SettingsScreen extends StatelessWidget {
  final bool appBackButton;
  const SettingsScreen({super.key, required this.appBackButton});
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final bool modern =
        Get.find<HomeLayoutController>().currentLayout.value ==
        HomeLayoutController.modern;
    void page(String module) =>
        Get.to(() => SettingsContent(module: module, modern: modern));
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
      child: Text(
        text.tr,
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: t.primaryColor,
        ),
      ),
    );
    Widget tile(IconData icon, String text, VoidCallback action) => ListTile(
      leading: Icon(icon, color: t.primaryColor),
      title: Text(text.tr),
      trailing: const Icon(Icons.chevron_right),
      onTap: action,
    );
    Widget group(List<Widget> children) => Card(
      elevation: modern ? 0 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(modern ? 20 : 8),
      ),
      child: Column(children: children),
    );
    Widget social(IconData icon, String text, String url, Color color) =>
        Expanded(
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => SettingsActions.open(url),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 4,
                ),
                child: Column(
                  children: [
                    Icon(icon, color: color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return Scaffold(
      appBar: CustomAppBar(
        title: 'settings'.tr,
        isBackButtonExist: appBackButton,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          24,
          16,
          modern && !appBackButton ? 120 : 24,
        ),
        children: [
          heading('preferences'),
          const PrayerTimeCalculationSettings(),
          const NofificationDWWidget(),
          const LanguageDWWidget(),
          const HomeLayoutDWWidget(),
          heading('spiritual_guidance'),
          if (modern)
            Card(
              elevation: 0,
              color: t.primaryColor.withValues(alpha: .10),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: InkWell(
                onTap: () => page('nasihat'),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: t.primaryColor,
                        size: 34,
                      ),
                      const SizedBox(height: 12),
                      Text('nasihat'.tr, style: t.textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text('spiritual_guidance_description'.tr),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'read_advice'.tr,
                            style: TextStyle(color: t.primaryColor),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: t.primaryColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            group([tile(Icons.menu_book, 'nasihat', () => page('nasihat'))]),
          heading('connect_with_us'),
          if (modern)
            Row(
              children: [
                social(
                  Icons.play_circle_fill,
                  'YouTube',
                  SettingsActions.youtube,
                  Colors.red,
                ),
                social(
                  Icons.facebook,
                  'Facebook',
                  SettingsActions.facebook,
                  Colors.blue,
                ),
                social(
                  Icons.camera_alt_outlined,
                  'Instagram',
                  SettingsActions.instagram,
                  Colors.pink,
                ),
              ],
            )
          else ...[
            group([
              tile(
                Icons.play_circle_outline,
                'YouTube',
                () => SettingsActions.open(SettingsActions.youtube),
              ),
            ]),
            group([
              tile(
                Icons.facebook,
                'Facebook',
                () => SettingsActions.open(SettingsActions.facebook),
              ),
            ]),
            group([
              tile(
                Icons.camera_alt_outlined,
                'Instagram',
                () => SettingsActions.open(SettingsActions.instagram),
              ),
            ]),
          ],
          heading('application'),
          if (modern)
            group([
              tile(
                Icons.share_outlined,
                'share',
                () => SettingsActions.share(context),
              ),
              const Divider(height: 1),
              tile(
                Icons.star_border,
                'rate_us',
                () => SettingsActions.open(SettingsActions.store(context)),
              ),
              const Divider(height: 1),
              tile(Icons.info_outline, 'about_us', () => page('about_us')),
              const Divider(height: 1),
              tile(
                Icons.privacy_tip_outlined,
                'privacy_policy',
                () => page('privacy_policy'),
              ),
            ])
          else ...[
            group([
              tile(Icons.share, 'share', () => SettingsActions.share(context)),
            ]),
            group([
              tile(
                Icons.star_border,
                'rate_us',
                () => SettingsActions.open(SettingsActions.store(context)),
              ),
            ]),
            group([
              tile(Icons.info_outline, 'about_us', () => page('about_us')),
            ]),
            group([
              tile(
                Icons.privacy_tip_outlined,
                'privacy_policy',
                () => page('privacy_policy'),
              ),
            ]),
          ],
          const SizedBox(height: 28),
          Center(child: Text('Nazar E Aalam', style: t.textTheme.titleMedium)),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
