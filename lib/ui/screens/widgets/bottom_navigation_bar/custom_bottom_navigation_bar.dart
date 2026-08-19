import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/system/bottom_nav_cubit.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/number_formatter.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom Navigation bar that gives space to the centerDocked FAB button
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final items = [
    _BottomNavigationItem(
      tab: BottomTab.home,
      icon: AppAssets.bottomNavigation.home,
      activeIcon: AppAssets.bottomNavigation.homeActive,
      label: 'homeTab',
    ),
    _BottomNavigationItem(
      tab: BottomTab.chat,
      icon: AppAssets.bottomNavigation.chat,
      activeIcon: AppAssets.bottomNavigation.chatActive,
      label: 'chat',
    ),
    _BottomNavigationItem(
      tab: BottomTab.videoAds,
      icon: AppAssets.bottomNavigation.videoAds,
      activeIcon: AppAssets.bottomNavigation.videoAdsActive,
      label: 'videoAd',
    ),
    _BottomNavigationItem(
      tab: BottomTab.myAds,
      icon: AppAssets.bottomNavigation.myAds,
      activeIcon: AppAssets.bottomNavigation.myAdsActive,
      label: 'myAdsTab',
    ),
    _BottomNavigationItem(
      tab: BottomTab.profile,
      icon: AppAssets.bottomNavigation.profile,
      activeIcon: AppAssets.bottomNavigation.profileActive,
      label: 'profileTab',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // We need SafeArea here because we are not using conventional BottomNavigationBar
    // widget, hence it will not automatically add padding on Android 15 edge-to-edge mode
    double bottomNavHeight = kBottomNavigationBarHeight;
    bottomNavHeight += MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: bottomNavHeight,
      child: ColoredBox(
        color: context.colorScheme.secondary,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
            child: BlocBuilder<BottomNavCubit, BottomTab>(
              builder: (context, state) {
                return Row(
                  children: items.map((item) {
                    Widget child = _BottomNavigationItemWidget(
                      item: item,
                      selected: state == item.tab,
                      onPressed: () {
                        if (item.tab
                            case == BottomTab.chat || BottomTab.myAds) {
                          UiUtils.checkUser(
                            onNotGuest: () {
                              context.read<BottomNavCubit>().changeTab(
                                item.tab,
                              );
                            },
                            context: context,
                          );
                        } else {
                          context.read<BottomNavCubit>().changeTab(item.tab);
                        }
                      },
                    );
                    if (item.tab == BottomTab.chat) {
                      child = _DynamicChatIconWithBadge(child: child);
                    }
                    return Expanded(child: child);
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItemWidget extends StatelessWidget {
  _BottomNavigationItemWidget({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _BottomNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomImage(
            src: selected ? item.activeIcon : item.icon,
            size: Size.square(24),
            fit: BoxFit.scaleDown,
          ),
          Text(
            item.label.translate(context),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: context.labelMedium.withColor(
              selected ? context.colorScheme.onSurface : context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationItem {
  _BottomNavigationItem({
    required this.tab,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final BottomTab tab;
  final String icon;
  final String activeIcon;
  final String label;
}

class _DynamicChatIconWithBadge extends StatelessWidget {
  const _DynamicChatIconWithBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sellerCount = context.select<SellerItemOffersCubit, int>((
      offerCubit,
    ) {
      return switch (offerCubit.state) {
        final SellerItemOffersSuccess s when s.offers.isNotEmpty =>
          s.offers.fold(0, (value, ele) => value + ele.unreadCount),
        _ => 0,
      };
    });

    final buyerCount = context.select<BuyingChatListCubit, int>((buyingCubit) {
      return switch (buyingCubit.state) {
        final ChatListSuccess b when b.users.isNotEmpty => b.users.fold(
          0,
          (value, ele) => value + ele.unreadCount,
        ),
        _ => 0,
      };
    });

    final totalUnread = sellerCount + buyerCount;
    final label = totalUnread.compact;

    return switch (totalUnread) {
      > 0 => Badge(
        alignment: AlignmentDirectional.topCenter.add(
          AlignmentGeometry.directional(.1, 0),
        ),
        backgroundColor: context.colorScheme.tertiary,
        label: Text(
          label,
          style: context.labelSmall.withColor(context.colorScheme.onPrimary),
        ),
        child: child,
      ),
      _ => child,
    };
  }
}
