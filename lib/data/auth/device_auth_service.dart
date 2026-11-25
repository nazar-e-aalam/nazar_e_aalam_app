import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DeviceAuthService extends GetxService {
  DeviceAuthService({required this.baseUrl, this.debugMode = false});

  final String baseUrl;
  final bool debugMode;
  static const _storage = FlutterSecureStorage();
  final http.Client _client = http.Client();

  String get _prefix => debugMode ? 'device_auth_debug_' : 'device_auth_';
  String get _uuidKey => '${_prefix}uuid';
  String get _accessKey => '${_prefix}access_token';
  String get _refreshKey => '${_prefix}refresh_token';
  String get _expiryKey => '${_prefix}access_expiry';

  Uri _uri(String path) => Uri.parse(
    '${baseUrl.replaceFirst(RegExp(r'/+$'), '')}/${path.replaceFirst(RegExp(r'^/+'), '')}',
  );

  String get _registerPath =>
      debugMode ? 'auth/device/register/debug' : 'auth/device/register';
  String get _refreshPath =>
      debugMode ? 'auth/device/refresh/debug' : 'auth/refresh';

  String? _accessToken;
  String? _refreshToken;
  DateTime? _expiresAt;
  Future<String?>? _registrationFuture;
  Future<String?>? _refreshFuture;

  Future<DeviceAuthService> init() async {
    _accessToken = await _storage.read(key: _accessKey);
    _refreshToken = await _storage.read(key: _refreshKey);
    final expiry = await _storage.read(key: _expiryKey);
    _expiresAt = expiry == null ? null : DateTime.tryParse(expiry);
    return this;
  }

  bool get hasValidToken =>
      _accessToken != null &&
      _accessToken!.isNotEmpty &&
      _expiresAt != null &&
      DateTime.now().isBefore(
        _expiresAt!.subtract(const Duration(seconds: 30)),
      );

  Future<String> _deviceUuid() async {
    final existing = await _storage.read(key: _uuidKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = const Uuid().v4();
    await _storage.write(key: _uuidKey, value: generated);
    return generated;
  }

  Future<String> _saveTokens(Map<String, dynamic> data) async {
    final access = data['access_token'];
    final refresh = data['refresh_token'];
    final seconds = data['expires_in'];
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty ||
        seconds is! num ||
        seconds <= 0) {
      throw const FormatException('Invalid authentication response');
    }
    final expiry = DateTime.now().add(Duration(seconds: seconds.toInt()));
    // Persist refresh first so an interrupted write can still be recovered.
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());
    _refreshToken = refresh;
    _accessToken = access;
    _expiresAt = expiry;
    debugPrint(
      'Device credentials saved (${debugMode ? 'debug' : 'production'})',
    );
    return access;
  }

  Future<String?> getAccessToken() async {
    if (hasValidToken) return _accessToken;
    if (_refreshToken != null && _refreshToken!.isNotEmpty) {
      final token = await refreshAccessToken();
      if (token != null) return token;
      // Production must not silently create a replacement identity.
      if (!debugMode) return null;
      // A debug session can be recreated only when the server confirms expiry.
      // Network errors and other failures do not trigger re-registration.
      if (!_debugSessionExpired) return null;
    }
    if (!debugMode && _accessToken != null && _accessToken!.isNotEmpty) {
      return null;
    }
    return registerDevice();
  }

  bool _debugSessionExpired = false;

  Future<String?> refreshAccessToken() {
    return _refreshFuture ??= _refresh().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _refresh() async {
    final refresh = _refreshToken;
    if (refresh == null || refresh.isEmpty) return null;
    try {
      final response = await _client
          .post(
            _uri(_refreshPath),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic>) {
          throw const FormatException('Invalid token response');
        }
        _debugSessionExpired = false;
        return await _saveTokens(data);
      }
      if (debugMode && response.statusCode == 401) {
        // Debug refresh 401 means this opaque token is no longer usable.
        // Another registration can start a fresh one-hour session.
        _debugSessionExpired = true;
      }
      debugPrint('Device token response ${response.body}');
      debugPrint('Device token refresh rejected: HTTP ${response.statusCode}');
      return null;
    } on TimeoutException {
      debugPrint('Device token refresh timed out');
      return null;
    } catch (e) {
      debugPrint('Device token refresh failed: ${e.runtimeType}');
      return null;
    }
  }

  Future<String?> registerDevice() {
    if (hasValidToken) return Future.value(_accessToken);
    if (_refreshToken != null &&
        _refreshToken!.isNotEmpty &&
        !(debugMode && _debugSessionExpired)) {
      return refreshAccessToken();
    }
    return _registrationFuture ??= _registerDevice().whenComplete(() {
      _registrationFuture = null;
    });
  }

  Future<String?> _registerDevice() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      debugPrint('Device registration unsupported on this platform');
      return null;
    }
    final platform = Platform.isAndroid ? 'android' : 'ios';
    final uuid = await _deviceUuid();
    try {
      final response = await _client
          .post(
            _uri(_registerPath),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              if (!debugMode &&
                  _accessToken != null &&
                  _accessToken!.isNotEmpty)
                'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({'device_uuid': uuid, 'platform': platform}),
          )
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('Device registration failed: HTTP ${response.statusCode}');
        return null;
      }
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Invalid registration response');
      }
      final token = await _saveTokens(data);
      _debugSessionExpired = false;
      debugPrint(
        'Device registered ($platform, ${debugMode ? 'debug' : 'production'})',
      );
      return token;
    } on TimeoutException {
      debugPrint('Device registration timed out');
      return null;
    } catch (e) {
      debugPrint('Device registration failed: ${e.runtimeType}');
      return null;
    }
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }
}
