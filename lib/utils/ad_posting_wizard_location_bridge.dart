import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/model/item/ad_posting_data.dart';
import 'package:eClassify/ui/screens/item/add_item_screen/select_category.dart';
import 'package:eClassify/utils/ad_posting_item_payload.dart';
import 'package:eClassify/utils/reel_upload_payload.dart';
import 'package:eClassify/utils/video_ad_editor_draft.dart';
import 'package:eClassify/utils/ad_posting_video_link_policy.dart';
import 'package:eClassify/utils/ad_posting_wizard_utils.dart';
import 'package:eClassify/utils/cloud_state/cloud_state.dart';
import 'package:flutter/material.dart';

/// Seeds [CloudState] and opens [Routes.confirmLocationScreen] after wizard media.
abstract final class AdPostingWizardLocationBridge {
  static void openConfirmLocation(
    BuildContext context, {
    required AdPostingData data,
    required File mainImage,
    required List<File> galleryImages,
    String? videoLink,
    int? wizardTotalSteps,
    int? wizardProgressStep,
  }) {
    final categoryIds =
        data.categoryPath.map((c) => c.id).whereType<int>().toList();
    if (categoryIds.isEmpty) return;

    final slug = (data.slug?.trim().isNotEmpty ?? false)
        ? data.slug!.trim()
        : AdPostingWizardUtils.generateSlug(data.title ?? '');

    final payload = <String, dynamic>{
      'name': data.title ?? '',
      'slug': slug,
      'description': data.description ?? '',
      'category_id': categoryIds.last,
      'price': data.price ?? '',
      'contact': data.phone ?? '',
      'all_category_ids': categoryIds.join(','),
    };

    AdPostingVideoLinkPolicy.applyToPayload(
      payload,
      data,
      userInput: videoLink,
    );

    if (data.customFieldsJson != null && data.customFieldsJson!.isNotEmpty) {
      payload['custom_fields'] = data.customFieldsJson;
    }
    payload.addAll(data.customFieldFiles);

    AdPostingItemPayload.ensureItemType(payload, adType: data.adType);

    if (data.reelVideoFile != null) {
      CloudState.cloudData['pending_reel_upload'] =
          ReelUploadPayload.toCloudMap(
        videoPath: data.reelVideoFile!.path,
        thumbnailPath: data.reelThumbnailFile?.path ??
            VideoAdEditorDraft.thumbnailFile?.path,
      );
    }

    CloudState.cloudData['item_details'] = Map<String, dynamic>.from(payload);
    CloudState.cloudData['with_more_details'] =
        Map<String, dynamic>.from(payload);

    screenStack++;

    Navigator.pushReplacementNamed(
      context,
      Routes.confirmLocationScreen,
      arguments: {
        'isEdit': false,
        'mainImage': mainImage,
        'otherImage': galleryImages,
        'inAppWizardHandoff': true,
        if (wizardTotalSteps != null) 'wizardTotalSteps': wizardTotalSteps,
        if (wizardProgressStep != null)
          'wizardProgressStep': wizardProgressStep,
      },
    );
  }
}
