import 'package:eClassify/data/cubits/add_item_review_cubit.dart';
import 'package:eClassify/ui/screens/widgets/rating/rating_bar.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/extensions/lib/translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({required this.itemId, super.key});

  final int itemId;

  static Future<void> show(BuildContext context, {required int itemId}) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => BlocProvider.value(
        value: context.read<AddItemReviewCubit>(),
        child: RatingDialog(itemId: itemId),
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 0;
  final TextEditingController _feedbackController = TextEditingController();
  final ValueNotifier<bool> _isValid = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _feedbackController.dispose();
    _isValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          'rateSeller'.translate(context),
          style: TextStyle(
            color: context.colorScheme.onSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'rateYourExperience'.translate(context),
              style: TextStyle(color: context.colorScheme.onTertiaryContainer),
            ),
            10.vGap,
            RatingBar(
              defaultIconSize: 40,
              count: 5,
              onChanged: (value) {
                _rating = value;
              },
            ),
            2.vGap,
            ValueListenableBuilder(
              valueListenable: _isValid,
              builder: (context, value, child) {
                return value
                    ? const SizedBox.shrink()
                    : Text(
                        'Rating cannot be zero',
                        style: context.labelSmall.withColor(
                          StatusColors.errorMessageColor,
                        ),
                      );
              },
            ),
            16.vGap,
            TextField(
              controller: _feedbackController,
              cursorColor: context.colorScheme.primary,
              decoration: InputDecoration(
                hintText: 'shareYourExperience'.translate(context),
              ),
              maxLines: 3,
            ),
            16.vGap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("cancel".translate(context)),
                ),
                FilledButton(
                  onPressed: () async {
                    if (_rating == 0) {
                      _isValid.value = false;
                      return;
                    }
                    await context.read<AddItemReviewCubit>().addItemReview(
                      itemId: widget.itemId,
                      rating: _rating,
                      review: _feedbackController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text("submit".translate(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
