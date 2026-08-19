import 'package:eClassify/app/routes.dart';
import 'package:eClassify/new_development/status/models/status_models.dart';
import 'package:eClassify/new_development/status/widgets/status_list_widgets.dart';
import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final List<StatusModel> allStatus;
  final double height;

  const StatusWidget({super.key, required this.allStatus, this.height = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allStatus.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, idx) {
          final status = allStatus[idx];

          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.statusStoriesViewer,
                arguments: {
                  'allUsers': allStatus,
                  'initialUserIndex': idx,
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: StatusListItem(
                status: status,
                avatarSize: 60,      // WhatsApp size
                ringThickness: 5,    // WhatsApp ring
              ),
            ),
          );
        },
      ),
    );
  }
}
