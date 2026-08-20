import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/subscription/assign_free_package_cubit.dart';
import 'package:eClassify/data/cubits/subscription/get_payment_intent_cubit.dart';
import 'package:eClassify/data/cubits/subscription/iap_cubit.dart';
import 'package:eClassify/data/cubits/subscription/subscription_package_cubit.dart';
import 'package:eClassify/data/cubits/system/get_payment_methods_cubit.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/data/model/subscription/subscription_package.dart';
import 'package:eClassify/ui/screens/subscription/payment_handler.dart';
import 'package:eClassify/ui/screens/subscription/payment_listener_wrapper.dart';
import 'package:eClassify/ui/screens/subscription/payment_method_selector.dart';
import 'package:eClassify/ui/screens/subscription/widgets/free_package_purchase_dialog.dart';
import 'package:eClassify/ui/screens/subscription/widgets/package_selector.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscriptionPackageScreen extends StatefulWidget {
  const SubscriptionPackageScreen({
    required this.category,
    required this.showCategorySelection,
    super.key,
  });

  final Category? category;
  final bool showCategorySelection;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SubscriptionPackageCubit()),
          BlocProvider(create: (_) => GetPaymentIntentCubit()),
          BlocProvider(create: (_) => AssignFreePackageCubit()),
          // IapCubit is scoped locally here — iOS only, but safe to register
          // on both platforms since buy() is only called when Platform.isIOS.
          BlocProvider(create: (_) => IapCubit()),
        ],
        child: SubscriptionPackageScreen(
          category: args?['category'] as Category?,
          showCategorySelection: args?['show_category_selection'] ?? true,
        ),
      ),
    );
  }

  @override
  State<SubscriptionPackageScreen> createState() =>
      _SubscriptionPackageScreenState();
}

