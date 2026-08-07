import 'dart:io';

import 'package:eClassify/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:eClassify/data/model/system_settings_model.dart';
import 'package:eClassify/ui/screens/widgets/version_update_dialog.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/version_utility.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Checks admin version settings and shows [VersionUpdateDialog] when needed.
abstract final class AppUpdateHelper {
  static Future<void> checkAndPrompt(
    BuildContext context,
    FetchSystemSettingsCubit settingsCubit,
  ) async {
    final remoteVersion = settingsCubit.getSetting(
      Platform.isIOS
          ? SystemSetting.iosVersion
          : SystemSetting.androidVersion,
    )?.toString();

    if (remoteVersion == null || remoteVersion.isEmpty) return;

    final forceUpdate =
        settingsCubit.getSetting(SystemSetting.forceUpdate)?.toString() == '1';

    final packageInfo = await PackageInfo.fromPlatform();
    final currentLabel = '${packageInfo.version}+${packageInfo.buildNumber}';

    if (!VersionUtility.isRemoteVersionNewer(
      remote: remoteVersion,
      current: currentLabel,
    )) {
      return;
    }

    Constant.isUpdateAvailable = true;
    Constant.newVersionNumber = remoteVersion;

    if (!context.mounted) return;

    Future.microtask(() {
      if (!context.mounted) return;
      final storeUrl = Platform.isIOS
        ? Constant.appstoreURLios
        : Constant.playstoreURLAndroid;

    VersionUpdateDialog.show(
      context,
      availableVersionLabel: remoteVersion,
      isForceUpdate: forceUpdate,
      storeUrl: storeUrl,
    );
    });
  }
}
