import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/background_upload_utility.dart';
import 'package:eClassify/utils/my_ads_refresh.dart';
import 'package:eClassify/utils/reel_feed_refresh.dart';
import 'package:eClassify/utils/reel_subscription_refresh.dart';
import 'package:eClassify/utils/reel_upload_constants.dart';
import 'package:eClassify/utils/hive_keys.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum ReelUploadStatus { running, complete, failed }

/// Persists reel [upload-media] jobs for status + retry on success screen.
abstract final class ReelUploadTracker {
  static const _hiveKey = 'reel_upload_records';

  static ValueNotifier<int> revision = ValueNotifier(0);

  static Future<void> track({
    required String itemId,
    required Map<String, String> files,
    required String taskId,
  }) async {
    final records = _readAll();
    records[itemId] = {
      'item_id': itemId,
      'files': files,
      'task_id': taskId,
      'status': ReelUploadStatus.running.name,
    };
    await _writeAll(records);
    revision.value++;
  }

  static ReelUploadStatus? statusForItem(String itemId) {
    final raw = _readAll()[itemId];
    if (raw is! Map) return null;
    final name = raw['status']?.toString();
    for (final s in ReelUploadStatus.values) {
      if (s.name == name) return s;
    }
    return ReelUploadStatus.running;
  }

  static Map<String, String>? filesForItem(String itemId) {
    final raw = _readAll()[itemId];
    if (raw is! Map) return null;
    final files = raw['files'];
    if (files is! Map) return null;
    return files.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  static void onTaskUpdate(TaskUpdate update) {
    if (update.group != ReelUploadConstants.uploadGroup) return;
    final records = _readAll();
    var changed = false;
    for (final entry in records.entries.toList()) {
      final map = entry.value;
      if (map is! Map) continue;
      if (map['task_id']?.toString() != update.task.taskId) continue;
      if (update.status == TaskStatus.complete) {
        records.remove(entry.key);
        changed = true;
        if (AppConfig.enableReelUploadCompleteFeedRefreshV214) {
          MyAdsRefresh.revision.value++;
          ReelFeedRefresh.revision.value++;
        }
        ReelSubscriptionRefresh.onReelUploadComplete();
      } else if (update.status == TaskStatus.failed ||
          update.status == TaskStatus.notFound) {
        map['status'] = ReelUploadStatus.failed.name;
        changed = true;
      }
    }
    if (changed) {
      unawaited(_writeAll(records));
      revision.value++;
    }
  }

  static Future<bool> retry(String itemId) async {
    final files = filesForItem(itemId);
    if (files == null || files.isEmpty) return false;

    for (final path in files.values) {
      if (!File(path).existsSync()) {
        Log.error('Reel retry: missing file $path', null, null);
        return false;
      }
    }

    final taskId = await BackgroundUploadUtility.uploadMedia(
      itemId: itemId,
      files: files,
    );
    if (taskId != null && AppConfig.enableReelUploadTrackerV214) {
      await track(itemId: itemId, files: files, taskId: taskId);
    }
    return taskId != null;
  }

  static Future<void> clearItem(String itemId) async {
    final records = _readAll();
    if (records.remove(itemId) != null) {
      await _writeAll(records);
      revision.value++;
    }
  }

  static Map<String, dynamic> _readAll() {
    final box = Hive.box(HiveKeys.historyBox);
    final raw = box.get(_hiveKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String) {
      try {
        return Map<String, dynamic>.from(
          json.decode(raw) as Map,
        );
      } catch (_) {}
    }
    return {};
  }

  static Future<void> _writeAll(Map<String, dynamic> records) async {
    final box = Hive.box(HiveKeys.historyBox);
    await box.put(_hiveKey, records);
  }
}
