import 'package:eClassify/data/cubits/category/main_category_cubit.dart';
import 'package:eClassify/data/cubits/chat/chat_list_cubit.dart';
import 'package:eClassify/data/cubits/chat/seller_item_offers_cubit.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/location/leaf_location_cubit.dart';
import 'package:eClassify/data/cubits/report/report_reason_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/repositories/category/category_store.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/extensions/lib/gap.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:eClassify/utils/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagesListScreen extends StatefulWidget {
  const LanguagesListScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => const LanguagesListScreen());
  }

  @override
  State<LanguagesListScreen> createState() => _LanguagesListScreenState();
}

class _LanguagesListScreenState extends State<LanguagesListScreen> {
  final String _currentLanguageCode = AppSession.currentLanguageCode;
  bool hasLanguageChanged = false;

  void _onBackPressed() {
    if (hasLanguageChanged &&
        _currentLanguageCode != AppSession.currentLanguageCode) {
      final location = AppSession.currentLocation;
      context.read<LeafLocationCubit>().refresh();
      CategoryStore.instance.clearCache(all: true);
      context.read<MainCategoryCubit>().fetch();
      // This will re-fetch the reasons from the API on the next item report
      // with the current language
      context.read<ReportReasonCubit>().clear();

      // We don't need to wait for refresh to complete to call the below apis
      // because refresh is only for translation updates and the below apis
      // expects english or default values, hence we can rely on previous state
      // without any issue.
      //
      // We only call these apis here if the location is null in which case, the refresh()
      // function above will be No-Op hence the listener in home_screen will not be triggered.
      // If we remove this check then there are multiple api calls as the home screen
      // is also listening to the change in LeafLocationCubit and calling these apis accordingly
      // hence to avoid multiple calls we wrap it with this condition.
      if (location == null) {
        context.read<HomeConfigurationCubit>().getHomeConfiguration();
        if (HiveUtils.isUserAuthenticated()) {
          context.read<SellerItemOffersCubit>().getOffers();
          context.read<BuyingChatListCubit>().getChatUsers();
        }
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final languages = Constant.systemSettings.languages;
    final currentLanguageCode = context.select<LanguageCubit, String>(
      (c) => switch (c.state) {
        LanguageFetchSuccess(:final language) => language.languageCode,
        _ => AppSession.currentLanguageCode,
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _onBackPressed();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("chooseLanguage".translate(context)),
          leading: BackButton(onPressed: _onBackPressed),
        ),
        body: BlocListener<LanguageCubit, LanguageState>(
          listener: (context, state) {
            if (state is LanguageLoading) {
              LoadingOverlay.show(context);
            }
            if (state is LanguageFetchSuccess) {
              LoadingOverlay.hide();
              hasLanguageChanged = true;
            }
            if (state is LanguageFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.error.toString());
            }
          },
          child: SafeArea(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: languages.length,
              padding: Constant.appContentPadding.copyWith(top: 20),
              itemBuilder: (context, index) {
                final language = languages[index];

                final selected = currentLanguageCode == language.languageCode;

                return ListTile(
                  minTileHeight: 70,
                  selected: selected,
                  selectedTileColor: context.colorScheme.primary,
                  selectedColor: context.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    context.read<LanguageCubit>().loadLanguage(language);
                  },
                  leading: SizedBox.fromSize(
                    size: Size.square(42),
                    child: CustomImage(
                      src: languages[index].image,
                      radius: 21,
                      size: Size.square(42),
                      fit: BoxFit.cover,
                    ),
                  ),
                  subtitle: language.englishName.isNotNullAndNotEmpty
                      ? Text(language.englishName)
                      : null,
                  title: Text(language.name),
                );
              },
              separatorBuilder: (context, index) => 8.vGap,
            ),
          ),
        ),
      ),
    );
  }
}
