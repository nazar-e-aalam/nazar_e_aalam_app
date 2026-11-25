import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/model/dua_book_model.dart';
import '../data/repository/dua_book_repository.dart';

class DuaBookController extends ChangeNotifier {
  DuaBook? book;
  Object? error;
  bool loading = true, translation = true, transliteration = true;
  double fontSize = 30;
  String? lastSection;
  final Set<String> bookmarks = {};
  SharedPreferences? _prefs;
  bool _disposed = false;
  void refresh() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    refresh();
    try {
      book = await DuaBookRepository().load();
      _prefs = await SharedPreferences.getInstance();
      bookmarks.addAll(_prefs!.getStringList('dua_book_bookmarks') ?? []);
      lastSection = _prefs!.getString('dua_book_last_section');
      fontSize = (_prefs!.getDouble('dua_book_font') ?? 30)
          .clamp(22, 48)
          .toDouble();
      translation = _prefs!.getBool('dua_book_translation') ?? true;
      transliteration = _prefs!.getBool('dua_book_transliteration') ?? true;
    } catch (e) {
      error = e;
    } finally {
      loading = false;
      refresh();
    }
  }

  Future<void> toggle(String id) async {
    if (!bookmarks.remove(id)) bookmarks.add(id);
    refresh();
    await _prefs?.setStringList('dua_book_bookmarks', bookmarks.toList());
  }

  Future<void> visit(String id) async {
    lastSection = id;
    refresh();
    await _prefs?.setString('dua_book_last_section', id);
  }

  Future<void> settings({
    double? size,
    bool? meaning,
    bool? pronunciation,
  }) async {
    fontSize = size ?? fontSize;
    translation = meaning ?? translation;
    transliteration = pronunciation ?? transliteration;
    refresh();
    await _prefs?.setDouble('dua_book_font', fontSize);
    await _prefs?.setBool('dua_book_translation', translation);
    await _prefs?.setBool('dua_book_transliteration', transliteration);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
