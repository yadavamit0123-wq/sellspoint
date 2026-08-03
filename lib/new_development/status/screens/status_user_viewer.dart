import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/new_development/status/screens/status_media_viewer.dart';
import 'package:flutter/material.dart';

class StatusUserViewer extends StatefulWidget {
  final List<StatusModel> allUsers;
  final int initialUserIndex;

  const StatusUserViewer({
    super.key,
    required this.allUsers,
    required this.initialUserIndex,
  });

  @override
  State<StatusUserViewer> createState() => _StatusUserViewerState();
}

class _StatusUserViewerState extends State<StatusUserViewer> {
  late PageController _userPC;
  int _currentUserIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _userPC = PageController(initialPage: widget.initialUserIndex);
  }

  @override
  void dispose() {
    _userPC.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _currentUserIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final users = widget.allUsers;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
          padding: EdgeInsets.zero,
          tooltip: 'Back',
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: (users[_currentUserIndex].avatarUrl.isNotEmpty)
                  ? NetworkImage(users[_currentUserIndex].avatarUrl)
                  : null,
              child: users[_currentUserIndex].avatarUrl.isNotEmpty ? null : const Icon(Icons.person),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  users[_currentUserIndex].name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(timeAgo(users[_currentUserIndex].item.created.toString()), style: TextStyle(fontSize: 14),),
              ],
            )
          ],
        ),
      ),
      body: PageView.builder(
        controller: _userPC,
        itemCount: users.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final user = users[index];
          return StatusMediaViewer(
            status: user,
            onNextUser: () {
              if (index + 1 < users.length) {
                _userPC.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              } else {
                Navigator.of(context).pop();
              }
            },
            onPrevUser: () {
              if (index - 1 >= 0) {
                _userPC.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              } else {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }

  String timeAgo(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString).toLocal();
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inSeconds < 60) {
        return "${difference.inSeconds} seconds ago";
      }
      else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago";
      }
      else if (difference.inHours < 24) {
        return "${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago";
      }
      else if (difference.inDays < 7) {
        return "${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago";
      }
      else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return "$weeks ${weeks == 1 ? 'week' : 'weeks'} ago";
      }
      else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return "$months ${months == 1 ? 'month' : 'months'} ago";
      }
      else {
        final years = (difference.inDays / 365).floor();
        return "$years ${years == 1 ? 'year' : 'years'} ago";
      }

    } catch (e) {
      return "";
    }
  }

}
