import 'package:eClassify/data/cubits/home/fetch_home_all_items_cubit.dart';
import 'package:eClassify/ui/screens/ad_banner_screen.dart';
import 'package:eClassify/ui/screens/home/widgets/grid_list_adapter.dart';
import 'package:eClassify/ui/screens/home/widgets/home_sections_adapter.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_internet.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({super.key, this.showGoogleBanner = false});

  /// When true, shows Google banner below the grid (2.14 `all_ads` section).
  final bool showGoogleBanner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FetchHomeAllItemsCubit, FetchHomeAllItemsState>(
      builder: (context, state) {
        if (state is FetchHomeAllItemsSuccess) {
          if (state.items.isNotEmpty) {
            const int crossAxisCount = 2;
            final int items = state.items.length;
            final int total = (items ~/ crossAxisCount) +
                (items % crossAxisCount != 0 ? 1 : 0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
                  child: Text(
                    'allAds'.translate(context),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: context.font.large,
                      color: context.color.textDefaultColor,
                    ),
                  ),
                ),
                GridListAdapter(
                  type: ListUiType.List,
                  crossAxisCount: 2,
                  builder: (context, int index, bool isGrid) {
                    int itemIndex = index * crossAxisCount;
                    return SizedBox(
                      height: (MediaQuery.sizeOf(context).height / 3.5) + 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < crossAxisCount; ++i) ...[
                            Expanded(
                              child: itemIndex + 1 <= items
                                  ? ItemCard(item: state.items[itemIndex++])
                                  : const SizedBox.shrink(),
                            ),
                            if (i != crossAxisCount - 1)
                              const SizedBox(width: 15),
                          ],
                        ],
                      ),
                    );
                  },
                  listSeparator: (context, index) {
                    if (index == 0 ||
                        index % Constant.nativeAdsAfterItemNumber != 0) {
                      return const SizedBox(height: 15);
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 5),
                        AdBannerWidget(),
                        const SizedBox(height: 5),
                      ],
                    );
                  },
                  total: total,
                ),
                if (state.isLoadingMore) UiUtils.progress(),
                if (showGoogleBanner &&
                    Constant.isGoogleBannerAdsEnabled == '1') ...[
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: AdBannerWidget(),
                  ),
                ],
              ],
            );
          }
          return const SizedBox.shrink();
        }
        if (state is FetchHomeAllItemsFail) {
          if (state.error is ApiException) {
            if (state.error.error == 'no-internet') {
              return const Center(child: NoInternet());
            }
          }
          return const SomethingWentWrong();
        }
        return const SizedBox.shrink();
      },
    );
  }
}
