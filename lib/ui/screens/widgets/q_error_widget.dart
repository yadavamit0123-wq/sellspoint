import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/color_mappers/primary_color_mapper.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Determines which error variant to render when no [error] object is provided.
enum QErrorType {
  /// Network / socket connectivity problem.
  socket,

  /// Generic API / server-side error.
  api,

  /// Successful response but the result set is empty.
  emptyData,
}

/// A unified, self-contained error display widget.
///
/// Supply **either** an [error] object **or** a [type] — never both, never
/// neither. An [AssertionError] is thrown at runtime if this contract is
/// violated.
///
/// Priority: when [error] is non-null it drives the illustration, title, and
/// subtitle, regardless of [type].
///
/// Supported [error] runtime types:
/// * [DioException] — inspects the underlying cause (socket = no internet,
///   timeout, otherwise generic) and shows the *No Internet* illustration.
/// * [ApiException] — shows the message stored inside the exception as the
///   subtitle, with the *Something Went Wrong* illustration.
/// * Anything else — shows a generic message with the *Something Went Wrong*
///   illustration.
///
/// When [onRetry] is non-null a *Retry* button is rendered below the body.
class QErrorWidget extends StatelessWidget {
  const QErrorWidget({super.key, this.error, this.type, this.onRetry})
    : assert(
        (error != null) != (type != null),
        'Provide either "error" or "type", not both and not neither.',
      );

  const QErrorWidget.emptyData({this.onRetry, super.key})
    : type = QErrorType.emptyData,
      error = null;

  /// The caught exception / error object. Takes priority over [type].
  final Object? error;

  /// Explicit error category used when [error] is null.
  final QErrorType? type;

  /// Optional callback wired to the *Retry* button. Pass `null` to hide it.
  final VoidCallback? onRetry;

  // ─── helpers ──────────────────────────────────────────────────────────────

  _ErrorConfig _resolveConfig(BuildContext context) {
    if (error != null) {
      // ── DioException ──────────────────────────────────────────────────────
      if (error is DioException) {
        final dioError = error as DioException;

        return switch ((dioError.error, dioError.type)) {
          (SocketException(), DioExceptionType.connectionError) => _ErrorConfig(
            svgPath: AppAssets.illustrators.noInternet,
            title: 'noInternet'.translate(context),
            subtitle: 'noInternetErrorMsg'.translate(context),
          ),
          (
            _,
            DioExceptionType.connectionTimeout ||
                DioExceptionType.receiveTimeout ||
                DioExceptionType.sendTimeout,
          ) =>
            _ErrorConfig(
              svgPath: AppAssets.illustrators.noInternet,
              title: 'connectionTimedOutTitle'.translate(context),
              subtitle: 'connectionTimedOut'.translate(context),
            ),
          (_, _) => _ErrorConfig(
            svgPath: AppAssets.illustrators.noInternet,
            title: 'noInternet'.translate(context),
            subtitle: 'noInternetErrorMsg'.translate(context),
          ),
        };
      }

      // ── ApiException ──────────────────────────────────────────────────────
      if (error is ApiException) {
        return _ErrorConfig(
          svgPath: AppAssets.illustrators.somethingWentWrong,
          title: 'somethingWentWrongTitle'.translate(context),
          subtitle: error.toString(),
        );
      }

      // ── Generic / unknown exception ───────────────────────────────────────
      return _ErrorConfig(
        svgPath: AppAssets.illustrators.somethingWentWrong,
        title: 'somethingWentWrongTitle'.translate(context),
        subtitle: 'defaultErrorMsg'.translate(context),
      );
    }

    // ── type supplied ────────────────────────────────────────────────────────
    return switch (type!) {
      QErrorType.socket => _ErrorConfig(
        svgPath: AppAssets.illustrators.noInternet,
        title: 'noInternet'.translate(context),
        subtitle: 'noInternetErrorMsg'.translate(context),
      ),
      QErrorType.api => _ErrorConfig(
        svgPath: AppAssets.illustrators.somethingWentWrong,
        title: 'somethingWentWrongTitle'.translate(context),
        subtitle: 'defaultErrorMsg'.translate(context),
      ),
      QErrorType.emptyData => _ErrorConfig(
        svgPath: AppAssets.illustrators.noDataFound,
        title: 'nodatafound'.translate(context),
        subtitle: 'sorryLookingFor'.translate(context),
      ),
    };
  }

  // ─── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final config = _resolveConfig(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomImage(
            src: config.svgPath,
            svgColorMapper: PrimaryColorMapper(context.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              config.title,
              textAlign: TextAlign.center,
              style: context.titleMedium.withColor(context.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              config.subtitle,
              textAlign: TextAlign.center,
              style: context.bodySmall,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 5),
            TextButton(
              onPressed: onRetry,
              child: Text('retry'.translate(context)),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── private config model ──────────────────────────────────────────────────

class _ErrorConfig {
  const _ErrorConfig({
    required this.svgPath,
    required this.title,
    required this.subtitle,
  });

  final String svgPath;

  /// Bold headline shown below the illustration.
  final String title;

  /// Secondary descriptive text shown below the title.
  final String subtitle;
}
