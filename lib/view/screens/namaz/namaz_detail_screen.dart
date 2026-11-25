import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import '../../../controller/namaz_controller.dart';
import '../../../data/model/response/namaz_model.dart';
import 'widget/namaz_labels.dart';
import 'widget/namaz_section_renderer.dart';

class NamazDetailScreen extends StatelessWidget {
  final NamazItem item;
  final NamazController controller;
  final bool modern;
  const NamazDetailScreen({
    super.key,
    required this.item,
    required this.controller,
    this.modern = false,
  });
  @override
  Widget build(BuildContext context) {
    final lang = namazLanguage(
      Get.locale?.languageCode ?? Localizations.localeOf(context).languageCode,
    );
    return Directionality(
      textDirection: ['ar', 'ur'].contains(lang)
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(item.title(lang)),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () => showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(nl('size', lang)),
                        Slider(
                          min: 20,
                          max: 52,
                          value: controller.arabicSize.value,
                          onChanged: (v) => controller.arabicSize.value = v,
                        ),
                        SwitchListTile(
                          title: Text(nl('translation', lang)),
                          value: controller.showTranslation.value,
                          onChanged: (v) =>
                              controller.showTranslation.value = v,
                        ),
                        SwitchListTile(
                          title: Text(nl('transliteration', lang)),
                          value: controller.showTransliteration.value,
                          onChanged: (v) =>
                              controller.showTransliteration.value = v,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: item.sections.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title(lang),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(item.description(lang)),
                    if (item.needsReview)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          nl('review', lang),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
            if (index == item.sections.length + 1) {
              return item.references.isEmpty
                  ? const SizedBox.shrink()
                  : ExpansionTile(
                      title: Text(nl('references', lang)),
                      children: [
                        for (final r in item.references)
                          ListTile(
                            title: Text(
                              (r['book'] ?? r['original_citation']).toString(),
                            ),
                            subtitle: Text(
                              [
                                r['original_citation'],
                                r['page'],
                                r['verification_status'],
                                r['notes'],
                              ].where((v) => v != null).join(' • '),
                            ),
                          ),
                      ],
                    );
            }
            return NamazSectionRenderer(
              section: item.sections[index - 1],
              item: item,
              lang: lang,
              modern: modern,
              controller: controller,
            );
          },
        ),
      ),
    );
  }
}
