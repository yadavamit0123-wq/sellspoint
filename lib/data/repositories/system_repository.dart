import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';

class SystemRepository {
  Future<Map> fetchSystemSettings() async {
    Map<String, dynamic> parameters = {};

    Map<String, dynamic> response = await Api.get(
      queryParameters: parameters,
      url: Api.getSystemSettingsApi,
    );

    Constant.sponsorPackageText = response["data"]["sponser_package_text"] ?? '';
    Constant.packageTextColor = response["data"]["package_text_color"] ?? '';
    return response;
  }
}
