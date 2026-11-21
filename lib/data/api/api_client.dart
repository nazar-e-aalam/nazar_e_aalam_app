// ignore_for_file: library_prefixes, empty_catches
import 'dart:async';
import 'dart:io';

import 'dart:convert';
import 'package:nazar_e_alam/data/model/response/error_response_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as Http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/auth/device_auth_service.dart';
import 'package:nazar_e_alam/data/cache/api_cache_service.dart';
import 'package:nazar_e_alam/data/cache/api_cache_policy.dart';

class ApiAuthenticationException implements Exception {
  final String message;

  const ApiAuthenticationException(this.message);

  @override
  String toString() => message;
}

class ApiClient extends GetxService {
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  static const String noInternetMessage =
      'Connection to API server failed due to internet connection';
  final int timeoutInSeconds = 120;
  static const int maxGetRetries = 3;
  static const Duration retryBaseDelay = Duration(seconds: 2);
  static const Duration retryMaxDelay = Duration(seconds: 10);
  static const Duration retryRequestTimeout = Duration(seconds: 15);
  final Map<String, String> _mainHeaders = {
    'Content-Type': 'application/json; charset=UTF-8',
  };
  final DeviceAuthService _auth = Get.find<DeviceAuthService>();
  final Http.Client _httpClient = Http.Client();
  final ApiCacheService _cache = Get.find<ApiCacheService>();
  final Map<String, Future<Response>> _pendingGets = {};

  Map<String, String> _buildHeaders({
    Map<String, String>? headers,
    String? accessToken,
  }) {
    return {
      ..._mainHeaders,
      ...?headers,
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  @override
  void onClose() {
    _httpClient.close();
    super.onClose();
  }

  ApiClient({required this.appBaseUrl, required this.sharedPreferences});

  Future<Http.Response> _sendRequest(
    String method,
    Uri uri, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = false,
    Duration? requestTimeout,
  }) async {
    String? token;

    if (requiresAuth) {
      token = await _auth.getAccessToken();

      if (token == null) {
        throw const ApiAuthenticationException('Authentication unavailable');
      }
    }

    Future<Http.Response> send(String? accessToken) {
      final requestHeaders = _buildHeaders(
        headers: headers,
        accessToken: accessToken,
      );

      switch (method) {
        case 'GET':
          return _httpClient.get(uri, headers: requestHeaders);

        case 'POST':
          return _httpClient.post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(body),
          );

        case 'PUT':
          return _httpClient.put(
            uri,
            headers: requestHeaders,
            body: jsonEncode(body),
          );

        case 'DELETE':
          return _httpClient.delete(uri, headers: requestHeaders);

        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }
    }

    var response = await send(
      token,
    ).timeout(requestTimeout ?? Duration(seconds: timeoutInSeconds));
    if (requiresAuth && response.statusCode == 401) {
      final refreshedToken = await _auth.refreshAccessToken();

      if (refreshedToken != null) {
        response = await send(
          refreshedToken,
        ).timeout(requestTimeout ?? Duration(seconds: timeoutInSeconds));
      }
    }

    return response;
  }

