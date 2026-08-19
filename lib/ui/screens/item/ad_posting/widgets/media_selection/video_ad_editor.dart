import 'package:eClassify/data/model/custom_field/file_resource.dart';
import 'package:eClassify/ui/screens/item/ad_posting/widgets/media_selection/video_thumbnail_bottom_sheet.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoAdEditor extends StatefulWidget {
  const VideoAdEditor({
    required this.resource,
    this.initialThumbnail,
    this.isCustomThumbnail = false,
    super.key,
  });

  final LocalFileResource resource;
  final FileResource? initialThumbnail;
  final bool isCustomThumbnail;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => VideoAdEditor(
        resource: args['video'] as LocalFileResource,
        initialThumbnail: args['thumbnail'] as FileResource?,
        isCustomThumbnail: args['isCustomThumbnail'] as bool,
      ),
    );
  }

  @override
  State<VideoAdEditor> createState() => _VideoAdEditorState();
}

class _VideoAdEditorState extends State<VideoAdEditor> {
  final Trimmer _trimmer = Trimmer();
  final maxDuration = Duration(
    seconds: Constant.systemSettings.maxReelDuration,
  );
  Duration _trimDuration = Duration.zero;
  double _startValue = 0.0;
  double _endValue = 0.0;
  final ValueNotifier<bool> _isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);

  FileResource? _customThumbnail;
  bool _isCustomThumbnail = false;

  @override
  void dispose() {
    _isPlayingNotifier.dispose();
    _isSavingNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _customThumbnail = widget.initialThumbnail;
    _isCustomThumbnail = widget.isCustomThumbnail;
    _trimmer.eventStream.listen((event) {
      if (event == TrimmerEvent.initialized) {
        final videoDuration =
            _trimmer.videoPlayerController?.value.duration ?? Duration.zero;
        setState(() {
          _trimDuration = videoDuration < maxDuration
              ? videoDuration
              : maxDuration;
          _endValue = _trimDuration.inMilliseconds.toDouble();
        });
      }
    });
    _trimmer.loadVideo(videoFile: widget.resource.file);
  }

  void _openThumbnailBottomSheet() {
    VideoThumbnailBottomSheet.show(
      context: context,
      videoPath: widget.resource.file.path,
      startMs: _startValue,
      endMs: _endValue,
      customThumbnail: _customThumbnail,
      onThumbnailChanged: (thumbnail, isCustom) {
        _customThumbnail = thumbnail;
        _isCustomThumbnail = isCustom;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('editVideo'.translate(context))),
      bottomNavigationBar: ColoredBox(
        color: context.colorScheme.secondary,
        child: SafeArea(
          child: Padding(
            padding: Constant.safeAreaMinimumPadding,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSavingNotifier,
              builder: (context, isSaving, _) {
                return FilledButton(
                  style: FilledButton.styleFrom(
                    fixedSize: const Size.fromHeight(48),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          _isSavingNotifier.value = true;
                          await _trimmer.saveTrimmedVideo(
                            startValue: _startValue,
                            endValue: _endValue,
                            videoFileName:
                                'trimmed_${DateTime.now().millisecondsSinceEpoch}',
                            onSave: (outputPath) {
                              if (mounted) {
                                _isSavingNotifier.value = false;
                              }
                              Navigator.of(context).pop({
                                'videoPath': outputPath,
                                'thumbnail': _customThumbnail,
                                'isCustomThumbnail': _isCustomThumbnail,
                              });
                            },
                          );
                        },
                  child: isSaving
                      ? LoadingIndicator(color: context.colorScheme.onPrimary)
                      : Text('saveVideo'.translate(context)),
                );
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: Constant.appContentPadding,
        child: Column(
          spacing: 32,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .5,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      bool playbackState = await _trimmer.videoPlaybackControl(
                        startValue: _startValue,
                        endValue: _endValue,
                      );
                      _isPlayingNotifier.value = playbackState;
                    },
                    child: VideoViewer(trimmer: _trimmer),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isPlayingNotifier,
                    builder: (context, isPlaying, _) {
                      return IgnorePointer(
                        ignoring: isPlaying,
                        child: AnimatedOpacity(
                          opacity: isPlaying ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () async {
                              bool playbackState = await _trimmer
                                  .videoPlaybackControl(
                                    startValue: _startValue,
                                    endValue: _endValue,
                                  );
                              _isPlayingNotifier.value = playbackState;
                            },
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.theme.dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'videoTimeline'.translate(context),
                          style: context.labelLarge,
                        ),
                        TextButton(
                          onPressed: _openThumbnailBottomSheet,
                          child: Text('setThumbnail'.translate(context)),
                        ),
                      ],
                    ),
                    TrimViewer(
                      trimmer: _trimmer,
                      maxVideoLength: _trimDuration,
                      viewerWidth: MediaQuery.sizeOf(context).width,
                      viewerHeight: 50,
                      paddingFraction: 3.0,
                      durationTextStyle: context.labelMedium,
                      type: ViewerType.fixed,
                      onChangeStart: (startValue) {
                        _startValue = startValue;
                      },
                      onChangeEnd: (endValue) {
                        _endValue = endValue;
                      },
                      onChangePlaybackState: (isPlaying) {
                        _isPlayingNotifier.value = isPlaying;
                      },
                      editorProperties: TrimEditorProperties(
                        circlePaintColor: context.colorScheme.primary,
                        borderPaintColor: context.colorScheme.primary,
                        scrubberPaintColor: context.colorScheme.primary,
                        borderWidth: 3,
                        sideTapSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
