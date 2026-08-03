import 'dart:math';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StatusListItem extends StatefulWidget {
  final StatusModel status;
  final double avatarSize;
  final double ringThickness;

  const StatusListItem({
    super.key,
    required this.status,
    this.avatarSize = 64,
    this.ringThickness = 6,
  });

  @override
  State<StatusListItem> createState() => _StatusListItemState();
}

class _StatusListItemState extends State<StatusListItem> {
  late List<bool> viewed; // which segments viewed

  @override
  void initState() {
    super.initState();
    viewed = List<bool>.filled(widget.status.mediaUrls.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.avatarSize;
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: size + widget.ringThickness * 1.4,
                    height: size + widget.ringThickness * 1.3,
                    child: CustomPaint(
                      painter: StatusRingPainter(
                        segments: widget.status.mediaUrls.length,
                        viewed: viewed,
                        gapDegrees: 2,
                        thickness: widget.ringThickness,
                        viewedColor: Colors.grey.shade400,
                        unViewedColor: Colors.green, // like whatsapp
                        currentColor: Colors.lightGreenAccent,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: size / 2,
                    backgroundImage: widget.status.mediaUrls.isNotEmpty ? NetworkImage(widget.status.mediaUrls.first) : null,   // <-- IMPORTANT
                    child: widget.status.mediaUrls.isNotEmpty
                        ? null
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: SvgPicture.asset('assets/svg/Logo/splashlogo.svg', fit: BoxFit.cover,),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 70,
                  child: Center(
                    child: Text(
                      widget.status.name,
                      style: const TextStyle(fontWeight: FontWeight.bold,),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                // const SizedBox(height: 4),
                // Text(
                //   "${widget.status.mediaUrls.length} ${widget.status.mediaUrls.length == 1 ? 'status' : 'statuses'}",
                //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                // )
              ],
            )
          ],
        ),
      ),
    );
  }
}


/// CustomPainter to draw segmented ring
class StatusRingPainter extends CustomPainter {
  final int segments;
  final List<bool> viewed;
  final double gapDegrees;
  final double thickness;
  final Color viewedColor;
  final Color unViewedColor;
  final Color currentColor;

  StatusRingPainter({
    required this.segments,
    required this.viewed,
    this.gapDegrees = 4,
    this.thickness = 6,
    required this.viewedColor,
    required this.unViewedColor,
    required this.currentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments == 0) return;
    final center = size.center(Offset.zero);
    final radius = (min(size.width, size.height) / 2) - thickness / 2;

    // final totalGap = gapDegrees * segments;
    final gapRad = gapDegrees * pi / 180;
    final sweepPer = (2 * pi - (gapRad * segments)) / segments;

    final paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.butt;

    double start = -pi / 2; // start from top

    for (int i = 0; i < segments; i++) {
      final isViewed = i < viewed.length && viewed[i];
      // background arc (unfilled) - we will draw unViewedColor for unviewed, viewedColor for viewed
      paintBg.color = isViewed ? viewedColor : unViewedColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweepPer,
        false,
        paintBg,
      );
      start += sweepPer + gapRad;
    }
  }

  @override
  bool shouldRepaint(covariant StatusRingPainter old) {
    return old.segments != segments ||
        old.viewed != viewed ||
        old.thickness != thickness ||
        old.gapDegrees != gapDegrees;
  }
}

