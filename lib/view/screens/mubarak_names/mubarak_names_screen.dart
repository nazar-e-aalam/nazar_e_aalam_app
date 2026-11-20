// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nazar_e_alam/data/repository/mubarak_names_repository.dart';
import 'package:nazar_e_alam/view/base/custom_app_bar.dart';
import 'mubarak_names_list_wrapper.dart';
import 'mubarak_extra_categories.dart';

class MubarakNamesScreen extends StatelessWidget {
  final bool appBackButton;
  const MubarakNamesScreen({super.key, required this.appBackButton});

  @override
  Widget build(BuildContext context) {
    final existing = [
      (MubarakNamesCategory.allah, '99 Names of Allah ﷻ', 'أَسْمَاءُ اللَّهِ الْحُسْنَى', Icons.auto_awesome),
      (MubarakNamesCategory.muhammad, '99 Names of Muhammad ﷺ', 'أَسْمَاءُ النَّبِيِّ ﷺ', Icons.menu_book_rounded),
      (MubarakNamesCategory.ghaus, '11 Names of Ghaus-e-Azam', 'غوثِ اعظم', Icons.star_rounded),
    ];
    return Scaffold(
      appBar: CustomAppBar(title: 'Mubarak Names', isBackButtonExist: appBackButton),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < existing.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    child: Icon(existing[i].$4, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(existing[i].$2, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(existing[i].$3),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Get.to(() => MubarakNamesListWrapper(category: existing[i].$1)),
                ),
              ),
            ),
          const MubarakExtraCategories(modern: false),
        ],
      ),
    );
  }
}
