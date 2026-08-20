import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/home/home_screen_configuration_cubit.dart';
import 'package:eClassify/data/cubits/system/language_cubit.dart';
import 'package:eClassify/data/cubits/system/system_settings_cubit.dart';
import 'package:eClassify/data/model/core/language.dart';
import 'package:eClassify/data/model/system_settings.dart';
import 'package:eClassify/ui/screens/widgets/q_error_widget.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

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
  static const _splashVideoAsset = 'assets/videos/splash_video.mp4';

  late Completer<SystemSettings> _settingsCompleter;
  late Completer<void> _languageCompleter;

  Object? _error;
  SystemSettings? _loadedSettings;
  bool _bootReady = false;
  bool _videoFinished = false;
  bool _videoCompleteFired = false;
  bool _navigated = false;

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  Timer? _splashWatchdog;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _startNavigationFlow();
    // Never block launch if the splash video fails to fire "completed".
    _splashWatchdog = Timer(const Duration(seconds: 15), _markVideoFinished);
  }

  @override
  void dispose() {
    _splashWatchdog?.cancel();
    _controller.removeListener(_onVideoTick);
    _controller.dispose();
    super.dispose();
  }

  void _initVideo() {
    _controller = VideoPlayerController.asset(_splashVideoAsset);
    _controller.setLooping(false);
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.play();
      if (mounted) setState(() {});
    }).catchError((Object _) {
      // If video asset fails, do not block app launch.
      _markVideoFinished();
    });
    _controller.addListener(_onVideoTick);
  }

  void _onVideoTick() {
    final value = _controller.value;
    if (!value.isInitialized || _videoCompleteFired) return;

    final position = value.position;
    final duration = value.duration;
    if (!value.isPlaying &&
        position > Duration.zero &&
        position >= duration) {
      _markVideoFinished();
    }
  }

  void _markVideoFinished() {
    if (_videoCompleteFired) return;
    _videoCompleteFired = true;
    _videoFinished = true;
    _tryNavigate();
  }

  Future<void> _startNavigationFlow() async {
    try {
      _settingsCompleter = Completer<SystemSettings>();
      _languageCompleter = Completer<void>();

      context.read<SystemSettingsCubit>().getSystemSettings();
      context.read<HomeConfigurationCubit>().getHomeConfiguration();

      final settings = await _settingsCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Loading app settings timed out'),
      );

      _loadLanguage(
        currentLanguageCode: settings.currentLanguageCode,
        defaultLanguage: settings.defaultLanguage,
      );

      await _languageCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Loading language timed out'),
      );

      _loadedSettings = settings;
      _bootReady = true;
      _tryNavigate();
    } catch (e) {
      _error = e;
      if (mounted) setState(() {});
    }
  }

  void _loadLanguage({
    required String currentLanguageCode,
    required Language defaultLanguage,
  }) {
    final persistedLanguage = AppSession.currentLanguage;
    if (persistedLanguage != null &&
        persistedLanguage.languageCode == currentLanguageCode) {
      context.read<LanguageCubit>().loadLanguage(persistedLanguage);
    } else {
      context.read<LanguageCubit>().loadLanguage(defaultLanguage);
    }
  }

  void _tryNavigate() {
    if (!mounted || _navigated || !_bootReady || !_videoFinished) return;
    final settings = _loadedSettings;
    if (settings == null) return;

    _navigated = true;

    if (settings.maintenanceMode) {
      Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
    } else if (HiveUtils.isUserFirstTime()) {
      Navigator.of(context).pushReplacementNamed(Routes.onboarding);
    } else if (HiveUtils.isUserAuthenticated()) {
      Navigator.of(context).pushReplacementNamed(
        Routes.main,
        arguments: {'from': 'main'},
      );
    } else if (HiveUtils.isUserSkip()) {
      Navigator.of(context).pushReplacementNamed(
        Routes.main,
        arguments: {'from': 'main'},
      );
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.login);
    }
  }

  Widget _videoBody() {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _controller.value.isInitialized) {
          return FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              child: VideoPlayer(_controller),
            ),
          );
        }
        return Center(
          child: CircularProgressIndicator(
            color: context.color.secondaryColor,
          ),
        );
      },
    );
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
              _bootReady = false;
              _loadedSettings = null;
              _navigated = false;
              _videoCompleteFired = false;
              _videoFinished = false;
              _controller.removeListener(_onVideoTick);
              _controller.dispose();
              setState(() {});
              _initVideo();
              _startNavigationFlow();
            },
          ),
        ),
      );
    }

    return MultiBlocListener(
      listeners: [
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
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: context.color.territoryColor,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: context.color.territoryColor,
          body: _videoBody(),
        ),
      ),
    );
  }
}
