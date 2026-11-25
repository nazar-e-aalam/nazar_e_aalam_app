// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nazar_e_alam/controller/audio_player_controller.dart';
import 'package:nazar_e_alam/helper/route_helper.dart';
import 'package:nazar_e_alam/shimmer/all_shimmer_loder.dart';
import 'package:nazar_e_alam/util/dimensions.dart';
import 'package:nazar_e_alam/util/images.dart';
import 'package:nazar_e_alam/util/styles.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReciterScreen extends StatefulWidget {
  final bool? appBackButton;

  const ReciterScreen({super.key, this.appBackButton});

  @override
  State<ReciterScreen> createState() => _ReciterScreenState();
}

class _ReciterScreenState extends State<ReciterScreen> {
  late final AudioPlayerController audioPlayerController;

  @override
  void initState() {
    super.initState();

    audioPlayerController = Get.isRegistered<AudioPlayerController>()
        ? Get.find<AudioPlayerController>()
        : Get.put(AudioPlayerController(apiClient: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioPlayerController.fetchReciterData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'all_reciters_key'.tr,
        isBackButtonExist: widget.appBackButton == true,
      ),
      body: GetBuilder<AudioPlayerController>(
        builder: (controller) {
          final reciters = controller.recitersListApiData?.data ?? [];

          if (controller.isRecitersLoading.value &&
              controller.recitersListApiData == null) {
            return const Center(child: DhuaShimmer());
          }

          if (reciters.isEmpty) {
            return Center(child: Text('no_data_found'.tr, style: robotoMedium));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.PADDING_SIZE_SMALL,
            ),
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];

              return Card(
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).cardColor,
                child: ListTile(
                  contentPadding: const EdgeInsetsDirectional.only(
                    start: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                    end: Dimensions.PADDING_SIZE_SMALL,
                  ),
                  leading: CircleAvatar(
                    backgroundImage:
                        reciter.profilePicture != null &&
                            reciter.profilePicture!.isNotEmpty
                        ? CachedNetworkImageProvider(reciter.profilePicture!)
                        : const AssetImage(Images.Reciter_Person)
                              as ImageProvider,
                  ),
                  title: Text(
                    reciter.name ?? 'no_name_found_key'.tr,
                    style: robotoMedium,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    final slug = reciter.slug;

                    if (slug == null || slug.isEmpty) {
                      Get.snackbar('Error', 'Reciter slug is missing');
                      return;
                    }

                    Get.toNamed(RouteHelper.audioList, arguments: slug);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
