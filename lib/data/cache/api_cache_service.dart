
import 'dart:convert';

import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class ApiCacheService extends GetxService {
  static const _boxName = 'api_response_cache_v1';

  late final Box<String> _box;

  final Map<String, _CacheEntry> _memory = {};

  Future<ApiCacheService> init() async {
    await Hive.initFlutter();

    _box = await Hive.openBox<String>(_boxName);

    return this;
  }

  dynamic get(String key, {bool allowExpired = false}) {
    final now = DateTime.now().millisecondsSinceEpoch;

    var entry = _memory[key];

    if (entry == null) {
      final raw = _box.get(key);

      if (raw == null) return null;

      try {
        entry = _CacheEntry.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
        _memory[key] = entry;
      } catch (e) {
        return null;
      }
    }

    if (!allowExpired && entry.expiresAt <= now) {
      return null;
    }

    return entry.data;
  }

  Future<void> put(String key, dynamic data, Duration ttl) async {
    if (data is! Map && data is! List) {
      return;
    }

    final entry = _CacheEntry(
      data: data,
      expiresAt: DateTime.now().add(ttl).millisecondsSinceEpoch,
    );

    _memory[key] = entry;

    await _box.put(key, jsonEncode(entry.toJson()));
  }

  Future<void> invalidate(String key) async {
    _memory.remove(key);
    await _box.delete(key);
  }

  Future<void> clear() async {
    _memory.clear();
    await _box.clear();
  }

  @override
  void onClose() {
    _box.close();
    super.onClose();
  }
}

class _CacheEntry {
  final dynamic data;
  final int expiresAt;

  _CacheEntry({
    required this.data,
    required this.expiresAt,
  });

  factory _CacheEntry.fromJson(Map<String, dynamic> json) {
    return _CacheEntry(
      data: json['data'],
      expiresAt: (json['expiresAt'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'data': data,
    'expiresAt': expiresAt,
  };
}
