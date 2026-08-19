import 'package:eClassify/data/cubits/currency/currencies_cubit.dart';
import 'package:eClassify/data/model/currency.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyPrefixWidget extends StatelessWidget {
  const CurrencyPrefixWidget({required this.currencyNotifier, super.key});

  final ValueNotifier<Currency> currencyNotifier;

  void _showCurrencyBottomSheet(
    BuildContext context,
    List<Currency> currencies,
  ) async {
    showModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .7,
      ),
      builder: (_) => SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shrinkWrap: true,
          children: currencies.map((c) {
            final isSelected = c.id == currencyNotifier.value.id;
            return ListTile(
              onTap: () {
                currencyNotifier.value = c;
                Navigator.of(context).pop();
              },
              dense: true,
              title: Text(
                '${c.symbol}\t\t\t${c.code}',
                style: context.titleSmall,
              ),
              trailing: isSelected
                  ? Icon(AppIcons.check, color: context.colorScheme.primary)
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencies = context.select<CurrenciesCubit, List<Currency>>(
      (c) => switch (c.state) {
        final CurrenciesSuccess s => s.currencies,
        _ => [Constant.systemSettings.defaultCurrency],
      },
    );

    return GestureDetector(
      onTap: () {
        if (currencies.length > 1) {
          _showCurrencyBottomSheet(context, currencies);
        }
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 100, minWidth: 50),
        child: ValueListenableBuilder(
          valueListenable: currencyNotifier,
          builder: (context, value, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                5.hGap,
                Text(value.symbol, style: context.labelLarge),
                Text(value.code, style: context.labelLarge),
                SizedBox(height: 15, child: VerticalDivider(width: 10)),
              ],
            );
          },
        ),
      ),
    );
  }
}
