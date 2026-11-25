import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/model/mubarak_name_model.dart';
import 'package:nazar_e_alam/data/repository/mubarak_names_repository.dart';

class MubarakNamesController extends GetxController {
  final MubarakNamesRepository repository;

  MubarakNamesController({required this.repository});

  final Map<MubarakNamesCategory, List<MubarakName>> _cache = {};

  MubarakNamesCategory currentCategory = MubarakNamesCategory.allah;

  List<MubarakName> names = [];
  MubarakName? selectedName;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCategory(MubarakNamesCategory category) async {
    currentCategory = category;
    selectedName = null;
    errorMessage = null;

    final cached = _cache[category];
    if (cached != null) {
      names = cached;
      isLoading = false;
      update();
      return;
    }

    names = [];
    isLoading = true;
    update();

    try {
      final result = await repository.load(category);
      _cache[category] = result;

      if (currentCategory == category) {
        names = result;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Mubarak Names error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      if (currentCategory == category) {
        errorMessage = 'Unable to load names.';
      }
    } finally {
      if (currentCategory == category) {
        isLoading = false;
        update();
      }
    }
  }

  void selectName(MubarakName name) {
    selectedName = name;
    update();
  }

  MubarakName? findById(int id) {
    for (final name in names) {
      if (name.id == id) return name;
    }
    return null;
  }
}
