// ignore_for_file: deprecated_member_use
// ignore_for_file: library_private_types_in_public_api, strict_top_level_inference

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_setter/wallpaper_setter.dart';
import 'package:nazar_e_alam/data/model/response/wallpaper_model.dart';

import '../data/repository/wallpaper_repo.dart';

class WallPaperController extends GetxController implements GetxService {
  final WallpaperRepo wallpaperRepo;

  WallPaperController({required this.wallpaperRepo});

  RxBool isWallPaperListLoading = false.obs;

  WallpaperModel? wallpaperModelData;
  var selectedCategory = ''.obs;

  bool isHomeChecked = true; // For first checkbox
  bool isLockChecked = true; // For second checkbox
  RxBool isLoadingMoreWallpapers = false.obs;

  setHomeCheckedValue(homeCheckedValue) {
    isHomeChecked = homeCheckedValue;

    update();
  }

  setLockCheckedValue(lockCheckedValue) {
    isLockChecked = lockCheckedValue;

    update();
  }

  setWallpaperCategoryValue(type) {
    selectedCategory = type;

    update();
  }

  Future<void> wallpaperCategoryListDetails(String category) async {
    try {
      isWallPaperListLoading(true);
      update();

      final response = await wallpaperRepo.getWallpaperLisRepo();

      if (response.statusCode == 200) {
        wallpaperModelData = WallpaperModel.fromJson(response.body);

        // Set selected category to passed category
        selectedCategory.value = category;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    } finally {
      isWallPaperListLoading(false);
      update();
    }
  }

  Future<void>? _wallpaperRequest;
  int _nextSkip = 0;
  bool _hasMoreWallpapers = true;

  Future<void> wallpaperCategoryListData({bool refresh = false}) {
    if (_wallpaperRequest != null) {
      return _wallpaperRequest!;
    }

    if (!refresh && wallpaperModelData != null) {
      return Future.value();
    }

    _wallpaperRequest = _fetchWallpapers(refresh: true);
    return _wallpaperRequest!;
  }

  Future<void> loadMoreWallpapers() {
    if (_wallpaperRequest != null) {
      return _wallpaperRequest!;
    }

    if (!_hasMoreWallpapers || wallpaperModelData == null) {
      return Future.value();
    }

    _wallpaperRequest = _fetchWallpapers(refresh: false);
    return _wallpaperRequest!;
  }

  Future<void> _fetchWallpapers({required bool refresh}) async {
    if (refresh) {
      isWallPaperListLoading.value = true;
    } else {
      isLoadingMoreWallpapers.value = true;
    }

    update();

    try {
      final skip = refresh ? 0 : _nextSkip;

      final response = await wallpaperRepo.getWallpaperLisRepo(
        skip: skip,
        limit: 50,
        refresh: refresh,
      );

      if (response.statusCode != 200) {
        debugPrint('Wallpaper HTTP error: ${response.statusCode}');
        return;
      }

      final incoming = WallpaperModel.fromJson(
        Map<String, dynamic>.from(response.body as Map),
      );

      if (refresh || wallpaperModelData == null) {
        wallpaperModelData = incoming;
      } else {
        final existing = wallpaperModelData!.data;
        final existingIds = existing.map((e) => e.id).toSet();

        for (final wallpaper in incoming.data) {
          if (existingIds.add(wallpaper.id)) {
            existing.add(wallpaper);
          }
        }

        wallpaperModelData!.total = incoming.total;
        wallpaperModelData!.pages = incoming.pages;
      }

      _nextSkip = skip + incoming.data.length;

      _hasMoreWallpapers =
          incoming.data.isNotEmpty && _nextSkip < incoming.total;
    } catch (e, stackTrace) {
      debugPrint('Wallpaper fetch error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isWallPaperListLoading.value = false;
      isLoadingMoreWallpapers.value = false;
      _wallpaperRequest = null;
      update();
    }
  }

  Future<void> shareFilePdf(imageUrl) async {
    try {
      // Download file bytes
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final fileName = imageUrl.split('/').last;
        final filePath = '${tempDir.path}/$fileName';

        // Save the file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Share the file
        final result = await Share.shareXFiles([XFile(filePath)]);

        if (result.status == ShareResultStatus.success) {
          debugPrint('Thank you for sharing my PDF!');
        }
      } else {
        debugPrint('Failed to download file: HTTP ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  final GlobalKey previewContainer = GlobalKey();

  Future<void> handleUseAs(context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Call wallpaper plugin
    await WallpaperPlugin.useAsImageFromRepaintBoundary(previewContainer);

    // Hide loading dialog
    Navigator.of(context, rootNavigator: true).pop();
  }
}
