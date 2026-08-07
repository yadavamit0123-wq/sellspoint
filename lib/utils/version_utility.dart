import 'package:eClassify/data/model/version.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract final class VersionUtility {
  static Future<String> currentVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  static bool isRemoteVersionNewer({
    required String remote,
    required String current,
  }) {
    try {
      return Version.fromString(remote) > Version.fromString(current);
    } catch (_) {
      final remotePlain = remote.split('+').first;
      final currentPlain = current.split('+').first;
      return HelperUtils.comparableVersion(remotePlain) >
          HelperUtils.comparableVersion(currentPlain);
    }
  }
}
