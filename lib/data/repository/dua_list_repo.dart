import 'package:get/get_connect/http/src/response/response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nazar_e_alam/data/api/api_client.dart';
import 'package:nazar_e_alam/util/app_constants.dart';

class DuaRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  DuaRepo({required this.sharedPreferences, required this.apiClient});

  Future<Response> getDuaListRepo() async {
    return apiClient.getData(Endpoints.DUAS);
  }

  Future<Response> getDuaDetailsRepo(dynamic duaId) async {
    final id = duaId.toString();

    return apiClient.getData(
      '${Endpoints.DUAS.replaceFirst(RegExp(r"/+$"), "")}/$id',
    );
  }
}
