import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/ui/screens/widgets/full_screen_image_view.dart';
import 'package:eClassify/ui/screens/widgets/loading_indicator.dart';
import 'package:eClassify/ui/screens/widgets/toast_message.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/currency_formatter.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/login_required_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UiUtils {
  static SystemUiOverlayStyle getSystemUiOverlayStyle({
    required BuildContext context,
    Color? statusBarColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: statusBarColor,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    );
  }

  // Temporary
  // This is to fulfil the case when bottom-sheet cannot show default snack-bars
  // due to absence of Scaffold widget.
  static Future<void> showOverlaySnackBar({
    required BuildContext context,
    required String message,
    MessageType? type,
  }) async {
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => ToastMessage(
        backgroundColor: type?.value ?? context.color.inverseThemeColor,
        errorMessage: message,
      ),
    );

    overlayState.insert(overlayEntry);
    await Future<void>.delayed(const Duration(milliseconds: 3000));
    overlayEntry.remove();
  }

  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    double? height,
    bool isDismissible = true,
    bool isDraggable = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      enableDrag: isDraggable,
      constraints: BoxConstraints(
        maxHeight: height ?? MediaQuery.sizeOf(context).height * .8,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) =>
          Padding(padding: MediaQuery.viewInsetsOf(context), child: child),
    );
  }

  static void checkUser({
    required Function() onNotGuest,
    required BuildContext context,
  }) {
    if (HiveUtils.isUserAuthenticated()) {
      onNotGuest.call();
    } else {
      LoginRequiredBottomSheet.show(context);
    }
  }

  static void imagePickerBottomSheet(
    BuildContext context, {
    Function? callback,
    bool isRemovalWidget = false,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(AppIcons.images),
                title: CustomText("gallery".translate(context)),
                onTap: () async {
                  if (callback != null) callback(false, ImageSource.gallery);

                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(AppIcons.camera),
                title: CustomText("camera".translate(context)),
                onTap: () async {
                  if (callback != null) callback(false, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (isRemovalWidget)
                ListTile(
                  leading: const Icon(AppIcons.x),
                  title: CustomText("lblremove".translate(context)),
                  onTap: () {
                    if (callback != null) callback(true, null);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @Deprecated('Use LoadingIndicator instead')
  static Widget progress({double? width, double? height, Color? color}) {
    return LoadingIndicator(size: Size(width ?? 70, height ?? 70));
  }

  @Deprecated("Use Flutter's AppBar Instead")
  static PreferredSizeWidget buildAppBar(
    BuildContext context, {
    String? title,
    bool showBackButton = false,
    List<Widget>? actions,
    Widget? bottom,
    double? bottomHeight,
    bool? hideTopBorder,
    VoidCallback? onBackPress,
    Color? backgroundColor,
  }) {
    return AppBar(
      backgroundColor: backgroundColor,
      title: Text(title ?? ''),
      leading: showBackButton ? BackButton(onPressed: onBackPress) : null,
      actions: actions,
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? kToolbarHeight),
              child: bottom,
            )
          : null,
    );
  }

  @Deprecated(
    "Use Flutter's FilledButton, OutlinedButton or ElevatedButton Instead",
  )
  static Widget buildButton(
    BuildContext context, {
    double? height,
    double? width,
    BorderSide? border,
    double? fontSize,
    double? radius,
    bool? autoWidth,
    Widget? prefixWidget,
    EdgeInsetsGeometry? padding,
    required VoidCallback onPressed,
    required String buttonTitle,
    bool? showElevation,
    Color? textColor,
    Color? buttonColor,
    EdgeInsetsGeometry? outerPadding,
    Color? disabledColor,
    VoidCallback? onTapDisabledButton,
    bool disabled = false,
  }) {
    String title = buttonTitle;

    return Padding(
      padding: outerPadding ?? EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          if (disabled) {
            onTapDisabledButton?.call();
          }
        },
        child: MaterialButton(
          minWidth: autoWidth == true ? null : (width ?? double.infinity),
          height: height ?? 56,
          padding: padding,
          shape: RoundedRectangleBorder(
            side: border ?? BorderSide.none,
            borderRadius: BorderRadius.circular(radius ?? 8),
          ),
          elevation: (showElevation ?? true) ? 0.5 : 0,
          color: buttonColor ?? context.color.territoryColor,
          disabledColor: disabledColor ?? context.color.deactivateColor,
          onPressed: disabled
              ? null
              : () {
                  HelperUtils.unfocus();
                  onPressed.call();
                },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefixWidget != null) prefixWidget,
              Flexible(
                child: CustomText(
                  title,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  color: textColor ?? context.color.buttonColor,
                  fontSize: fontSize ?? context.font.larger,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showFullScreenImage(
    BuildContext context, {
    required ImageProvider provider,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        barrierDismissible: true,
        builder: (BuildContext context) =>
            FullScreenImageView(provider: provider),
      ),
    );
  }

  static bool displayPrice(ItemModel item) {
    final category = item.category!;

    if (category.isJobCategory) {
      return item.formattedSalary != null;
    } else if (category.isPriceOptional) {
      return item.formattedPrice != null;
    } else {
      return true;
    }
  }

  static Widget getPriceWidget(ItemModel item, BuildContext context) {
    final category = item.category!;
    final color = context.color.territoryColor;

    if (category.isJobCategory) {
      return CustomText(
        '${item.formattedSalary}',
        color: color,
        fontWeight: FontWeight.bold,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        fontSize: context.font.large,
        maxLines: 1,
      );
    } else if (category.isPriceOptional) {
      if (item.price != null) {
        return CustomText(
          item.formattedPrice ?? item.price!.currencyFormat(),
          color: color,
          fontWeight: FontWeight.bold,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          fontSize: context.font.large,
          maxLines: 1,
        );
      }
    } else {
      return CustomText(
        item.formattedPrice ?? (item.price ?? 0.0).currencyFormat(),
        color: color,
        fontWeight: FontWeight.bold,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        fontSize: context.font.larger,
        maxLines: 1,
      );
    }

    return SizedBox.shrink();
  }

  static String formatDisplayAddress(String address) {
    // Split by comma and trim extra spaces
    List<String> parts = address.split(',').map((e) => e.trim()).toList();

    // Remove consecutive duplicates
    List<String> uniqueParts = [];
    for (int i = 0; i < parts.length; i++) {
      if (i == 0 || parts[i].toLowerCase() != parts[i - 1].toLowerCase()) {
        uniqueParts.add(parts[i]);
      }
    }

    // Join back into formatted address
    return uniqueParts.join(', ');
  }
}

///Format string
extension FormatAmount on String {
  String formatDate({String? format}) {
    DateFormat dateFormat;
    final locale = DateFormat.localeExists(AppSession.currentLocale)
        ? AppSession.currentLocale
        : Intl.defaultLocale;
    dateFormat = DateFormat(format ?? "MMM d, yyyy", locale);
    String formatted = dateFormat.format(DateTime.parse(this));
    return formatted;
  }

  String firstUpperCase() {
    String upperCase = "";
    var suffix = "";
    if (isNotEmpty) {
      upperCase = this[0].toUpperCase();
      suffix = substring(1, length);
    }
    return (upperCase + suffix);
  }
}

//scroll controller extenstion

extension ScrollEndListen on ScrollController {
  /// Detect near-bottom instead of exact end to reduce repeated triggers
  bool isEndReached({double offsetThreshold = 400}) {
    if (!hasClients || position.outOfRange) return false;
    return position.extentAfter < offsetThreshold;
  }
}

class RemoveGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
