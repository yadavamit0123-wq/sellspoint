import 'package:eClassify/app/cubit_observer.dart';
import 'package:eClassify/firebase_options.dart';
import 'package:eClassify/main.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/utils/api.dart';
import 'package:eClassify/utils/app_session.dart';
import 'package:eClassify/utils/background_upload_utility.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/hive_keys.dart';
import 'package:eClassify/utils/map_style.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as libphonenumber;
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Initializes the application with all necessary configurations
Future<void> initApp() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    //debugRepaintRainbowEnabled = true;

    // Configure Google Maps for Android
    _configureGoogleMaps();

    // Set up error handling for release mode
    if (kReleaseMode) {
      _setupErrorHandling();
    }

    _setupFilePath();

    // Initialize Mobile Ads
    MobileAds.instance.initialize();

    // Initialize regions for phone number
    libphonenumber.init();

    // Load map styles from assets
    MapStyle.init();

    // Initialize background downloader notifications configuration
    BackgroundUploadUtility.initialize();

    // Configure system UI and launch app
    _configureSystemUI();

    Bloc.observer = AppCubitObserver();

    await Future.wait([
      // Init Api Client
      Api.init(),

      // Initialize Firebase
      _initializeFirebase(),

      // Initialize Hive and open boxes
      _initializeHive(),
    ]);

    // Create app session from stored values
    // Note: Must be called "after" hive is initialized
    AppSession.create();

    runApp(const EntryPoint());
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'App failed to start.\n\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Configures Google Maps for Android platform
void _configureGoogleMaps() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = false;
    mapsImplementation.warmup();
  }
}

/// Sets up error handling for release mode
void _setupErrorHandling() {
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    return SomethingWentWrong();
  };
}

/// Initializes Firebase with appropriate options
Future<void> _initializeFirebase() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  try {
    await FirebaseAppCheck.instance.activate(
      providerApple:
          kDebugMode ? AppleDebugProvider() : AppleAppAttestProvider(),
      providerAndroid: kDebugMode
          ? AndroidDebugProvider()
          : AndroidPlayIntegrityProvider(),
    );
  } catch (e, stackTrace) {
    debugPrint('Firebase App Check activation failed: $e\n$stackTrace');
  }
}

/// Initializes Hive and opens all required boxes
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // List of Hive box names that need to be initialized
  final List<String> hiveBoxes = [
    HiveKeys.userDetailsBox,
    HiveKeys.authBox,
    HiveKeys.languageBox,
    HiveKeys.themeBox,
    HiveKeys.jwtToken,
    HiveKeys.historyBox,
  ];

  final boxesFuture = [for (final box in hiveBoxes) Hive.openBox(box)];

  await Future.wait(boxesFuture);
}

/// Configures system UI and launches the app
Future<void> _configureSystemUI() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final brightness = AppSession.isDarkMode ? Brightness.light : Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarIconBrightness: brightness,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );
}

/// Setup the file path for saving internal files
Future<void> _setupFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  Constant.savePath = directory.path;
}
