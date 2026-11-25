// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../../data/model/wazaif_data.dart';
import '../wazaif_detail.dart';
import '../../../base/custom_app_bar.dart';
import 'package:nazar_e_alam/view/base/modern/modern_components.dart';

class WazaifModernScreen extends StatelessWidget {
  const WazaifModernScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      // appBar: AppBar(title: const Text('Wazaif'), centerTitle: false),
      appBar: const CustomAppBar(title: 'Wazaif', isBackButtonExist: true),
      body: FutureBuilder<List<Wazifa>>(
        future: WazaifData.load(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load Wazaif: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('No Wazaif available'));
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [scheme.primary, scheme.primary],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.auto_stories_rounded,
                        color: scheme.onPrimary,
                        size: 32,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Daily Wazaif',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${items.length} recitation collections',
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: .85),
                        ),
                      ),
                    ],
                  ),
                );
              }
              final item = items[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            WazaifDetailScreen(wazifa: item, modern: true),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Container(
                          //   width: 48,
                          //   height: 48,
                          //   alignment: Alignment.center,
                          //   decoration: BoxDecoration(
                          //     color: scheme.primaryContainer,
                          //     borderRadius: BorderRadius.circular(15),
                          //   ),
                          //   child: Text(
                          //     index.toString().padLeft(2, '0'),
                          //     style: TextStyle(
                          //       color: scheme.onPrimaryContainer,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                          ModernTitleBadge(number: index, size: 44),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  textDirection: WazaifData.rtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  textDirection: WazaifData.rtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
