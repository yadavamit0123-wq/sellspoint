import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/repositories/item/item_repository.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_feature_gate.dart';
import 'package:eClassify/utils/reel_upload_tracker.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// Compact chip on My Ads rows for pending/failed reel uploads.
class ReelUploadBadge extends StatefulWidget {
  const ReelUploadBadge({
    super.key,
    required this.itemId,
    this.compact = false,
  });

  final String itemId;
  final bool compact;

  @override
  State<ReelUploadBadge> createState() => _ReelUploadBadgeState();
}

class _ReelUploadBadgeState extends State<ReelUploadBadge> {
  ReelUploadStatus? _status;
  bool _retrying = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    if (AppConfig.enableReelUploadTrackerV214) {
      ReelUploadTracker.revision.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    ReelUploadTracker.revision.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _status = ReelUploadTracker.statusForItem(widget.itemId);
    });
  }

  Future<void> _openAdDetails() async {
    final id = int.tryParse(widget.itemId);
    if (id == null) return;
    try {
      final result = await ItemRepository().fetchItemFromItemId(id);
      if (!mounted || result.modelList.isEmpty) return;
      await Navigator.pushNamed(
        context,
        Routes.adDetailsScreen,
        arguments: {'model': result.modelList.first},
      );
    } catch (_) {
      if (!mounted) return;
      UiUtils.showSnackBarMessage(
        context,
        'somethingWentWrong'.translate(context),
      );
    }
  }

  Future<void> _onRetryTap() async {
    if (_retrying) return;
    if (!await ReelFeatureGate.ensureAllowed(context)) return;
    if (!mounted) return;
    await _retry();
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    final ok = await ReelUploadTracker.retry(widget.itemId);
    if (!mounted) return;
    setState(() => _retrying = false);
    if (!ok) {
      UiUtils.showSnackBarMessage(
        context,
        'somethingWentWrong'.translate(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableReelUploadMyAdsBadgeV214 ||
        !AppConfig.enableReelUploadTrackerV214) {
      return const SizedBox.shrink();
    }

    final status = _status;
    if (status == null) return const SizedBox.shrink();

    final isFailed = status == ReelUploadStatus.failed;
    final label = isFailed
        ? 'reelUploadFailedShort'.translate(context)
        : 'reelUploadPendingShort'.translate(context);
    final bg = isFailed
        ? context.color.forthColor.withValues(alpha: 0.12)
        : context.color.territoryColor.withValues(alpha: 0.12);
    final fg = isFailed ? context.color.forthColor : context.color.territoryColor;

    final chip = Container(
      margin: EdgeInsets.only(top: widget.compact ? 4 : 0),
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 8 : 10,
        vertical: widget.compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFailed ? Icons.error_outline : Icons.cloud_upload_outlined,
            size: widget.compact ? 12 : 14,
            color: fg,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: CustomText(
              _retrying ? 'retry'.translate(context) : label,
              fontSize: context.font.small,
              color: fg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (isFailed && !widget.compact) {
      if (AppConfig.enableMyAdsReelFailedBadgeOpensDetailsV214) {
        return GestureDetector(onTap: _openAdDetails, child: chip);
      }
      return GestureDetector(onTap: _retrying ? null : _onRetryTap, child: chip);
    }
    if (isFailed && widget.compact) {
      if (AppConfig.enableMyAdsReelFailedBadgeOpensDetailsV214) {
        return InkWell(onTap: _openAdDetails, child: chip);
      }
      return InkWell(onTap: _retrying ? null : _onRetryTap, child: chip);
    }
    if (status == ReelUploadStatus.running &&
        AppConfig.enableMyAdsReelPendingBadgeOpensDetailsV214) {
      return InkWell(onTap: _openAdDetails, child: chip);
    }
    return chip;
  }
}
