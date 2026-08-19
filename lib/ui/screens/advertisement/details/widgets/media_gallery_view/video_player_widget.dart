import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:omni_video_player/omni_video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    required this.videoUrl,
    required this.type,
    this.isFullScreen = false,
    super.key,
  });

  final String videoUrl;
  final ProductVideoType type;
  final bool isFullScreen;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      return const Center(child: Text('Invalid Video URL'));
    }

    final videoSource = switch (widget.type) {
      ProductVideoType.youtube => VideoSourceConfiguration.youtube(
        // Remove query parameters and any fragments as the regex
        // used by OmniPlayer to extract the video id is not able to handle them
        videoUrl: Uri(host: uri.host, scheme: uri.scheme, path: uri.path),
      ),
      ProductVideoType.vimeo => VideoSourceConfiguration.vimeo(
        videoId: uri.pathSegments.last,
      ),
      ProductVideoType.otherLink => VideoSourceConfiguration.network(
        videoUrl: uri,
      ),
      ProductVideoType.custom => VideoSourceConfiguration.network(
        videoUrl: uri,
      ),
    };

    return OmniVideoPlayer(
      configuration: VideoPlayerConfiguration(
        videoSourceConfiguration: videoSource,
        playerUIVisibilityOptions: PlayerUIVisibilityOptions(
          showBottomControlsBarOnPause: true,
        ),
        customPlayerWidgets: CustomPlayerWidgets(
          loadingWidget: LoadingIndicator(),
        ),
      ),
      callbacks: VideoPlayerCallbacks(),
    );
  }
}
