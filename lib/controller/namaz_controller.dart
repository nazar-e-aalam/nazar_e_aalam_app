import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../data/model/response/namaz_model.dart';

class NamazController extends GetxController {
  final items = <NamazItem>[].obs;
  final loading = true.obs;
  final error = RxnString();
  final query = ''.obs;
  final arabicSize = 30.0.obs;
  final showTranslation = true.obs;
  final showTransliteration = true.obs;
  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final root =
          jsonDecode(await rootBundle.loadString('assets/quran/namaz.json'))
              as Map<String, dynamic>;
      if (root['module'] != 'namaz' || root['schema_version'] != 1) {
        throw const FormatException('Unsupported Namaz dataset');
      }
      final parsed =
          (root['items'] as List)
              .map((e) => NamazItem(Map<String, dynamic>.from(e as Map)))
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      if (parsed.length != 15 || parsed.map((e) => e.id).toSet().length != 15) {
        throw const FormatException('Expected 15 unique Namaz entries');
      }
      for (final item in parsed) {
        if (item.sections.isEmpty) {
          throw const FormatException('Empty sections');
        }
      }
      items.assignAll(parsed);
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  List<NamazItem> filtered(String lang) {
    final q = query.value.trim().toLowerCase();
    return items
        .where(
          (e) => '${e.title(lang)} ${e.description(lang)} ${e.title('en')}'
              .toLowerCase()
              .contains(q),
        )
        .toList();
  }
}
