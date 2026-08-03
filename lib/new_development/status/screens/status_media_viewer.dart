import 'dart:async';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class StatusMediaViewer extends StatefulWidget {
  final StatusModel status;
  final VoidCallback onNextUser;
  final VoidCallback onPrevUser;

  const StatusMediaViewer({
    super.key,
    required this.status,
    required this.onNextUser,
    required this.onPrevUser,
  });

  @override
  State<StatusMediaViewer> createState() => _StatusMediaViewerState();
}

class _StatusMediaViewerState extends State<StatusMediaViewer> {
  late PageController _mediaPC;
  int currentIndex = 0;

  List<double> progress = [];
  Timer? _timer;
  VideoPlayerController? _videoController;
  bool _isLoadingCurrent = false;

  bool _isPaused = false;
  bool _isHolding = false;
  int _imageElapsedMs = 0; // image ke liye timer memory


  @override
  void initState() {
    super.initState();
    _mediaPC = PageController();
    progress = List.filled(widget.status.mediaUrls.length, 0.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCurrentMedia();
    });
  }

  Future<void> _startCurrentMedia() async {
    // Cancel previous timers / controllers
    _imageElapsedMs = 0;

    _timer?.cancel();
    await _disposeVideo();
    setState(() {
      _isLoadingCurrent = true;
      progress[currentIndex] = 0.0;
    });

    final mediaUrl = widget.status.mediaUrls[currentIndex];
    final isVideo = _isVideo(mediaUrl);

    if (isVideo) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
        await _videoController!.initialize();
        // start playback
        _videoController!.play();

        final total = _videoController!.value.duration.inMilliseconds;
        // Safety: if duration is zero, move next
        if (total <= 0) {
          setState(() => _isLoadingCurrent = false);
          _goNext();
          return;
        }

        setState(() => _isLoadingCurrent = false);


        // _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        //   final pos = _videoController!.value.position.inMilliseconds;
        //   double p = pos / total;
        //   setState(() => progress[currentIndex] = p.clamp(0.0, 1.0));
        //   if (p >= 1.0) {
        //     t.cancel();
        //     _goNext();
        //   }
        // });
        _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
          if (_isPaused) return;

          final pos = _videoController!.value.position.inMilliseconds;
          double p = pos / total;

          setState(() => progress[currentIndex] = p.clamp(0.0, 1.0));
          if (p >= 1.0) {
            t.cancel();
            _goNext();
          }
        });

      } catch (e) {
        // video init error -> skip after small delay
        setState(() => _isLoadingCurrent = false);
        Future.delayed(const Duration(seconds: 1), _goNext);
      }
    } else {
      // Image: wait for it to be cached / loaded
      try {
        await precacheImage(NetworkImage(mediaUrl), context);
        setState(() => _isLoadingCurrent = false);

        // int elapsed = 0;
        // _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
        //   elapsed += 50;
        //   double p = elapsed / 5000; // 5 seconds for images
        //   setState(() => progress[currentIndex] = p.clamp(0.0, 1.0));
        //   if (p >= 1.0) {
        //     t.cancel();
        //     _goNext();
        //   }
        // });
        _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
          if (_isPaused) return;

          _imageElapsedMs += 50;
          double p = _imageElapsedMs / 5000;

          setState(() => progress[currentIndex] = p.clamp(0.0, 1.0));

          if (p >= 1.0) {
            t.cancel();
            _imageElapsedMs = 0;
            _goNext();
          }
        });

      } catch (e) {
        // image failed to load -> skip after small delay
        setState(() => _isLoadingCurrent = false);
        Future.delayed(const Duration(seconds: 1), _goNext);
      }
    }
  }

  void _goNext() {
    if (currentIndex + 1 < widget.status.mediaUrls.length) {
      _mediaPC.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onNextUser();
    }
  }

  void _goPrev() {
    if (currentIndex - 1 >= 0) {
      _mediaPC.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onPrevUser();
    }
  }

  bool _isVideo(String url) {
    final u = url.toLowerCase();
    return u.endsWith('.mp4') || u.endsWith('.mov') || u.endsWith('.webm') || u.endsWith('.mkv');
  }

  Future<void> _disposeVideo() async {
    try {
      await _videoController?.pause();
      await _videoController?.dispose();
    } catch (_) {}
    _videoController = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeVideo();
    _mediaPC.dispose();
    super.dispose();
  }
  void _resumeImageTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (_isPaused) return;

      _imageElapsedMs += 50;
      double p = _imageElapsedMs / 5000;

      setState(() => progress[currentIndex] = p.clamp(0.0, 1.0));

      if (p >= 1.0) {
        t.cancel();
        _imageElapsedMs = 0;
        _goNext();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.status.mediaUrls;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      /*onTapDown: (details) {
        final w = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < w / 2) {
          _goPrev();
        } else {
          _goNext();
        }
      },*/
      // ✅ HOLD START (pause)
      onLongPressStart: (_) {
        _isHolding = true;
        _isPaused = true;
        _timer?.cancel();

        if (_videoController != null && _videoController!.value.isPlaying) {
          _videoController!.pause();
        }
      },

      // ✅ HOLD END (resume)
      onLongPressEnd: (_) {
        _isPaused = false;

        if (_videoController != null && !_videoController!.value.isPlaying) {
          _videoController!.play();
        }

        if (!_isVideo(widget.status.mediaUrls[currentIndex])) {
          _resumeImageTimer();
        }

        // thoda delay taaki tap trigger na ho
        Future.delayed(const Duration(milliseconds: 150), () {
          _isHolding = false;
        });
      },

      // ✅ TAP navigation (only when not holding)
      onTapUp: (details) {
        if (_isHolding) return;

        final w = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < w / 2) {
          _goPrev();
        } else {
          _goNext();
        }
      },

      child: Column(
        children: [
          // TOP PROGRESS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              children: List.generate(media.length, (i) {
                return Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: i == media.length - 1 ? 0 : 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress[i],
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // MEDIA VIEWER
          Expanded(
            child: PageView.builder(
              controller: _mediaPC,
              itemCount: media.length,
              physics: const NeverScrollableScrollPhysics(), // disable inner swipe
              onPageChanged: (i) {
                setState(() => currentIndex = i);
                _timer?.cancel();
                _startCurrentMedia();
              },
              itemBuilder: (context, i) {
                final url = media[i];

                return Stack(
                  children: [
                    // ---------------- MEDIA DISPLAY ----------------
                    Center(
                      child: _isVideo(url)
                          ? _buildVideo(i, url)
                          : _buildImage(i, url),
                    ),

                    // ---------------- DESCRIPTION TEXT ----------------
                    if ((widget.status.description.isNotEmpty))
                      Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: Text(
                          widget.status.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,

                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // ---------------- VIEW DETAILS BUTTON ----------------
                    Positioned(
                      bottom: 15 + MediaQuery.of(context).viewPadding.bottom,
                      left: 16,
                      right: 16,
                      child: UiUtils.buildButton(
                        context,
                        buttonTitle: 'View Details',
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.adDetailsScreen, arguments: {
                            "model": widget.status.item,
                          });
                        },
                        fontSize: context.font.larger,
                        textColor: context.color.buttonColor,
                        height: 55
                    ),)
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(int i, String url) {
    return _isLoadingCurrent && currentIndex == i
        ? const CircularProgressIndicator()
        : Image.network(
      url, fit: BoxFit.contain,
      errorBuilder: (ctx, e, st) => const Icon(
        Icons.broken_image,
        color: Colors.white54,
        size: 60,
      ),
    );
  }

  Widget _buildVideo(int i, String url) {
    if (_videoController == null || !_videoController!.value.isInitialized || currentIndex != i) {
      return const CircularProgressIndicator();
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: VideoPlayer(_videoController!),
    );
  }

}
