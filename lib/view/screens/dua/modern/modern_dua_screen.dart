// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/dua_controller.dart';
import 'package:nazar_e_alam/data/repository/dua_list_repo.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern Dua screen — glass tabs + animated rank-chipped list items.
class ModernDuaScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernDuaScreen({super.key, required this.appBackButton});

  @override
  State<ModernDuaScreen> createState() => _ModernDuaScreenState();
}

class _ModernDuaScreenState extends State<ModernDuaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Get.put(DuaRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
    Get.find<DuaController>().fetchDuaListData();
    Get.find<DuaController>().loadDuaList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: dark
          ? Theme.of(context).scaffoldBackgroundColor
          : AppColorModern.scaffoldBackground,
      appBar: CustomAppBar(
        title: "all_duas".tr,
        isBackButtonExist: widget.appBackButton,
        actions: [
          IconButton(
            tooltip: "add_dua".tr,
            onPressed: () {
              Get.toNamed(RouteHelper.duaAdd);
            },
            icon: const Icon(Icons.playlist_add_rounded, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: ModernGlassPanel(
          color: dark ? const Color(0x0AFFFFFF) : AppColorModern.glassFill,
          child: Column(
            children: [
              // Glass pill tab bar
              _buildModernTabBar(context),
              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // API duas
                    const _ModernApiDuaList(),
                    // User-added duas
                    const _ModernUserDuaList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabBar(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
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
          gradient: LinearGradient(
            colors: [primary, primary.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: darkText(context),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: [_buildTab('dua'.tr), _buildTab('added_dua'.tr)],
      ),
    );
  }

  Widget _buildTab(String label) {
    return Tab(
      child: Text(
        label,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.FONT_SIZE_DEFAULT,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color darkText(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF9A8F82) : AppColorModern.textSecondary;
  }
}

/// Modern API dua list.
class _ModernApiDuaList extends StatelessWidget {
  const _ModernApiDuaList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DuaController>(
      builder: (controller) {
        if (controller.isDuaListLoading.value ||
            controller.duaApiData == null) {
          return const Center(child: HadisChapterShimmer());
        }

        final data = controller.duaApiData!.data;
        if (data == null || data.isEmpty) {
          return ModernEmptyState(
            icon: Icons.event_outlined,
            title: 'no_dua_added_here'.tr,
            subtitle: 'no_dua_available'.tr,
          );
        }

        return ModernAnimatedList(
          itemCount: data.length,
          padding: const EdgeInsets.fromLTRB(
            Dimensions.PADDING_SIZE_DEFAULT,
            8,
            Dimensions.PADDING_SIZE_DEFAULT,
            Dimensions.PADDING_SIZE_EXTRA_LARGE,
          ),
          itemBuilder: (context, index) {
            final item = data[index];
            return ModernListItem(
              key: ValueKey('dua_api_${item.id}_$index'),
              index: index + 1,
              title: item.enShortName ?? "",
              subtitle: item.arShortName != null && item.arShortName!.isNotEmpty
                  ? item.arShortName
                  : null,
              accentColor: Theme.of(context).primaryColor,
              isFirst: index == 0,
              isLast: index == data.length - 1,
              onTap: () {
                final controller = Get.find<DuaController>();
                controller.fetchDuaDetailsData(duaId: item.id.toString());
                Get.toNamed(RouteHelper.duaView);
              },
            );
          },
        );
      },
    );
  }
}

/// Modern user-added dua list.
class _ModernUserDuaList extends StatelessWidget {
  const _ModernUserDuaList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DuaController>(
      builder: (controller) {
        final data = controller.duaList;
        if (data.isEmpty) {
          return ModernEmptyState(
            icon: Icons.add_circle_outline,
            title: 'no_added_duas'.tr,
            subtitle: 'add_dua'.tr,
            action: ModernPrimaryButton(
              text: 'add_dua'.tr,
              onPressed: () => Get.toNamed(RouteHelper.duaAdd),
              icon: Icons.add_rounded,
            ),
          );
        }

        return ModernAnimatedList(
          itemCount: data.length,
          padding: const EdgeInsets.fromLTRB(
            Dimensions.PADDING_SIZE_DEFAULT,
            8,
            Dimensions.PADDING_SIZE_DEFAULT,
            Dimensions.PADDING_SIZE_EXTRA_LARGE,
          ),
          itemBuilder: (context, index) {
            final item = data[index];
            return ModernListItem(
              key: ValueKey('dua_user_${item.id}_$index'),
              index: index + 1,
              title: item.englishName,
              subtitle: item.arabicName.isNotEmpty ? item.arabicName : null,
              accentColor: AppColorModern.primaryColor,
              isFirst: index == 0,
              isLast: index == data.length - 1,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
