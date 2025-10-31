import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:blur/blur.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/globals.dart';
import 'package:qubic_wallet/globals/localization_manager.dart';
import 'package:qubic_wallet/helpers/app_logger.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/platform_specific_initialization.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/routes.dart';
import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/dapp_store.dart';
import 'package:qubic_wallet/stores/root_jailbreak_flag_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/button_styles.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await setupDI(); //Dependency injection
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
    getIt.get<SettingsStore>().setVersion(packageInfo.version);
    getIt.get<SettingsStore>().setBuildNumber(packageInfo.buildNumber);

    getIt.get<ApplicationStore>().checkWalletIsInitialized();
  } catch (e) {
    appLogger.e(e.toString());
  }

  runApp(const WalletApp());
}

class WalletApp extends StatefulWidget {
  const WalletApp({super.key});

  @override
  State<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> with WidgetsBindingObserver {
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  final AppLinks appLinks = getIt<AppLinks>();

  bool _isInBackground = false;
  StreamSubscription<Uri>? _linkSubscription;

  Future<void> initDeepLinks() async {
    // Handle links
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      getIt<ApplicationStore>().setCurrentInboundUrl(uri);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      setState(() {
        _isInBackground = true;
      });
    } else if (state == AppLifecycleState.resumed) {
      qubicCmd.reinitialize();
      getIt<RootJailbreakFlagStore>().showSecurityWarningIfNeeded();
      setState(() {
        _isInBackground = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initDeepLinks();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<RootJailbreakFlagStore>().showSecurityWarningIfNeeded();
      getIt<DappStore>().loadDapps();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      ).copyWith(
          filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyles.primaryButtonBig,
      )),
      builder: (context, child) {
        final localizations = AppLocalizations.of(context);
        if (localizations != null) {
          LocalizationManager.instance.setLocalizations(localizations);
          l10nWrapper.setL10n(localizations);
        }
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
                    color: Colors.black.withValues(alpha: 0.2),
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
