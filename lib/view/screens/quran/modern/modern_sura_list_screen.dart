// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/bookmark_controller.dart';
import 'package:nazar_e_alam/controller/quran_settings_controller.dart';

import 'package:nazar_e_alam/theme/modern_light_theme.dart';

import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';

import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

import 'package:nazar_e_alam/view/screens/quran/quran_settings_screen.dart';
import 'widget/modern_sura_list_widget.dart';
import 'widget/modern_juz_list_widget.dart';
import 'widget/modern_bookmark_tab.dart';
import 'widget/modern_quran_language_menu.dart';

class ModernSuraListScreen extends StatefulWidget {
  final bool appBackButton;

  const ModernSuraListScreen({super.key, required this.appBackButton});

  @override
  State<ModernSuraListScreen> createState() => _ModernSuraListScreenState();
}

class _ModernSuraListScreenState extends State<ModernSuraListScreen>
    with SingleTickerProviderStateMixin {
  late final BookMarkController _bookMarkController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }

    _bookMarkController = Get.isRegistered<BookMarkController>()
        ? Get.find<BookMarkController>()
        : Get.put(BookMarkController());

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _bookMarkController.bookMarks.isEmpty ? 0 : 2,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==================== MAIN SCREEN ====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? theme.scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,

      appBar: CustomAppBar(
        title: 'holy_quran'.tr,
        isBackButtonExist: widget.appBackButton,
        actions: [
          ModernQuranLanguageMenu(
            iconColor: dark
                ? theme.textTheme.bodyMedium?.color
                : theme.cardColor,
          ),

          IconButton(
            tooltip: 'settings'.tr,

            onPressed: () => openBottomSheet(context),

            icon: SvgPicture.asset(
              Images.Icon_Quran_Setting,
              height: 28,

              colorFilter: ColorFilter.mode(
                dark
                    ? theme.textTheme.bodyMedium?.color ?? Colors.white
                    : theme.cardColor,

                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        bottom: false,
        child: ModernGlassPanel(
          color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,

          child: Column(
            children: [
              _buildTabBar(context),

              const SizedBox(height: 4),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    // _buildSurahTab(),
                    ModernSuraListWidget(),
                    ModernJuzListWidget(),
                    ModernBookmarkTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== MODERN TAB BAR ====================

  Widget _buildTabBar(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_SMALL,
        Dimensions.PADDING_SIZE_DEFAULT,
        Dimensions.PADDING_SIZE_SMALL,
      ),

      child: Container(
        padding: const EdgeInsets.all(5),

        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.10)),
        ),

        child: TabBar(
          controller: _tabController,

          isScrollable: false,
          dividerColor: Colors.transparent,
          dividerHeight: 0,

          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.zero,

          indicator: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          labelColor: Colors.white,
          unselectedLabelColor: primary,

          labelStyle: robotoMedium.copyWith(
            fontSize: Dimensions.FONT_SIZE_SMALL,
            fontWeight: FontWeight.w600,
          ),

          unselectedLabelStyle: robotoMedium.copyWith(
            fontSize: Dimensions.FONT_SIZE_SMALL,
          ),

          labelPadding: const EdgeInsets.symmetric(horizontal: 4),

          splashBorderRadius: BorderRadius.circular(12),

          tabs: [
            _buildTab(icon: Icons.menu_book_rounded, label: 'surah_list'.tr),
            _buildTab(icon: Icons.auto_stories_rounded, label: 'juz_list'.tr),
            _buildTab(
              icon: Icons.bookmark_border_rounded,
              label: 'bookmark'.tr,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required IconData icon, required String label}) {
    return Tab(
      height: 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),

          const SizedBox(height: 5),

          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