class _SubscriptionPackageScreenState extends State<SubscriptionPackageScreen>
    with WidgetsBindingObserver {
  final ValueNotifier<SubscriptionPackage?> _selectedPackage =
      ValueNotifier<SubscriptionPackage?>(null);

  final ValueNotifier<String?> _selectedGateway = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SubscriptionPackageCubit>().getPackages(
      type: widget.category == null
          ? SubscriptionPackageType.featuredAds
          : SubscriptionPackageType.itemListing,
      categoryId: widget.category?.id,
    );
    if (HiveUtils.isUserAuthenticated()) {
      context.read<GetPaymentMethodsCubit>().fetch();
    }
    // Start listening to the App Store purchase stream (iOS only).
    // The cubit owns the subscription; it is cancelled on cubit.close().
    if (Platform.isIOS) {
      context.read<IapCubit>().startListening();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _selectedPackage.dispose();
    _selectedGateway.dispose();
    // IapCubit is closed automatically by BlocProvider when the widget
    // is removed from the tree — no manual dispose needed.
    super.dispose();
  }

  /// StoreKit does not emit a `canceled` event when the payment sheet is
  /// swiped away interactively. Detecting app resume while still in
  /// IapInProgress is the only reliable way to unlock the loading state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isIOS) {
      //context.read<IapCubit>().resetIfStuck();
    }
  }

  void _handlePurchase() async {
    final package = _selectedPackage.value!;
    if (package.isFree) {
      final shouldPurchase =
          await FreePackagePurchaseDialog.show(context) ?? false;
      if (!shouldPurchase) return;
      context.read<AssignFreePackageCubit>().assignFreePackage(
        packageId: package.id,
      );
    } else if (Platform.isIOS) {
      // On iOS, always use App Store IAP regardless of which payment
      // gateways are configured on the backend.
      final productId = package.iosProductId;
      if (productId == null || productId.isEmpty) {
        HelperUtils.showSnackBarMessage(
          context,
          'iapProductNotFound'.translate(context),
        );
        return;
      }
      context.read<IapCubit>().buy(productId: productId, packageId: package.id);
    } else {
      _selectedGateway.value = null;
      _selectedGateway.value = await PaymentMethodSelector.show(
        context,
        initialGateway: _selectedGateway.value,
      );
      if (_selectedGateway.value != null) {
        PaymentHandler.processPayment(
          context: context,
          selectedGateway: _selectedGateway.value!,
          packageId: package.id,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category != null
              ? 'adListingPlan'.translate(context)
              : 'featuredAdsPlan'.translate(context),
        ),
        actions: [
          // ======= NOTE ======= //
          // This button was originally added to meet Apple’s iOS subscription guidelines,
          // as apps were being rejected when a Restore Purchases option was missing.
          // It was reintroduced in v2.3.0 for compliance.
          //
          // Recently, however, Apple started rejecting builds because of this button,
          // so it has been temporarily commented out.
          //
          // If Apple requires the Restore Purchases option again,
          // simply uncomment this section to restore it.

          // if (Platform.isIOS)
          //   CupertinoButton(
          //     child: Text("restore".translate(context)),
          //     onPressed: () async {
          //       await InAppPurchase.instance.restorePurchases();
          //     },
          //   ),
        ],
      ),
      bottomNavigationBar:
          BlocBuilder<SubscriptionPackageCubit, SubscriptionPackageState>(
            builder: (context, state) {
              if (state is! SubscriptionPackageSuccess) return const SizedBox();
              return SafeArea(
                minimum: Constant.safeAreaMinimumPadding,
                child: ValueListenableBuilder(
                  valueListenable: _selectedPackage,
                  builder: (context, value, child) {
                    final canPurchase = value != null && value.isPurchasable;
                    return FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: Size.fromHeight(48),
                      ),
                      onPressed: canPurchase
                          ? () => UiUtils.checkUser(
                              context: context,
                              onNotGuest: () => _handlePurchase(),
                            )
                          : null,
                      child: Text(switch ((value, canPurchase, value?.isFree)) {
                        (_, true, false) =>
                          '${'pay'.translate(context)} ${value!.formattedDiscountedPrice}',
                        (_, _, _) => 'purchase'.translate(context),
                      }),
                    );
                  },
                ),
              );
            },
          ),
      body: PaymentListenerWrapper(
        package: _selectedPackage,
        selectedGateway: _selectedGateway,
        child: Padding(
          padding: Constant.appContentPadding,
          child: Column(
            spacing: 20,
            children: [
              if (widget.category != null && widget.showCategorySelection)
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.subscriptionCategorySelectionScreen,
                      (route) =>
                          route.settings.name == Routes.subscriptionScreen ||
                          route.isFirst,
                    );
                  },
                  leading: (widget.category?.image).isNotNullAndNotEmpty
                      ? CustomImage(
                          src: widget.category!.image,
                          size: Size.square(40),
                          radius: 20,
                        )
                      : Icon(
                          AppIcons.globe,
                          color: context.colorScheme.primary,
                        ),
                  title: Text(switch (widget.category?.name.localized) {
                    final value when value.isNotNullAndNotEmpty => value!,
                    _ => 'globalPackage'.translate(context),
                  }, style: context.labelLarge),
                  trailing: IconButton(
                    style: IconButton.styleFrom(
                      disabledForegroundColor: context.colorScheme.onSurface,
                      disabledBackgroundColor: context.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      iconSize: 20,
                    ),
                    onPressed: null,
                    icon: Icon(AppIcons.pencilSimpleLine),
                  ),
                ),
              Expanded(
                child:
                    BlocBuilder<
                      SubscriptionPackageCubit,
                      SubscriptionPackageState
                    >(
                      builder: (context, state) {
                        if (state is SubscriptionPackageLoading) {
                          return Center(child: UiUtils.progress());
                        }
                        if (state is SubscriptionPackageFailure) {
                          return QErrorWidget(
                            error: state.error,
                            onRetry: () {
                              context
                                  .read<SubscriptionPackageCubit>()
                                  .getPackages(
                                    type: widget.category == null
                                        ? SubscriptionPackageType.featuredAds
                                        : SubscriptionPackageType.itemListing,
                                    categoryId: widget.category?.id,
                                  );
                            },
                          );
                        }
                        if (state is SubscriptionPackageSuccess) {
                          if (state.packages.isEmpty) {
                            return const QErrorWidget.emptyData();
                          }
                          return PackageSelector(
                            packages: state.packages,
                            onSelect: (value) {
                              _selectedPackage.value = value;
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
