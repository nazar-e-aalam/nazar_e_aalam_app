// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/memorable_days_model.dart';
import '../service/memorable_days_local_service.dart';

String memorableLanguage() {
  final locale = Get.locale ?? Get.deviceLocale;
  const allowed = {'en', 'gu', 'hi', 'sw', 'ar', 'ur'};
  final code = locale?.languageCode ?? 'gu';
  return allowed.contains(code) ? code : 'gu';
}

const memorableLabels = <String, Map<String, String>>{
  'title': {
    'en': 'Memorable Days',
    'gu': 'યાદગાર દિવસો',
    'hi': 'यादगार दिवस',
    'sw': 'Siku za Kukumbukwa',
    'ar': 'أيام لا تُنسى',
    'ur': 'یادگار دن',
  },
  'day': {
    'en': 'Hijri day',
    'gu': 'ચાંદ',
    'hi': 'चाँद',
    'sw': 'Siku ya Hijria',
    'ar': 'اليوم الهجري',
    'ur': 'چاند',
  },
  'unknown': {
    'en': 'Day not specified',
    'gu': 'ચાંદની તારીખ આપેલ નથી',
    'hi': 'चाँद की तारीख़ नहीं दी गई',
    'sw': 'Siku haijabainishwa',
    'ar': 'اليوم غير محدد',
    'ur': 'چاند کی تاریخ درج نہیں',
  },
  'empty': {
    'en': 'No events available',
    'gu': 'કોઈ પ્રસંગ ઉપલબ્ધ નથી',
    'hi': 'कोई घटना उपलब्ध नहीं',
    'sw': 'Hakuna matukio',
    'ar': 'لا توجد أحداث',
    'ur': 'کوئی واقعات دستیاب نہیں',
  },
  'retry': {
    'en': 'Retry',
    'gu': 'ફરી પ્રયાસ કરો',
    'hi': 'पुनः प्रयास करें',
    'sw': 'Jaribu tena',
    'ar': 'إعادة المحاولة',
    'ur': 'دوبارہ کوشش کریں',
  },
};
String memorableLabel(String key) =>
    localizedValue(memorableLabels[key] ?? {}, memorableLanguage());

class MemorableMonthLoader extends StatelessWidget {
  final Widget Function(BuildContext, List<MemorableMonth>) builder;
  const MemorableMonthLoader({super.key, required this.builder});
  @override
  Widget build(BuildContext context) => FutureBuilder<MemorableDaysData>(
    future: MemorableDaysLocalService.load(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unable to load Memorable Days: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    MemorableDaysLocalService.clearCache();
                    (context as Element).markNeedsBuild();
                  },
                  child: Text(memorableLabel('retry')),
                ),
              ],
            ),
          ),
        );
      }
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return builder(context, snapshot.data!.months);
    },
  );
}

String dayTitle(int? day) =>
    day == null ? memorableLabel('unknown') : '${memorableLabel('day')} $day';
