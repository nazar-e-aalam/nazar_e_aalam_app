
import 'package:nazar_e_alam/util/app_constants.dart';

class ApiCachePolicy {
  ApiCachePolicy._();

  static Duration? durationFor(String uri) {
    final path = Uri.parse(uri).path.replaceFirst(RegExp(r'^/+'), '');

    // New FastAPI endpoints
    switch (path) {
      case Endpoints.RECITERS:
        return const Duration(hours: 24);

      case Endpoints.PRAYER_CITIES:
        return const Duration(days: 1);

      case Endpoints.SURAH_LIST:
        return const Duration(days: 1);

      case Endpoints.DHIKRS:
        return const Duration(hours: 1);

      case Endpoints.DUAS:
        return const Duration(hours: 24);

      case Endpoints.WALLPAPERS:
        return const Duration(hours: 2);

      case Endpoints.SIFAT_NAMES:
        return const Duration(days: 7);
    }

    // Dynamic reciter endpoints
    if (RegExp(r'^reciters/[^/]+/surahs/?$').hasMatch(path)) {
      return const Duration(hours: 24);
    }

    if (RegExp(r'^reciters/[^/]+/?$').hasMatch(path)) {
      return const Duration(hours: 24);
    }

    // Legacy API endpoints
    switch (path) {
      case 'chapters':
        return const Duration(days: 7);

      case 'duas':
        return const Duration(days: 7);

      case 'reciters':
        return const Duration(hours: 24);

      case 'wallpapers':
        return const Duration(hours: 6);

      case 'prayer-times/cities':
        return const Duration(days: 7);
    }

    // Legacy detail endpoints
    if (path.startsWith('duas') ||
        path.startsWith('dhikrs')) {
      return const Duration(hours: 24);
    }

    if (path.endsWith('verses') ||
        RegExp(r'^chapters/[^/]+/verses/?$').hasMatch(path)) {
      return const Duration(days: 7);
    }
    return null;
  }
}
