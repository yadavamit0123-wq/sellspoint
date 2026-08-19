import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/widgets/package_widget.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:flutter/material.dart';

class PackageSelector extends StatefulWidget {
  const PackageSelector({
    required this.packages,
    required this.onSelect,
    super.key,
  });
  final List<SubscriptionPackage> packages;
  final ValueChanged<SubscriptionPackage> onSelect;

  @override
  State<PackageSelector> createState() => _PackageSelectorState();
}

class _PackageSelectorState extends State<PackageSelector> {
  SubscriptionPackage? _selectedPackage;

  void _onPackageSelect(SubscriptionPackage? package) {
    if (package == null || package.isActive) return;
    if (!package.isPurchasable) {
      HelperUtils.showSnackBarMessage(
        context,
        'freePackagePurchaseWarning'.translate(context),
      );
      return;
    }
    _selectedPackage = package;
    setState(() {});
    widget.onSelect(package);
  }

  @override
  Widget build(BuildContext context) {
    return RadioGroup<SubscriptionPackage>(
      groupValue: _selectedPackage,
      onChanged: _onPackageSelect,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          final package = widget.packages[index];
          return GestureDetector(
            onTap: () => _onPackageSelect(package),
            child: PackageWidget(
              package: package,
              isSelected: package == _selectedPackage,
              activePlanCapLabel: 'activePlan'.translate(context),
            ),
          );
        },
        separatorBuilder: (context, index) => 10.vGap,
        itemCount: widget.packages.length,
      ),
    );
  }
}
