import 'package:eClassify/app/app.dart';
import 'package:eClassify/app/app_localization.dart';
import 'package:eClassify/app/navigator_observer.dart';
import 'package:eClassify/app/register_cubits.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/system/app_theme_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/ui/screens/onboarding/widgets/onboarding_page_view.dart';
import 'package:eClassify/ui/theme/app_theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// v2.14.0 ///

void main() => initApp();

class EntryPoint extends StatelessWidget {
  const EntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: RegisterCubits().providers,
      child: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    if (HiveUtils.isUserFirstTime()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final data in kOnboardingList) {
          final assetName = data['svg'] as String;
          precacheImage(AssetImage(assetName), context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<AppThemeCubit>().state;
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, languageState) {
        final isDark = currentTheme == ThemeMode.dark;

        final overlayStyle = SystemUiOverlayStyle(
          // iOS Only
          statusBarBrightness: isDark
              ? Brightness.dark
              : Brightness.light, // iOS background brightness
          // Android Only
          statusBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark, // Android icons
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        );
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlayStyle,
          child: MaterialApp(
            key: ValueKey(AppConfig.applicationName),
            scrollBehavior: ScrollConfiguration.of(
              context,
            ).copyWith(overscroll: false),
            initialRoute: Routes.splash,
            navigatorKey: Constant.navigatorKey,
            navigatorObservers: [
              Constant.routeObserver,
              AppNavigatorObserver(),
            ],
            title: AppConfig.applicationName,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: Routes.onGenerateRouted,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: currentTheme,
            builder: (context, child) {
              TextDirection direction = TextDirection.ltr;

              if (languageState is LanguageFetchSuccess) {
                direction = languageState.language.isRTL
                    ? TextDirection.rtl
                    : TextDirection.ltr;
              }
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: Directionality(textDirection: direction, child: child!),
              );
            },
            localizationsDelegates: const [
              AppLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: loadLocalLanguageIfFail(languageState),
          ),
        );
      },
    );
  }

  dynamic loadLocalLanguageIfFail(LanguageState state) {
    if ((state is LanguageFetchSuccess)) {
      return Locale(state.language.languageCode, state.language.countryCode);
    } else if (state is LanguageFailure) {
      return const Locale("en");
    }
  }
}
