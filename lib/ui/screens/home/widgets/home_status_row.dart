import 'package:eClassify/new_development/status/widgets/home_status_strip.dart';
import 'package:eClassify/ui/screens/home/widgets/home_add_listing_button.dart';
import 'package:flutter/material.dart';

/// Home header row: tricolor Add Listing (left) + status strip (right).
class HomeStatusRow extends StatelessWidget {
  const HomeStatusRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 8, bottom: 0),
      child: SizedBox(
        height: 110,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            HomeAddListingButton(),
            Expanded(child: HomeStatusStrip()),
          ],
        ),
      ),
    );
  }
}
