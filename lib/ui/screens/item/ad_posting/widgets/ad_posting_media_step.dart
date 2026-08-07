import 'dart:io';

import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/model/item/ad_item_type.dart';
import 'package:eClassify/utils/ad_posting_reel_draft_bridge.dart';
import 'package:eClassify/utils/ad_posting_video_link_policy.dart';
import 'package:eClassify/utils/video_ad_thumbnail_utility.dart';
import 'package:eClassify/data/cubits/item/ad_posting_cubit.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:eClassify/ui/screens/widgets/custom_text_form_field.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/ad_posting_legacy_handoff.dart';
import 'package:eClassify/utils/ad_posting_wizard_location_bridge.dart';
import 'package:eClassify/utils/ad_posting_wizard_progress.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/image_picker.dart';
import 'package:eClassify/utils/reel_feature_gate.dart';
import 'package:eClassify/utils/video_ad_editor_launcher.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

/// Main + gallery images before legacy video-link / location handoff.
class AdPostingMediaStep extends StatefulWidget {
  const AdPostingMediaStep({super.key, this.extraArguments});

  final Map<String, dynamic>? extraArguments;

  @override
  State<AdPostingMediaStep> createState() => _AdPostingMediaStepState();
}

class _AdPostingMediaStepState extends State<AdPostingMediaStep> {
  final PickImage _mainImagePicker = PickImage();
  final PickImage _galleryPicker = PickImage();
  final List<File> _galleryFiles = [];
  final TextEditingController _videoLinkController = TextEditingController();
  bool _usedReelThumbnail = false;

