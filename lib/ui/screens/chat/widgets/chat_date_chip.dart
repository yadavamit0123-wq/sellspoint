import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/date_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDateChip extends StatelessWidget {
  const ChatDateChip({required this.date, super.key});

  final DateTime date;

  String _getRelativeDate(BuildContext context) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(now, date)) {
      return 'today'.translate(context);
    } else if (DateUtils.isSameDay(
      now.subtract(const Duration(days: 1)),
      date,
    )) {
      return 'yesterday'.translate(context);
    } else {
      return date.format(formatString: DateFormat.YEAR_MONTH_DAY);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              _getRelativeDate(context),
              style: context.labelLarge.withColor(
                context.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