  Future<Http.Response> _sendWithRetry(
    String method,
    Uri uri, {
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    final canRetry = method == 'GET';
    final maxAttempts = canRetry ? maxGetRetries + 1 : 1;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _sendRequest(
          method,
          uri,
          body: body,
          headers: headers,
          requiresAuth: requiresAuth,
          requestTimeout: retryRequestTimeout,
        );

        final retryableStatus =
            response.statusCode == 429 ||
            response.statusCode == 500 ||
            response.statusCode == 502 ||
            response.statusCode == 503 ||
            response.statusCode == 504;

        if (!canRetry || !retryableStatus || attempt == maxAttempts) {
          return response;
        }

        final retryAfter = response.headers['retry-after'];
        Duration? serverDelay;

        if (retryAfter != null) {
          final seconds = int.tryParse(retryAfter);

          if (seconds != null && seconds >= 0) {
            serverDelay = Duration(seconds: seconds);
          } else {
            final date = HttpDate.parse;
            try {
              final until = date(retryAfter).difference(DateTime.now().toUtc());
              if (!until.isNegative) {
                serverDelay = until;
              }
            } on FormatException {
              // Invalid Retry-After header.
            }
          }
        }

        final backoff = Duration(
          milliseconds: retryBaseDelay.inMilliseconds * (1 << (attempt - 1)),
        );

        final delay =
            serverDelay ?? (backoff > retryMaxDelay ? retryMaxDelay : backoff);

        if (kDebugMode) {
          debugPrint(
            'API RETRY: $method $uri '
            'HTTP ${response.statusCode} '
            'attempt $attempt/$maxAttempts '
            'delay ${delay.inMilliseconds}ms',
          );
        }

        await Future.delayed(delay);
      } on SocketException catch (e) {
        if (!canRetry || attempt == maxAttempts) rethrow;
        await _retryDelay(attempt, e);
      } on TimeoutException catch (e) {
        if (!canRetry || attempt == maxAttempts) rethrow;
        await _retryDelay(attempt, e);
      } on Http.ClientException catch (e) {
        if (!canRetry || attempt == maxAttempts) rethrow;
        await _retryDelay(attempt, e);
      }
    }

