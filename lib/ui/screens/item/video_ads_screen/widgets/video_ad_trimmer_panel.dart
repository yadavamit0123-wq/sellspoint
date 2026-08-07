import 'dart:io';

import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_trimmer/video_trimmer.dart';

/// Pick + trim UI for [VideoAdEditorScreen] (package [video_trimmer]).
class VideoAdTrimmerPanel extends StatefulWidget {
  const VideoAdTrimmerPanel({
    super.key,
    required this.onTrimmed,
  });

  final ValueChanged<File> onTrimmed;

  @override
  State<VideoAdTrimmerPanel> createState() => _VideoAdTrimmerPanelState();
}

class _VideoAdTrimmerPanelState extends State<VideoAdTrimmerPanel> {
  final Trimmer _trimmer = Trimmer();
  final ImagePicker _picker = ImagePicker();

  double _startValue = 0;
  double _endValue = 0;
  bool _isPlaying = false;
  bool _progressVisible = false;
  File? _sourceFile;

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  Future<void> _pickVideo(ImageSource source) async {
    final picked = await _picker.pickVideo(source: source);
    if (picked == null || !mounted) return;
    final file = File(picked.path);
    await _trimmer.loadVideo(videoFile: file);
    if (!mounted) return;
    setState(() => _sourceFile = file);
  }

  Future<void> _saveTrim() async {
    if (_sourceFile == null) return;
    setState(() => _progressVisible = true);
    final path = await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
    );
    if (!mounted) return;
    setState(() => _progressVisible = false);
    if (path == null) {
      UiUtils.showSnackBarMessage(
        context,
        'somethingWentWrong'.translate(context),
      );
      return;
    }
    widget.onTrimmed(File(path));
  }

  Future<void> _showPickSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: CustomText('gallery'.translate(context)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: CustomText('camera'.translate(context)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickVideo(ImageSource.camera);
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
    if (_sourceFile == null) {
      return Center(
        child: UiUtils.buildButton(
          context,
          width: context.screenWidth - 40,
          height: 48,
          radius: 10,
          buttonTitle: 'selectVideo'.translate(context),
          buttonColor: context.color.territoryColor,
          textColor: context.color.secondaryColor,
          onPressed: _showPickSource,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: VideoViewer(trimmer: _trimmer),
        ),
        const SizedBox(height: 8),
        Center(
          child: TrimViewer(
            trimmer: _trimmer,
            viewerHeight: 48,
            viewerWidth: context.screenWidth - 32,
            maxVideoLength: const Duration(seconds: 90),
            onChangeStart: (v) => _startValue = v,
            onChangeEnd: (v) => _endValue = v,
            onChangePlaybackState: (playing) =>
                setState(() => _isPlaying = playing),
          ),
        ),
        const SizedBox(height: 12),
        if (_progressVisible)
          const LinearProgressIndicator(minHeight: 4),
        if (!_progressVisible) ...[
          IconButton(
            iconSize: 48,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: context.color.territoryColor,
            ),
            onPressed: _progressVisible
                ? null
                : () async {
                    final playback = await _trimmer.videoPlaybackControl(
                      startValue: _startValue,
                      endValue: _endValue,
                    );
                    if (mounted) setState(() => _isPlaying = playback);
                  },
          ),
          const SizedBox(height: 8),
          UiUtils.buildButton(
            context,
            height: 48,
            radius: 10,
            buttonTitle: 'continue'.translate(context),
            buttonColor: context.color.territoryColor,
            textColor: context.color.secondaryColor,
            onPressed: _saveTrim,
          ),
        ],
      ],
    );
  }
}
