import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DeviceAuthService extends GetxService {
  DeviceAuthService({required this.baseUrl});

  final String baseUrl;

  static const _storage = FlutterSecureStorage();
  static const _refreshKey = 'device_auth_refresh_token';
  String? _refreshToken;
  Future<String?>? _refreshFuture;
  static const _uuidKey = 'device_auth_uuid';
  static const _accessKey = 'device_auth_access_token';
  static const _expiryKey = 'device_auth_access_expiry';

  final http.Client _client = http.Client();

  Future<String?>? _registrationFuture;

  String? _accessToken;
  DateTime? _expiresAt;

  Future<DeviceAuthService> init() async {
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);

    final expiry = await _storage.read(key: _expiryKey);
    _expiresAt = expiry == null ? null : DateTime.tryParse(expiry);

    return this;
  }

  Future<String> _saveTokens(Map<String, dynamic> data) async {
    final access = data['access_token'] as String?;
    final refresh = data['refresh_token'] as String?;
    final expiresIn = (data['expires_in'] as num?)?.toInt();

    if (access == null ||
        access.isEmpty ||
        refresh == null ||
        refresh.isEmpty ||
        expiresIn == null ||
        expiresIn <= 0) {
      throw const FormatException('Invalid authentication response');
    }

    final expiry = DateTime.now().add(Duration(seconds: expiresIn));

    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());

    _accessToken = access;
    _refreshToken = refresh;
    _expiresAt = expiry;

    return access;
  }

  Future<String> _deviceUuid() async {
    final existing = await _storage.read(key: _uuidKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final generated = const Uuid().v4();
    await _storage.write(key: _uuidKey, value: generated);

    return generated;
  }

  bool get hasValidToken {
    if (_accessToken == null || _expiresAt == null) {
      return false;
    }

    return DateTime.now().isBefore(
      _expiresAt!.subtract(const Duration(minutes: 5)),
    );
  }

  Future<String?> refreshAccessToken() {
    return _refreshFuture ??= _refresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _refresh() async {
    final refresh = _refreshToken;

    if (refresh == null || refresh.isEmpty) {
      return null;
    }

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/refresh'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return await _saveTokens(data);
    } catch (_) {
      // Keep existing credentials on network failures.
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    if (hasValidToken) {
      return _accessToken;
    }

    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      return refreshAccessToken();
    }

    // Only register if this installation has never received credentials.
    if (_accessToken == null && await _storage.read(key: _uuidKey) == null) {
      return registerDevice();
    }

    return null;
  }

  Future<String?> registerDevice() {
    if (hasValidToken) {
      return Future.value(_accessToken);
    }

    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      return refreshAccessToken();
    }

    return _registrationFuture ??= _registerDevice().whenComplete(() {
      _registrationFuture = null;
    });
  }

  Future<String?> _registerDevice() async {
    // An expired device token cannot currently be recovered
    // through the supplied backend contract.
    if (_accessToken != null && !hasValidToken) {
      return null;
    }

    final uuid = await _deviceUuid();

    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/auth/device/register'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'device_uuid': uuid, 'platform': 'android'}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      return await _saveTokens(data);
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
