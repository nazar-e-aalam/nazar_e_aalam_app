import 'package:nazar_e_alam/helper/quran_local_data.dart';
import 'package:nazar_e_alam/helper/arabic_utils.dart';

class QuranLoader {
  QuranLoader._();

  static final QuranLoader instance = QuranLoader._();

  // ==================== CACHE ====================

  final Map<String, List<Map<String, dynamic>>> _cache = {};

  final Map<String, Future<List<Map<String, dynamic>>>> _pendingRequests = {};

  List<Map<String, dynamic>> _cachedVerses = [];

  String? _cachedLanguage;

  int _requestId = 0;

  // Keep memory usage controlled.
  static const int _maxCachedLanguages = 2;

  // ==================== GETTERS ====================

  List<Map<String, dynamic>> get allVerses => _cachedVerses;

  String? get cachedLanguage => _cachedLanguage;

  // ==================== LOAD ALL VERSES ====================

  Future<List<Map<String, dynamic>>> loadAllVerses({
    int totalSurah = 114,
    String? language,
  }) async {
    if (totalSurah < 1 || totalSurah > 114) {
      throw RangeError.range(totalSurah, 1, 114, 'totalSurah');
    }

    final resolvedLanguage = QuranLocalData.resolveLanguage(language);

    final requestId = ++_requestId;

    final cacheKey = '$resolvedLanguage:$totalSurah';

    final cached = _cache.remove(cacheKey);

    if (cached != null) {
      // Move recently accessed entry to the end.
      _cache[cacheKey] = cached;

      _cachedVerses = cached;
      _cachedLanguage = resolvedLanguage;

      return cached;
    }

    // Do not expose old-language verses while loading.
    _cachedVerses = [];
    _cachedLanguage = null;

    // Reuse an existing request for the same language.
    final pending = _pendingRequests.putIfAbsent(
      cacheKey,
      () => _loadVerses(language: resolvedLanguage, totalSurah: totalSurah),
    );

    try {
      final verses = await pending;

      _cache.remove(cacheKey);
      _cache[cacheKey] = verses;

      // Evict the least recently accessed cache entry.
      while (_cache.length > _maxCachedLanguages) {
        _cache.remove(_cache.keys.first);
      }

      // Only the latest request updates the active cache.
      if (requestId == _requestId) {
        _cachedVerses = verses;
        _cachedLanguage = resolvedLanguage;
      }

      return verses;
    } finally {
      if (identical(_pendingRequests[cacheKey], pending)) {
        _pendingRequests.remove(cacheKey);
      }
    }
  }

  // ==================== ASSET LOADING ====================

  Future<List<Map<String, dynamic>>> _loadVerses({
    required String language,
    required int totalSurah,
  }) async {
    final verses = <Map<String, dynamic>>[];

    for (int i = 1; i <= totalSurah; i++) {
      // Always use the captured language.
      final surahData = await QuranLocalData.surah(i, language: language);

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

            'language': language,

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

    return List<Map<String, dynamic>>.unmodifiable(verses);
  }
}
