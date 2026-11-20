// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/quran_controller.dart';
import 'package:nazar_e_alam/controller/quran_milestone_controller.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';
import 'package:nazar_e_alam/view/screens/quran/quran_settings_screen.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/arabic_quran_widget.dart';
import 'package:nazar_e_alam/view/screens/quran/widget/ayah_translation_widget.dart';

/// Modern Quran Surah Detail screen — glass surface, modern tab bar.
class ModernSuraDetileScreen extends StatefulWidget {
  final bool appBackButton;
  final int? savedPage = int.tryParse(Get.arguments.toString());

  ModernSuraDetileScreen({super.key, required this.appBackButton});

  @override
  State<ModernSuraDetileScreen> createState() => _ModernSuraDetileScreenState();
}

class _ModernSuraDetileScreenState extends State<ModernSuraDetileScreen>
    with SingleTickerProviderStateMixin {
  late final QuranController _quranController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _quranController = Get.find<QuranController>();
    _tabController = TabController(length: 2, vsync: this);

    // Defer API fetch until after build to avoid setState-during-build error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final suraId = _quranController.suraNumber;

      if (suraId != null && suraId >= 1 && suraId <= 114) {
        _quranController.fetchSuraDetaileData(suraId: suraId.toString());
      } else {
        debugPrint('Invalid Surah ID in modern detail screen: $suraId');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return GetBuilder<QuranController>(
      builder: (quranController) {
        final isLoading = quranController.isSuraDetaileLoading.value;
        final sura = quranController.suraDetaileApiData?.data?.chapter;

        if (!isLoading && sura?.id != null) {
          final suraId = sura!.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.find<QuranMilestoneController>().markSurahRead(suraId);
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: false,
          backgroundColor: dark
              ? Theme.of(context).scaffoldBackgroundColor
              : AppColorModern.scaffoldBackground,
          appBar: CustomAppBar(
            title: isLoading || sura == null
                ? 'holy_quran'.tr
                : [
                    (sura.translatedName?.trim().isNotEmpty == true
                        ? sura.translatedName!
                        : (sura.arabicName ?? 'holy_quran'.tr)),
                    if (sura.versesCount != null)
                      '${sura.versesTranslateName ?? 'Verses'}: ${sura.versesCount}',
                  ].join('\n'),
            isBackButtonExist: widget.appBackButton,
            actions: [
              if (!isLoading)
                IconButton(
                  onPressed: () => openBottomSheet(context),
                  icon: SvgPicture.asset(
                    Images.Icon_Quran_Setting,
                    color: Get.isDarkMode
                        ? Theme.of(context).indicatorColor
                        : Theme.of(context).cardColor,
                    height: 28,
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: ModernGlassPanel(
              color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
              child: Column(
                children: [
                  _buildModernTabBar(context),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Center(
                          child: ArabicQuranWidget(
                            pageNumber: widget.savedPage,
                          ),
                        ),
                        const Center(child: AyanTranslationWidget()),
                      ],
                    ),
                  ),
                  _buildNavigationButtons(context, quranController),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_DEFAULT,
        8,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColorModern.divider.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF26B21), Color(0xFFF58220)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B5E52),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: [
          Tab(text: 'arabic'.tr),
          Tab(text: 'ayah_and_translation'.tr),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    QuranController quranController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      child: Row(
        children: [
          _navButton(
            context,
            icon: Icons.chevron_left,
            label: 'previous_sura'.tr,
            isEnabled:
                !quranController.isSuraDetaileLoading.value &&
                (quranController.suraNumber ?? 1) > 1,
            onPressed: () {
              quranController.suraNumber =
                  (quranController.suraNumber ?? 1) - 1;
              quranController.fetchSuraDetaileData(
                suraId: quranController.suraNumber.toString(),
              );
            },
          ),
          const SizedBox(width: 16),
          _navButton(
            context,
            label: 'next_sura'.tr,
            icon: Icons.chevron_right,
            isLeftIcon: false,
            isEnabled:
                !quranController.isSuraDetaileLoading.value &&
                (quranController.suraNumber ?? 114) < 114,
            onPressed: () {
              quranController.suraNumber =
                  (quranController.suraNumber ?? 1) + 1;
              quranController.fetchSuraDetaileData(
                suraId: quranController.suraNumber.toString(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isEnabled,
    required VoidCallback onPressed,
    bool isLeftIcon = true,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isEnabled ? 1.0 : 0.4,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: isLeftIcon
                  ? [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(label, style: robotoMedium.copyWith(fontSize: 15)),
                    ]
                  : [
                      Text(label, style: robotoMedium.copyWith(fontSize: 15)),
                      const SizedBox(width: 8),
                      Icon(icon, size: 20),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
