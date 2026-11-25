// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../data/model/wazaif_data.dart';
import 'wazaif_detail.dart';

class WazaifClassicScreen extends StatelessWidget {
  const WazaifClassicScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Wazaif')),
    body: FutureBuilder<List<Wazifa>>(
      future: WazaifData.load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _error(snapshot.error!);
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Center(child: Text('No Wazaif available'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  item.name,
                  textDirection: WazaifData.rtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
                subtitle: Text(
                  item.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: WazaifData.rtl
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        WazaifDetailScreen(wazifa: item, modern: false),
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

Widget _error(Object error) => Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Text(
      'Unable to load Wazaif JSON. Check the asset path and JSON syntax.\n$error',
      textAlign: TextAlign.center,
    ),
  ),
);
