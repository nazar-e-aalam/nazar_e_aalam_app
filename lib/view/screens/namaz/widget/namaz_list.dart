import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../../../controller/namaz_controller.dart';
import '../../../../data/model/response/namaz_model.dart';
import '../namaz_detail_screen.dart';
import '../modern/modern_namaz_detail_screen.dart';
import 'namaz_labels.dart';

class NamazList extends StatefulWidget {
  final bool modern;
  final bool? appBackButton;
  const NamazList({super.key, required this.modern, this.appBackButton});
  @override
  State<NamazList> createState() => _NamazListState();
}

class _NamazListState extends State<NamazList> {
  late final NamazController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<NamazController>()
        ? Get.find<NamazController>()
        : Get.put(NamazController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final lang = namazLanguage(
      Get.locale?.languageCode ?? Localizations.localeOf(context).languageCode,
    );
    final theme = Theme.of(context);
    return Directionality(
      textDirection: ['ar', 'ur'].contains(lang)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(nl('title', lang)),
          automaticallyImplyLeading: widget.appBackButton ?? true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                initialValue: controller.query.value,
                onChanged: (v) => controller.query.value = v,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: nl('search', lang),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(widget.modern ? 24 : 6),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.loading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.value != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(nl('error', lang)),
                        TextButton(
                          onPressed: controller.load,
                          child: Text(nl('retry', lang)),
                        ),
                      ],
                    ),
                  );
                }
                final items = controller.filtered(lang);
                if (items.isEmpty) {
                  return Center(child: Text(nl('empty', lang)));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => widget.modern
                      ? const SizedBox(height: 10)
                      : const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final tile = ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        child: Text('${item.order}'),
                      ),
                      title: Text(
                        item.title(lang),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        item.description(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Get.to(
                        () => widget.modern
                            ? ModernNamazDetailScreen(
                                item: item,
                                controller: controller,
                              )
                            : NamazDetailScreen(
                                item: item,
                                controller: controller,
                              ),
                      ),
                    );
                    return widget.modern
                        ? Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: theme.dividerColor.withValues(alpha: .4),
                              ),
                            ),
                            child: tile,
                          )
                        : tile;
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
