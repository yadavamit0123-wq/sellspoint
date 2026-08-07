import 'package:eClassify/app/cubit_observer.dart';
import 'package:eClassify/app/navigator_observer.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:eClassify/utils/log.dart';
import 'package:eClassify/utils/network_request_interseptor.dart';
import 'package:flutter/foundation.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';

/// Shared HTTP client for upcoming 2.14 modules. Live code still uses [Api.get]/[Api.post].
class ApiInfrastructure {
  ApiInfrastructure._();

  static bool _ready = false;
  static late final Dio sharedDio;
  static late final CacheOptions cacheOptions;

  static bool get isReady => _ready;

  static Future<void> init() async {
    if (_ready) return;

    final supportDir = await getApplicationSupportDirectory();
    cacheOptions = CacheOptions(store: HiveCacheStore(supportDir.path));

    sharedDio = Dio()
      ..interceptors.addAll([
        NetworkRequestInterceptor(),
        if (kReleaseMode) DioCacheInterceptor(options: cacheOptions),
      ]);

    _ready = true;
    Log.info('ApiInfrastructure ready');
  }
}
