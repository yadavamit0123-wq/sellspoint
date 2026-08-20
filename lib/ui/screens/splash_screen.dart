import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app_config.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/cubits/system/system_settings_cubit.dart';
import 'package:eClassify/data/model/core/language.dart';
import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/ui/screens/widgets/custom_image.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icon.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const SplashScreen(),
    );
  }
}

class _SplashScreenState extends State<SplashScreen> {
  // Completers used to coordinate the asynchronous startup flow.
  // Using Completers allows us to sequentially fetch configuration settings,
  // load localized language assets, and transition screens.
  late Completer<SystemSettings> _settingsCompleter;
  late Completer<void> _languageCompleter;

  // Holds the error context when setting or language retrieval fails,
  // prompting a screen update to render the retry error widget.
  Object? _error;

  @override
  void initState() {
    super.initState();
    _startNavigationFlow();
  }

  /// Runs the step-by-step sequence of asynchronous actions required to boot the application.
  ///
  /// 1. Concurrently starts fetching system settings and home screen configurations.
  /// 2. Suspends until system settings are retrieved successfully.
  /// 3. Dispatches language localization fetching based on user-configured or default parameters.
  /// 4. Suspends until the localization file has finished loading.
  /// 5. Validates system modes (like Maintenance mode) and user authentication status,
  ///    routing the user to the correct initial page.
  void _startNavigationFlow() async {
    try {
      // Re-instantiate the completers on each loading attempt to avoid caching past results.
      _settingsCompleter = Completer<SystemSettings>();
      _languageCompleter = Completer<void>();

      context.read<SystemSettingsCubit>().getSystemSettings();
      context.read<HomeConfigurationCubit>().getHomeConfiguration();

      // Step 1: Wait for system settings (avoid infinite splash if API hangs)
      final settings = await _settingsCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Loading app settings timed out'),
      );

      // Step 2: Load default or active locale settings
      _loadLanguage(
        currentLanguageCode: settings.currentLanguageCode,
        defaultLanguage: settings.defaultLanguage,
      );

      // Step 3: Wait for language translations to be downloaded
      await _languageCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Loading language timed out'),
      );

      // Step 4: Route the user based on settings and authentication states
      if (settings.maintenanceMode) {
        Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
      } else if (HiveUtils.isUserFirstTime()) {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      } else if (HiveUtils.isUserAuthenticated()) {
        Navigator.of(
          context,
        ).pushReplacementNamed(Routes.main, arguments: {'from': "main"});
      } else if (HiveUtils.isUserSkip()) {
        Navigator.of(
          context,
        ).pushReplacementNamed(Routes.main, arguments: {'from': "main"});
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    } catch (e) {
      // Catch failure states bubbled up through the completers
      _error = e;
      setState(() {});
    }
  }

  /// Loads the language translations from either the app session storage
  /// (if active and matching) or fallbacks to the settings' default language.
  void _loadLanguage({
    required String currentLanguageCode,
    required Language defaultLanguage,
  }) {
    final persistedLanguage = AppSession.currentLanguage;
    // Check if the persisted language is still valid and matches the current language.
    if (persistedLanguage != null &&
        persistedLanguage.languageCode == currentLanguageCode) {
      context.read<LanguageCubit>().loadLanguage(persistedLanguage);
    } else {
      context.read<LanguageCubit>().loadLanguage(defaultLanguage);
    }
  }

  Widget? _companyLogo() {
    if (AppConfig.showCompanyLogo) {
      return SafeArea(
        child: Padding(
          padding: Constant.safeAreaMinimumPadding,
          child: SizedBox(
            height: kToolbarHeight,
            child: Center(
              child: CustomImage(
                src: AppIcons.companyLogo,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Material(
        color: context.colorScheme.surface,
        child: Center(
          child: QErrorWidget(
            error: _error,
            onRetry: () {
              _error = null;
              setState(() {});
              _startNavigationFlow();
            },
          ),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
        // Listens for system setting fetch outcomes and completes/errors the settings completer.
        BlocListener<SystemSettingsCubit, SystemSettingsState>(
          listener: (context, state) {
            if (state is SystemSettingsSuccess) {
              if (!_settingsCompleter.isCompleted) {
                _settingsCompleter.complete(state.settings);
              }
            }
            if (state is SystemSettingsFailure) {
              if (!_settingsCompleter.isCompleted) {
                _settingsCompleter.completeError(state.error);
              }
            }
          },
        ),
        // Listens for language loading outcomes and completes/errors the language completer.
        BlocListener<LanguageCubit, LanguageState>(
          listener: (context, state) {
            if (state is LanguageFetchSuccess) {
              if (!_languageCompleter.isCompleted) {
                _languageCompleter.complete();
              }
            }
            if (state is LanguageFailure) {
              if (!_languageCompleter.isCompleted) {
                _languageCompleter.completeError(state.error);
              }
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.color.territoryColor,
        bottomNavigationBar: _companyLogo(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            CustomImage(
              src: AppIcons.splashLogo,
              size: const Size.square(150),
              fit: BoxFit.scaleDown,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  CustomText(
                    AppConfig.applicationName,
                    fontSize: context.font.xxLarge,
                    color: context.color.secondaryColor,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                  CustomText(
                    '"${"buyAndSellAnything".translate(context)}"',
                    fontSize: context.font.smaller,
                    color: context.color.secondaryColor,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
