import 'package:eClassify/data/cubits/chat/get_buyer_chat_users_cubit.dart';
import 'package:eClassify/data/cubits/chat/get_seller_chat_users_cubit.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/app_assets.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Five-tab bar (Home, Chat, Video, My ads, Profile) — no center notch; FAB is separate.
class CustomBottomNavigationBarV214 extends StatelessWidget {
  const CustomBottomNavigationBarV214({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static final _items = [
    _NavItem(
      index: 0,
      icon: AppAssets.bottomNavigation.home,
      activeIcon: AppAssets.bottomNavigation.homeActive,
      labelKey: 'homeTab',
      requiresAuth: false,
    ),
    _NavItem(
      index: 1,
      icon: AppAssets.bottomNavigation.chat,
      activeIcon: AppAssets.bottomNavigation.chatActive,
      labelKey: 'chat',
      requiresAuth: true,
    ),
    _NavItem(
      index: 2,
      icon: AppAssets.bottomNavigation.videoAds,
      activeIcon: AppAssets.bottomNavigation.videoAdsActive,
      labelKey: 'videoAd',
      requiresAuth: false,
    ),
    _NavItem(
      index: 3,
      icon: AppAssets.bottomNavigation.myAds,
      activeIcon: AppAssets.bottomNavigation.myAdsActive,
      labelKey: 'myAdsTab',
      requiresAuth: true,
    ),
    _NavItem(
      index: 4,
      icon: AppAssets.bottomNavigation.profile,
      activeIcon: AppAssets.bottomNavigation.profileActive,
      labelKey: 'profileTab',
      requiresAuth: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: context.color.secondaryColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight + (bottomInset > 0 ? 0 : 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
            child: Row(
              children: _items.map((item) {
                Widget tab = _TabTile(
                  item: item,
                  selected: currentIndex == item.index,
                  onTap: () {
                    if (item.requiresAuth) {
                      UiUtils.checkUser(
                        onNotGuest: () => onTap(item.index),
                        context: context,
                      );
                      return;
                    }
                    onTap(item.index);
                  },
                );
                if (item.index == 1) {
                  tab = _ChatUnreadBadge(child: tab);
                }
                return Expanded(child: tab);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    required this.requiresAuth,
  });

  final int index;
  final String icon;
  final String activeIcon;
  final String labelKey;
  final bool requiresAuth;
}

class _TabTile extends StatelessWidget {
  const _TabTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UiUtils.getSvg(
            selected ? item.activeIcon : item.icon,
            color: selected
                ? context.color.textDefaultColor
                : context.color.textLightColor.darken(30),
          ),
          CustomText(
            item.labelKey.translate(context),
            textAlign: TextAlign.center,
            maxLines: 1,
            color: selected
                ? context.color.textDefaultColor
                : context.color.textLightColor.darken(30),
          ),
        ],
      ),
    );
  }
}

class _ChatUnreadBadge extends StatelessWidget {
  const _ChatUnreadBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetBuyerChatListCubit, GetBuyerChatListState>(
      builder: (context, buyerState) {
        return BlocBuilder<GetSellerChatListCubit, GetSellerChatListState>(
          builder: (context, sellerState) {
            var unread = 0;
            if (buyerState is GetBuyerChatListSuccess) {
              unread += buyerState.chatedUserList.fold(
                0,
                (sum, u) => sum + (u.unreadCount ?? 0),
              );
            }
            if (sellerState is GetSellerChatListSuccess) {
              unread += sellerState.chatedUserList.fold(
                0,
                (sum, u) => sum + (u.unreadCount ?? 0),
              );
            }
            if (unread <= 0) return child;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                child,
                Positioned(
                  top: 0,
                  right: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
