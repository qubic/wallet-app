import 'package:dargon2_flutter/dargon2_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qubic_wallet/di.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/globals.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/platform_specific_initialization.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/routes.dart';
import 'package:qubic_wallet/services/wallet_connect_service.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/qubic_hub_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:blur/blur.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> main() async {
  DArgon2Flutter.init(); //Initialize DArgon 2
  WidgetsFlutterBinding.ensureInitialized();
  setupDI(); //Dependency injection
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
  ));

  await PlatformSpecificInitilization().run();

  getIt.get<SettingsStore>().loadSettings();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  getIt.get<QubicHubStore>().setVersion(packageInfo.version);
  getIt.get<QubicHubStore>().setBuildNumber(packageInfo.buildNumber);

  getIt.get<ApplicationStore>().checkWalletIsInitialized();

  getIt.get<QubicCmd>().initialize();

  runApp(const WalletApp());
}

class WalletApp extends StatefulWidget {
  const WalletApp({super.key});

  @override
  State<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> with WidgetsBindingObserver {
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  bool _isInBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      setState(() {
        _isInBackground = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      qubicCmd.reinitialize();
      setState(() {
        _isInBackground = false;
      });
    }
  }

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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      LocalizationManager.instance.setLocalizations(localizations);
    }

    return MaterialApp.router(
      title: 'Qubic Wallet',
      routerConfig: appRouter,

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,

      /// Theme config for FlexColorScheme version 7.3.x. Make sure you use
      // same or higher package version, but still same major version. If you
      // use a lower package version, some properties may not be supported.
      // In that case remove them after copying this theme to your app.
      theme: FlexThemeData.dark(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          primary: LightThemeColors.primary,
          onPrimary: LightThemeColors.surface,
          secondary: LightThemeColors.primary,
          onSecondary: LightThemeColors.surface,
          error: LightThemeColors.error,
          onError: LightThemeColors.extraStrongBackground,
          background: LightThemeColors.background,
          onBackground: LightThemeColors.primary,
          surface: LightThemeColors.surface,
          onSurface: LightThemeColors.primary,
          seedColor: LightThemeColors.panelBackground,
          surfaceTint: LightThemeColors.background,
        ),

        useMaterial3: true,
        // To use the Playground font, add GoogleFonts package and uncomment
        fontFamily: ThemeFonts.primary,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 2,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            if (_isInBackground && UniversalPlatform.isMobile)
              Positioned.fill(
                child: Blur(
                  blur: 21.0,
                  colorOpacity: 0.5,
                  blurColor: Colors.black,
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
          ],
        );
      },
      // darkTheme: FlexThemeData.dark(
      //   colorScheme: ColorScheme.fromSeed(
      //     brightness: Brightness.light,
      //     primary: LightThemeColors.primary,
      //     onPrimary: LightThemeColors.surface,
      //     secondary: LightThemeColors.primary,
      //     onSecondary: LightThemeColors.surface,
      //     error: LightThemeColors.error,
      //     onError: LightThemeColors.extraStrongBackground,
      //     background: LightThemeColors.panelBackground,
      //     onBackground: LightThemeColors.primary,
      //     surface: LightThemeColors.surface,
      //     onSurface: LightThemeColors.primary,
      //     seedColor: LightThemeColors.panelBackground,
      //     surfaceTint: LightThemeColors.background,
      //   ),

      //   useMaterial3: true,
      //   // To use the Playground font, add GoogleFonts package and uncomment
      //   fontFamily: GoogleFonts.poppins().fontFamily,

      //   surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      //   blendLevel: 2,
      //   visualDensity: FlexColorScheme.comfortablePlatformDensity,

      //   // To use the Playground font, add GoogleFonts package and uncomment
      // ),
      // If you do not have a themeMode switch, uncomment this line
      // to let the device system mode control the theme mode:
      // themeMode: ThemeMode.system,
    );
  }
}
