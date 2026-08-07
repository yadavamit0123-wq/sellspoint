import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/reel_feature_gate.dart';
import 'package:eClassify/utils/main_navigation_v214.dart';
import 'package:eClassify/utils/reel_upload_tracker.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';

/// Shown on post success when a reel background upload was queued.
class ReelUploadStatusBanner extends StatefulWidget {
  const ReelUploadStatusBanner({super.key, required this.itemId});

  final String itemId;

  @override
  State<ReelUploadStatusBanner> createState() => _ReelUploadStatusBannerState();
}

class _ReelUploadStatusBannerState extends State<ReelUploadStatusBanner> {
  ReelUploadStatus? _status;
  bool _retrying = false;
  bool _uploadComplete = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    ReelUploadTracker.revision.addListener(_refresh);
  }

  @override
  void dispose() {
    ReelUploadTracker.revision.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    final next = ReelUploadTracker.statusForItem(widget.itemId);
    final wasRunning = _status == ReelUploadStatus.running;
    if (wasRunning &&
        next == null &&
        AppConfig.enableReelUploadBannerCompleteCtaV214) {
      setState(() {
        _status = null;
        _uploadComplete = true;
      });
      return;
    }
    setState(() {
      _status = next;
      if (next != null) {
        _uploadComplete = false;
      }
    });
  }

  Future<void> _retry() async {
    setState(() => _retrying = true);
    final ok = await ReelUploadTracker.retry(widget.itemId);
    if (mounted) {
      setState(() => _retrying = false);
      if (!ok) {
        UiUtils.showSnackBarMessage(
          context,
          'somethingWentWrong'.translate(context),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uploadComplete) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.color.territoryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.color.territoryColor.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomText(
              'reelUploadComplete'.translate(context),
              textAlign: TextAlign.center,
              fontSize: context.font.small,
              fontWeight: FontWeight.w600,
              color: context.color.textDefaultColor,
            ),
            const SizedBox(height: 10),
            UiUtils.buildButton(
              context,
              height: 40,
              radius: 8,
              buttonTitle: 'viewReelForListing'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: () {
                final id = int.tryParse(widget.itemId);
                MainNavigationV214.openReelsTab(itemId: id);
              },
            ),
            if (AppConfig.enableReelUploadBannerCompleteDismissV214) ...[
              const SizedBox(height: 8),
              UiUtils.buildButton(
                context,
                height: 36,
                radius: 8,
                buttonTitle: 'ok'.translate(context),
                buttonColor: context.color.secondaryColor,
                textColor: context.color.textDefaultColor,
                onPressed: () {
                  setState(() => _uploadComplete = false);
                },
              ),
            ],
          ],
        ),
      );
    }

    final status = _status;
    if (status == null) {
      return const SizedBox.shrink();
    }

    final isFailed = status == ReelUploadStatus.failed;
    final message = isFailed
        ? 'reelUploadFailed'.translate(context)
        : 'reelUploadInProgress'.translate(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFailed
            ? context.color.forthColor.withValues(alpha: 0.08)
            : context.color.territoryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFailed
              ? context.color.forthColor.withValues(alpha: 0.35)
              : context.color.territoryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomText(
            message,
            textAlign: TextAlign.center,
            fontSize: context.font.small,
            color: context.color.textDefaultColor,
          ),
          if (isFailed) ...[
            const SizedBox(height: 10),
            UiUtils.buildButton(
              context,
              height: 40,
              radius: 8,
              buttonTitle: 'retry'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: _retrying
                  ? () {}
                  : () async {
                      if (!await ReelFeatureGate.ensureAllowed(context)) {
                        return;
                      }
                      if (!mounted) return;
                      _retry();
                    },
            ),
          ],
        ],
      ),
    );
  }
}
