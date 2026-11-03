import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'services/deep_link_service.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set initial system overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Theme Service
  await ThemeService().init();

  // Run the app immediately so the UI is NEVER blocked by network or permissions
  runApp(const DweepDiaryApp());

  // Non-blocking background initializations after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    DeepLinkService().init(rootNavigatorKey);
    NotificationService().initialize();
    MobileAds.instance.initialize().catchError((e) {
      debugPrint('AdMob notice: $e');
    });
  });
}

class DweepDiaryApp extends StatefulWidget {
  const DweepDiaryApp({super.key});

  @override
  State<DweepDiaryApp> createState() => _DweepDiaryAppState();
}

class _DweepDiaryAppState extends State<DweepDiaryApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    final uri = routeInformation.uri;
    DeepLinkService().handleUri(uri);
    return Future.value(true);
  }

  @override
  Future<bool> didPushRoute(String route) {
    DeepLinkService().handleRawRoute(route);
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: currentThemeMode,
          home: const SplashScreen(),

          // Light Theme with Anek Malayalam Font
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.anekMalayalamTextTheme(
              ThemeData.light().textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              surface: AppColors.surface,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.surface,
              surfaceTintColor: Colors.transparent,
              elevation: 0.5,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppColors.textPrimary),
              titleTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardTheme(
              color: AppColors.surface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Dark Theme with Anek Malayalam Font
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.darkBackground,
            textTheme: GoogleFonts.anekMalayalamTextTheme(
              ThemeData.dark().textTheme,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              surface: AppColors.darkSurface,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.darkSurface,
              surfaceTintColor: Colors.transparent,
              elevation: 0.5,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
              titleTextStyle: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            cardTheme: CardTheme(
              color: AppColors.darkSurface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