    throw StateError('Retry loop ended unexpectedly');
  }

  Future<void> _retryDelay(int attempt, Object error) async {
    final backoff = Duration(
      milliseconds: retryBaseDelay.inMilliseconds * (1 << (attempt - 1)),
    );

    final delay = backoff > retryMaxDelay ? retryMaxDelay : backoff;

    if (kDebugMode) {
      debugPrint(
        'API NETWORK RETRY: '
        'attempt $attempt, '
        'waiting ${delay.inSeconds}s, '
        'error: $error',
      );
    }

    await Future.delayed(delay);
  }

  String _cacheKey(Uri uri) {
    final sorted = uri.queryParametersAll.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final parameters = <String, List<String>>{
      for (final entry in sorted) entry.key: [...entry.value]..sort(),
    };

    return uri.replace(queryParameters: parameters).toString();
  }

  Response _cachedResponse(dynamic data) {
    return Response(
      statusCode: 200,
      statusText: 'OK',
      body: data,
      bodyString: jsonEncode(data),
    );
  }

  Future<Response> _fetchGet(
    Uri requestUri, {
    Map<String, String>? headers,
    Duration? cacheDuration,
    bool offlineFallback = true,
    required String cacheKey,
  }) async {
    try {
      final response0 = await _sendWithRetry(
        'GET',
        requestUri,
        headers: headers,
      );

      final response = handleResponse(response0);

      if (response.statusCode == 200 &&
          cacheDuration != null &&
          (response.body is Map || response.body is List)) {
        await _cache.put(cacheKey, response.body, cacheDuration);
      }

      if (offlineFallback &&
          (response.statusCode == 1 ||
              (response.statusCode != null && response.statusCode! >= 500))) {
        final oldData = _cache.get(cacheKey, allowExpired: true);

        if (oldData != null) {
          return _cachedResponse(oldData);
        }
      }

      return response;
    } on ApiAuthenticationException catch (e) {
      return Response(statusCode: 401, statusText: e.message);
    } catch (e) {
      if (offlineFallback) {
        final oldData = _cache.get(cacheKey, allowExpired: true);

        if (oldData != null) {
          return _cachedResponse(oldData);
        }
      }

      if (kDebugMode) {
        debugPrint('GET request failed: $e');
      }

      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    bool requiresAuth = false,
    Duration? cacheDuration,
    bool forceRefresh = false,
    bool offlineFallback = false,
  }) async {
    final baseUri = Uri.parse('$appBaseUrl$uri');

    final requestUri = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        if (query != null)
          ...query.map((key, value) => MapEntry(key, value.toString())),
      },
    );
    final effectiveCacheDuration =
        cacheDuration ?? ApiCachePolicy.durationFor(uri);
    // Authenticated or custom-header requests are not cached.
    // This prevents mixing responses from different users,
    // languages, or authorization contexts.
    final useCache =
        !requiresAuth &&
        headers == null &&
        effectiveCacheDuration != null &&
        effectiveCacheDuration > Duration.zero;
    if (!useCache) {
      try {
        final response0 = await _sendWithRetry(
          'GET',
          requestUri,
          headers: headers,
          requiresAuth: requiresAuth,
        );

        return handleResponse(response0);
      } on ApiAuthenticationException catch (e) {
        return Response(statusCode: 401, statusText: e.message);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('GET request failed: $e');
        }

        return const Response(statusCode: 1, statusText: noInternetMessage);
      }
    }

    final key = _cacheKey(requestUri);

    if (!forceRefresh) {
      final cached = _cache.get(key);

      if (cached != null) {
        if (kDebugMode) {
          debugPrint('CACHE HIT: $uri');
        }

        return _cachedResponse(cached);
      }
    }

    // Share one in-flight request for identical URLs.
    // Requests with different fallback policies are separated.
    final pendingKey = '$key|offline=$offlineFallback';

    final existing = _pendingGets[pendingKey];

    if (existing != null) {
      if (kDebugMode) {
        debugPrint('REQUEST DEDUPLICATED: $uri');
      }

      return existing;
    }

    final future = _fetchGet(
      requestUri,
      cacheKey: key,
      cacheDuration: effectiveCacheDuration,
      offlineFallback: offlineFallback,
    );

    _pendingGets[pendingKey] = future;

    try {
      return await future;
    } finally {
      _pendingGets.remove(pendingKey);
    }
  }

  Future<Response> postData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      if (kDebugMode) {
        print('====> API Body: $body');
        print(appBaseUrl + uri);
      }

      final response0 = await _sendWithRetry(
        'POST',
        Uri.parse('$appBaseUrl$uri'),
        body: body,
        headers: headers,
        requiresAuth: requiresAuth,
      );
      Response response = handleResponse(response0);
      if (kDebugMode) {
        print(response.body);
      }

      if (kDebugMode) {
        print(
          '====> API Response: [${response.statusCode}] $uri\n${response.body}',
        );
      }

      return response;
    } on ApiAuthenticationException catch (e) {
      return Response(statusCode: 401, statusText: e.message);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> putData(
    String uri,
    dynamic body, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      if (kDebugMode) {
        print('====> API Body: $body');
      }

      final response0 = await _sendWithRetry(
        'PUT',
        Uri.parse('$appBaseUrl$uri'),
        body: body,
        headers: headers,
        requiresAuth: requiresAuth,
      );
      Response response = handleResponse(response0);

      if (kDebugMode) {
        print(
          '====> API Response: [${response.statusCode}] $uri\n${response.body}',
        );
      }

      return response;
    } on ApiAuthenticationException catch (e) {
      return Response(statusCode: 401, statusText: e.message);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Future<Response> deleteData(
    String uri, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final response0 = await _sendWithRetry(
        'DELETE',
        Uri.parse('$appBaseUrl$uri'),
        headers: headers,
        requiresAuth: requiresAuth,
      );
      Response response = handleResponse(response0);

      if (kDebugMode) {
        print(
          '====> API Response: [${response.statusCode}] $uri\n${response.body}',
        );
      }

      return response;
    } on ApiAuthenticationException catch (e) {
      return Response(statusCode: 401, statusText: e.message);
    } catch (e) {
      return const Response(statusCode: 1, statusText: noInternetMessage);
    }
  }

  Response handleResponse(Http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (e) {}
    Response response0 = Response(
      body: body ?? response.body,
      bodyString: response.body.toString(),
      headers: response.headers,
      statusCode: response.statusCode,
      statusText: response.reasonPhrase,
    );
    if ((response0.statusCode ?? 0) >= 400 &&
        response0.body != null &&
        response0.body is! String) {
      if (response0.body.toString().startsWith('{errors: [{code:')) {
        ErrorResponse errorResponse = ErrorResponse.fromJson(response0.body);
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: errorResponse.errors![0].message,
        );
      } else if (response0.body.toString().startsWith('{message')) {
        response0 = Response(
          statusCode: response0.statusCode,
          body: response0.body,
          statusText: response0.body['message'],
        );
      }
    } else if ((response0.statusCode ?? 0) >= 400 && response0.body == null) {
      response0 = const Response(statusCode: 0, statusText: noInternetMessage);
    }
    return response0;
  }
}
