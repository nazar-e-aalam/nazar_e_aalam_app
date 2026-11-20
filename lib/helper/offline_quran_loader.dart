import 'package:nazar_e_alam/helper/quran_local_data.dart';
import 'package:nazar_e_alam/helper/arabic_utils.dart';

class QuranLoader {
  QuranLoader._();

  static final QuranLoader instance = QuranLoader._();

  List<Map<String, dynamic>> _cachedVerses = [];
  String? _cachedLanguage;

  Future<void> loadAllVerses({int totalSurah = 114}) async {
    final language = QuranLocalData.language;

    if (_cachedLanguage == language && _cachedVerses.isNotEmpty) {
      return;
    }

    final verses = <Map<String, dynamic>>[];

    for (int i = 1; i <= totalSurah; i++) {
      final surahData = await QuranLocalData.surah(i);
      final data = surahData['data'] as Map<String, dynamic>;

      final chapter = Map<String, dynamic>.from(data['chapter'] as Map);

      final chapterInfoList = data['chapter_info'] as List;

      for (final info in chapterInfoList) {
        final page = info as Map<String, dynamic>;
        final pageVerses = page['page_verses'] as List;

        for (final item in pageVerses) {
          final v = item as Map<String, dynamic>;

          final verseNumber = v['verses_number'] ?? v['verse_number'];

          final arabic = (v['arabic_name'] ?? '').toString();

          verses.add({
            ...v,
            'text_without_taskeel':
                v['text_without_taskeel'] ?? removeDiacritics(arabic),
            'verse_number': verseNumber,
            'verse_key': '${chapter['id'] ?? v['chapter_id']}:$verseNumber',
            'page_number': page['page_number'],
            'page_key': page['page_key'],
            'chapter': chapter,
          });
        }
      }
    }

    _cachedVerses = verses;
    _cachedLanguage = language;
  }

  List<Map<String, dynamic>> get allVerses => _cachedVerses;
}
