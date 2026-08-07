import 'package:eClassify/app_config.dart';
import 'package:eClassify/ui/screens/main_activity.dart';

/// Tab index helpers — legacy 4-tab vs 2.14 5-tab shell.
abstract final class MainNavigationV214 {
  static bool get usesFiveTabs => AppConfig.enableFiveTabNavV214;

  static int get myAdsTabIndex => usesFiveTabs ? 3 : 2;

  static int get chatTabIndex => 1;

  static int get homeTabIndex => 0;

  static void openMyAdsTab() {
    MainActivity.globalKey.currentState?.onItemTapped(myAdsTabIndex);
  }

  static void openHomeTab() {
    MainActivity.globalKey.currentState?.onItemTapped(homeTabIndex);
  }
}
