
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:nazar_e_alam/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';

class WallpaperRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  WallpaperRepo({
    required this.sharedPreferences,
    required this.apiClient,
  });

  Future<Response> getWallpaperLisRepo({
    int skip = 0,
    int limit = 50,
    bool refresh = false,
  }) {
    return apiClient.getData(
      Endpoints.WALLPAPERS, query: {'skip': skip, 'limit': limit}, forceRefresh: refresh
    );
  }
}
