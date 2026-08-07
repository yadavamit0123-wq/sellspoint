import 'package:dio/dio.dart';
import 'package:eClassify/utils/log.dart';

class NetworkRequestInterceptor extends Interceptor {
  int totalAPICallTimes = 0;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    totalAPICallTimes++;
    final parameters = options.method == "POST" && options.data is FormData
        ? (options.data as FormData).fields
        : options.queryParameters.isNotEmpty
            ? options.queryParameters
            : options.data;
    Log.debug(
      'API #$totalAPICallTimes ${options.method} ${options.uri.path} $parameters',
    );
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 304) {
      Log.error(
        'API error ${err.requestOptions.method} ${err.requestOptions.uri.path}',
        err.error,
        err.stackTrace,
      );
    }
    handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Log.debug(
      'API ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri.path}',
    );
    handler.next(response);
  }
}