  @override
  void initState() {
    super.initState();
    _mainImagePicker.listener((files) {
      if (files != null && files.isNotEmpty) {
        setState(() {});
      }
    });
    _galleryPicker.listener((files) {
      if (files == null) return;
      setState(() {
        _galleryFiles.addAll(files);
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillMainImageFromReel();
    });
  }

  Future<void> _prefillMainImageFromReel() async {
    if (!AppConfig.enableAdPostingVideoReelThumbnailV214 || !mounted) return;
    final data = context.read<AdPostingCubit>().state.adPostingData;
    if (data.adType != AdItemType.videoAd) return;
    if (_mainImagePicker.pickedFile != null) return;

    File? thumb = data.reelThumbnailFile;
    thumb ??= data.reelVideoFile != null
        ? await VideoAdThumbnailUtility.fromVideo(data.reelVideoFile!)
        : null;

    if (thumb == null || !mounted) return;
    _mainImagePicker.pickedFile = thumb;
    context.read<AdPostingCubit>().updateData(
      (d) => d.copyWith(reelThumbnailFile: thumb),
    );
    setState(() => _usedReelThumbnail = true);
  }

  Future<void> _applyDraftFromEditor() async {
    if (!AdPostingReelDraftBridge.hasDraft) return;
    AdPostingReelDraftBridge.applyToCubit(context.read<AdPostingCubit>());
    _mainImagePicker.pickedFile = null;
    _usedReelThumbnail = false;
    await _prefillMainImageFromReel();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoLinkController.dispose();
    _mainImagePicker.dispose();
    _galleryPicker.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdPostingStepController.of(context).register(
      onPrevious: () => context.read<AdPostingCubit>().previousStep(),
      onNext: _onNext,
      showNext: true,
    );
  }

  void _onNext() async {
    if (_mainImagePicker.pickedFile == null) {
      UiUtils.showBlurredDialoge(
        context,
        dialoge: BlurredDialogBox(
          title: 'imageRequired'.translate(context),
          content: CustomText('selectImageYourItem'.translate(context)),
        ),
      );
      return;
    }

    final data = context.read<AdPostingCubit>().state.adPostingData;

    if (data.adType == AdItemType.videoAd &&
        AppConfig.enableAdPostingMediaStepRequireReelVideoV214 &&
        !AdPostingVideoLinkPolicy.hasLocalReel(data) &&
        !AdPostingVideoLinkPolicy.shouldShowLinkField(data)) {
      UiUtils.showSnackBarMessage(
        context,
        'adPostingReelVideoRequired'.translate(context),
      );
      return;
    }

    if (AdPostingVideoLinkPolicy.shouldShowLinkField(data)) {
      final videoLink = _videoLinkController.text.trim();
      if (videoLink.isNotEmpty &&
          !RegExp(r'^https?:\/\/').hasMatch(videoLink)) {
        UiUtils.showSnackBarMessage(
          context,
          'videoLink'.translate(context),
        );
        return;
      }
    }

    final link = AdPostingVideoLinkPolicy.linkForCreatePayload(
      data,
      _videoLinkController.text,
    );

    final main = _mainImagePicker.pickedFile!;
    final gallery = List<File>.from(_galleryFiles);

    if (AppConfig.enableAdPostingWizardDirectLocationV214) {
      final steps = context.read<AdPostingCubit>().state.steps;
      final total = AdPostingWizardProgress.totalWithLocation(steps);
      AdPostingWizardLocationBridge.openConfirmLocation(
        context,
        data: data,
        mainImage: main,
        galleryImages: gallery,
        videoLink: link,
        wizardTotalSteps: total,
        wizardProgressStep: total,
      );
      return;
    }

    AdPostingLegacyHandoff.openDetails(
      context,
      categoryPath: data.categoryPath,
      wizardDraft: data.wizardDraft,
      inAppWizardHandoff: true,
      inAppWizardPhotosDone: true,
      wizardMainImage: main,
      wizardGalleryImages: gallery,
      extraArguments: widget.extraArguments,
    );
  }

  Future<void> _pickMainImage() async {
    await _showSourceDialog((source) {
      _mainImagePicker.pick(context: context, source: source);
      setState(() {});
    });
  }

  Future<void> _pickGallery() async {
    if (_galleryFiles.length >= 5) {
      UiUtils.showSnackBarMessage(
        context,
        'max5ImagesAllowed'.translate(context),
      );
      return;
    }
    await _showSourceDialog((source) {
      _galleryPicker.pick(
        context: context,
        source: source,
        pickMultiple: source == ImageSource.gallery,
        imageLimit: 5,
        maxLength: _galleryFiles.length,
      );
    });
  }

  Future<void> _showSourceDialog(void Function(ImageSource) onSelected) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: CustomText('selectImageSource'.translate(context)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: CustomText('camera'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(ImageSource.camera);
                },
              ),
              ListTile(
                title: CustomText('gallery'.translate(context)),
                onTap: () {
                  Navigator.pop(context);
                  onSelected(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainFile = _mainImagePicker.pickedFile;
    final data = context.watch<AdPostingCubit>().state.adPostingData;
    final showVideoLink = AdPostingVideoLinkPolicy.shouldShowLinkField(data);
    final hasReel = AdPostingVideoLinkPolicy.hasLocalReel(data);
    final showReelAttach = data.adType == AdItemType.videoAd &&
        !hasReel &&
        AppConfig.enableAdPostingMediaStepVideoEditorCtaV214;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasReel &&
              AppConfig.enableAdPostingMediaStepReelAttachedLabelV214) ...[
            Row(
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: context.color.territoryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomText(
                    'adPostingReelVideoAttached'.translate(context),
                    fontWeight: FontWeight.w600,
                    color: context.color.territoryColor,
                  ),
                ),
              ],
            ),
            if (AppConfig.enableAdPostingMediaStepReplaceReelV214) ...[
              const SizedBox(height: 10),
              UiUtils.buildButton(
                context,
                height: 40,
                radius: 10,
                buttonTitle: 'adPostingReplaceReelVideoCta'.translate(context),
                buttonColor: context.color.secondaryColor,
                textColor: context.color.textDefaultColor,
                onPressed: () async {
                  if (!await ReelFeatureGate.ensureAllowed(context)) return;
                  if (!context.mounted) return;
                  await VideoAdEditorLauncher.openFromAdPostingWizard(
                    context,
                  );
                  if (!mounted) return;
                  await _applyDraftFromEditor();
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
          if (showReelAttach) ...[
            CustomText(
              'adPostingAttachReelVideoHint'.translate(context),
              fontSize: context.font.small,
              color: context.color.textLightColor,
            ),
            const SizedBox(height: 10),
            UiUtils.buildButton(
              context,
              height: 44,
              radius: 10,
              buttonTitle: 'adPostingAttachReelVideoCta'.translate(context),
              buttonColor: context.color.territoryColor,
              textColor: context.color.secondaryColor,
              onPressed: () async {
                if (!await ReelFeatureGate.ensureAllowed(context)) return;
                if (!context.mounted) return;
                await VideoAdEditorLauncher.openFromAdPostingWizard(context);
                if (!mounted) return;
                await _applyDraftFromEditor();
              },
            ),
            const SizedBox(height: 20),
          ],
          if (_usedReelThumbnail) ...[
            CustomText(
              'reelThumbnailHint'.translate(context),
              fontSize: context.font.small,
              color: context.color.textLightColor,
            ),
            const SizedBox(height: 8),
          ],
          CustomText(
            'mainPicture'.translate(context),
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickMainImage,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.color.borderColor),
                color: context.color.secondaryColor,
              ),
              clipBehavior: Clip.antiAlias,
              child: mainFile != null
                  ? Image.file(mainFile, fit: BoxFit.cover)
                  : Icon(Icons.add_a_photo, color: context.color.textLightColor),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CustomText(
                'otherPictures'.translate(context),
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(width: 6),
              CustomText(
                'max5Images'.translate(context),
                fontSize: context.font.small,
                color: context.color.textLightColor,
                fontStyle: FontStyle.italic,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final file in _galleryFiles)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(file, width: 72, height: 72, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(Icons.cancel, color: context.color.forthColor),
                        onPressed: () {
                          setState(() => _galleryFiles.remove(file));
                        },
                      ),
                    ),
                  ],
                ),
              InkWell(
                onTap: _pickGallery,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.color.borderColor),
                  ),
                  child: Icon(Icons.add, color: context.color.territoryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (showVideoLink)
            CustomTextFormField(
              controller: _videoLinkController,
              hintText: 'videoLink'.translate(context),
            ),
        ],
      ),
    );
  }
}
