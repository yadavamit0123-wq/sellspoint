import 'package:eClassify/ui/screens/widgets/app_dialog.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';

class CreateOfferDialog {
  static Future<double?> show(
    BuildContext context, {
    required String formattedPrice,
    required double price,
  }) {
    return showDialog<double>(
      context: context,
      builder: (context) {
        return _CreateOfferDialogContent(
          formattedPrice: formattedPrice,
          price: price,
        );
      },
    );
  }
}

class _CreateOfferDialogContent extends StatefulWidget {
  const _CreateOfferDialogContent({
    required this.formattedPrice,
    required this.price,
  });

  final String formattedPrice;
  final double price;

  @override
  State<_CreateOfferDialogContent> createState() =>
      _CreateOfferDialogContentState();
}

class _CreateOfferDialogContentState extends State<_CreateOfferDialogContent> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormFieldState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Text('makeAnOffer'.translate(context), style: context.titleLarge),
      content: Column(
        children: [
          const Divider(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'sellerPrice'.translate(context),
                  style: context.titleMedium.withColor(context.mutedColor),
                ),
                TextSpan(
                  text: ' : ${widget.formattedPrice}',
                  style: context.titleMedium.bold,
                ),
              ],
            ),
          ),
          16.vGap,
          TextFormField(
            controller: _controller,
            key: _formKey,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: context.titleLarge,
            validator: (value) {
              if (value.isNullOrEmpty) {
                return 'fieldMustNotBeEmpty'.translate(context);
              }
              final offer = double.tryParse(value!);
              if (offer == null) {
                return 'invalidOffer'.translate(context);
              } else if (offer > widget.price) {
                return 'offerPriceWarning'.translate(context);
              } else if (offer <= 0.0) {
                return 'valueMustBeGreaterThanZeroLbl'.translate(context);
              } else {
                return null;
              }
            },
            decoration: InputDecoration(
              fillColor: context.colorScheme.surface,
              filled: true,
              hintText: 'yourOffer'.translate(context),
              hintStyle: context.titleMedium.withColor(context.mutedColor),
            ),
          ),
        ],
      ),
      positiveButtonLabel: 'send'.translate(context),
      onPositiveTapped: () {
        if (!_formKey.currentState!.validate()) return;
        final offer = double.parse(_controller.text);
        Navigator.of(context).pop(offer);
      },
      negativeButtonLabel: 'cancel'.translate(context),
      onNegativeTapped: () {
        Navigator.of(context).pop();
      },
    );
  }
}
