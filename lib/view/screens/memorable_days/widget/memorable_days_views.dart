// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
// import 'package:get/get.dart';
import '../model/memorable_days_model.dart';
import 'memorable_days_common.dart';

class MemorableMonthList extends StatelessWidget {
  final List<MemorableMonth> months;
  final bool modern;
  final void Function(MemorableMonth) onOpen;
  const MemorableMonthList({super.key, required this.months,
    required this.modern, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: months.length,
      itemBuilder: (context, index) {
        final month = months[index];
        final tile = ListTile(
          leading: CircleAvatar(
            backgroundColor: color.primaryContainer,
            foregroundColor: color.onPrimaryContainer,
            child: Text('${month.month}'),
          ),
          title: Text(localizedValue(month.name, memorableLanguage())),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => onOpen(month),
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: modern
            ? Card(clipBehavior: Clip.antiAlias, elevation: 0,
                color: color.surfaceContainerLow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: tile)
            : Card(child: tile),
        );
      },
    );
  }
}

class MemorableDayContent extends StatelessWidget {
  final MemorableMonth month;
  final bool modern;
  const MemorableDayContent({super.key, required this.month, required this.modern});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = memorableLanguage();
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        if (localizedValue(month.heading, language).isNotEmpty)
          Padding(padding: const EdgeInsets.fromLTRB(8, 6, 8, 18),
            child: Text(localizedValue(month.heading, language),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
        if (month.days.isEmpty) Center(child: Text(memorableLabel('empty'))),
        for (final day in month.days)
          Padding(padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: modern ? 0 : 1,
              color: modern ? scheme.surfaceContainerLow : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(modern ? 18 : 8)),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dayTitle(day.day), style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  for (var i = 0; i < day.events.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    Text(localizedValue(day.events[i].description, language),
                      textDirection: language == 'ar' || language == 'ur'
                        ? TextDirection.rtl : TextDirection.ltr,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                  ],
                ],
              )),
            ),
          ),
      ],
    );
  }
}
