// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/controller/dhikr_controller.dart';
import 'package:nazar_e_alam/data/repository/dikir_list_repo.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/theme/modern_light_theme.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

/// Modern Dhikr screen — glass tabs + animated rank-chipped list items.
class ModernDhikrScreen extends StatefulWidget {
  final bool appBackButton;
  const ModernDhikrScreen({super.key, required this.appBackButton});

  @override
  State<ModernDhikrScreen> createState() => _ModernDhikrScreenState();
}

class _ModernDhikrScreenState extends State<ModernDhikrScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Get.put(DhikrRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
    Get.find<DhikrController>().fetchDikirListData();
    Get.find<DhikrController>().localLoadDhikrList();
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
        title: "all_dhikr".tr,
        isBackButtonExist: widget.appBackButton,
        actions: [
          IconButton(
            tooltip: "add_dikir".tr,
            onPressed: () {
              Get.toNamed(RouteHelper.addDhikr);
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
              _buildModernTabBar(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const _ModernApiDhikrList(),
                    const _ModernUserDhikrList(),
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
        unselectedLabelColor: _darkText(context),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        tabs: [_buildTab('dhikr'.tr), _buildTab('added_dhikr'.tr)],
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

  Color _darkText(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? const Color(0xFF9A8F82) : AppColorModern.textSecondary;
  }
}

/// Modern API dhikr list.
class _ModernApiDhikrList extends StatelessWidget {
  const _ModernApiDhikrList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DhikrController>(
      builder: (controller) {
        if (controller.isDikirListLoading.value ||
            controller.dikirListApiData == null) {
          return const Center(child: HadisChapterShimmer());
        }

        final data = controller.dikirListApiData!.data;
        if (data == null || data.isEmpty) {
          return ModernEmptyState(
            icon: Icons.event_outlined,
            title: 'no_dhikr_found'.tr,
            subtitle: 'no_dhikr_available'.tr,
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
              key: ValueKey('dhikr_api_${item.id}_$index'),
              index: index + 1,
              title: item.enShortName ?? "",
              subtitle: item.arShortName != null && item.arShortName!.isNotEmpty
                  ? item.arShortName
                  : null,
              accentColor: Theme.of(context).primaryColor,
              isFirst: index == 0,
              isLast: index == data.length - 1,
              onTap: () {
                final controller = Get.find<DhikrController>();
                controller.fetchDikirDetailsData(dikirId: item.id.toString());
                controller.dikirId = item.id.toString();
                Get.toNamed(RouteHelper.dhikrCount);
              },
            );
          },
        );
      },
    );
  }
}

/// Modern user-added dhikr list.
class _ModernUserDhikrList extends StatelessWidget {
  const _ModernUserDhikrList();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DhikrController>(
      builder: (controller) {
        final data = controller.dhikrList;
        if (data.isEmpty) {
          return ModernEmptyState(
            icon: Icons.add_circle_outline,
            title: 'no_added_dhikr'.tr,
            subtitle: 'add_dikir'.tr,
            action: ModernPrimaryButton(
              text: 'add_dikir'.tr,
              onPressed: () => Get.toNamed(RouteHelper.addDhikr),
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
              key: ValueKey('dhikr_user_${item.id}_$index'),
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
