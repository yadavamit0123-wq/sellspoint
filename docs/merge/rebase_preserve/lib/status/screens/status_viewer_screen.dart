import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

/// Full screen viewer. Returns the updated viewed list when popped.
class StatusViewer extends StatefulWidget {
  final StatusModel status;
  final int initialIndex;
  final List<bool> alreadyViewed;
  const StatusViewer({
    super.key,
    required this.status,
    this.initialIndex = 0,
    required this.alreadyViewed,
  });

  @override
  State<StatusViewer> createState() => _StatusViewerState();
}

class _StatusViewerState extends State<StatusViewer> {
  late PageController _pc;
  late List<bool> viewed;
  VideoPlayerController? _videoController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    viewed = List<bool>.from(widget.alreadyViewed);
    currentIndex = widget.initialIndex;
    _pc = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markViewed(currentIndex);
      _maybeInitVideo(currentIndex);
    });
  }

  void _markViewed(int idx) {
    if (idx >= 0 && idx < viewed.length && !viewed[idx]) {
      setState(() {
        viewed[idx] = true;
      });
    }
  }

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.mkv');
  }

  Future<void> _maybeInitVideo(int idx) async {
    _disposeVideo();
    final url = widget.status.mediaUrls[idx];
    if (_isVideo(url)) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        _videoController!.setLooping(false);
        _videoController!.play();
        setState(() {});
      } catch (e) {
        // ignore video init errors for now
      }
    }
  }

  void _disposeVideo() {
    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;
  }

  @override
  void dispose() {
    _disposeVideo();
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.status.mediaUrls;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop(viewed);
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.status.avatarUrl.isNotEmpty
                  ? NetworkImage(widget.status.avatarUrl)
                  : null,   // <-- IMPORTANT
              child: widget.status.avatarUrl.isNotEmpty
                  ? null
                  : ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SvgPicture.asset('assets/svg/Logo/splashlogo.svg', fit: BoxFit.cover,),
              ),
            ),
            const SizedBox(width: 8),
            Text(widget.status.name),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // segmented progress at top
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Row(
                    children: List.generate(media.length, (i) {
                      final isViewed = viewed[i];
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: EdgeInsets.symmetric(horizontal: i == 0 ? 0 : 2),
                          decoration: BoxDecoration(
                            color:  isViewed ? Colors.white : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < 0) {
                          // swipe left → NEXT USER
                          Navigator.pop(context, viewed);
                        } else {
                          // swipe right → PREVIOUS USER
                          Navigator.pop(context, viewed);
                        }
                      }
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) {
                        final width = MediaQuery.of(context).size.width;
                        final dx = details.globalPosition.dx;

                        if (dx < width / 2) {
                          _goPrevious();
                        } else {
                          _goNext();
                        }
                      },
                      child: PageView.builder(
                        controller: _pc,
                        itemCount: media.length,
                        onPageChanged: (index) async {
                          setState(() {
                            currentIndex = index;
                          });
                          _markViewed(index);
                          await _maybeInitVideo(index);
                        },
                        itemBuilder: (ctx, index) {
                          final url = media[index];
                          /// ------------------- IMAGE -------------------
                          if (!_isVideo(url)) {
                            return InteractiveViewer(
                              child: Center(
                                child: Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (ctx, child, prog) {
                                    if (prog == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                ),
                              ),
                            );
                          }

                          /// ------------------- VIDEO -------------------
                          if (_videoController != null && _videoController!.value.isInitialized) {
                            return Center(
                              child: AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                ),

              ],
            ),

            if(widget.status.description.isNotEmpty)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Text(widget.status.description.toString()),
            ),
          ],
        ),
      ),
    );
  }

  void _goNext() {
    final next = currentIndex + 1;

    if (next < widget.status.mediaUrls.length) {
      _pc.animateToPage(next,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop(viewed); // next user
    }
  }

  void _goPrevious() {
    final prev = currentIndex - 1;

    if (prev >= 0) {
      _pc.animateToPage(prev,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pop(viewed); // previous user
    }
  }

}
