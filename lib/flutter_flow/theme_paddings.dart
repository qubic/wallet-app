import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

abstract class ThemePaddings {
  /// 1px
  static const minimumPadding = 1.0;

  /// 4px
  static const miniPadding = 4.0;

  /// 8px
  static const smallPadding = 8.0;

  /// 12px
  static const mediumPadding = 12.0;

  /// 16px
  static const normalPadding = 16.0;

  /// 24px
  static const bigPadding = 24.0;

  /// 32px
  static const hugePadding = 32.0;

  // 44px
  static const bottomPaddingMobile = 44.0;
}

class LightThemeColors {
  static const shouldInvertIcon = true;
  static const primary = Color(0xFFFFFFFF);
  static const surface = Color(0xFF222229);
  static const background = Color(0xFF0C131B);
  static const navBg = Color(0xFF0C131B);
  static const navBorder = Color(0xFF202E3C);
  static const successIncoming = Color(0xFF179C6C);
  static const pending = Color(0xFFF3C05E);
  static const error = Color(0xFFE67070);
  static final border = Colors.white.withOpacity(0.03);
  // TODO Replace with error40 from the new palette
  static const dangerColor = Color(0xFFF97066);
  static const dangerBackgroundButton = Color(0xFF272127);

  static const textColorSecondary = Color(0xFF808B9B);

  static const menuBg = Color(0xFF101820);

  static const buttonPrimary = Color(0xFF1bdef5);

  static const color1 = Color(0xFF000000);
  static const color2 = Color(0xFF454545);
  static const color3 = Color(0xFF5E5E5E);
  static const color4 = Color(0xFF787878);
  static const color5 = Color(0xFF919191);
  static const color6 = Color(0xFF707A8A);
  static const color7 = Color(0xFFCCCCCC);
  static const color8 = Color(0xFFE6E6E6);
  static const color9 = Color(0xFFD1D1D1);

  static const disabledStateBg = color2;

  static const inputFieldBg = grey80;
  static const inputFieldHint = Color(0xFF4B5565);

  static const secondaryTypography = color6;
  static const buttonTap = color8;

  static const extraStrongBackground = menuBg;
  static const strongBackground = Color(0xFF060606);

  static const inputBorderColor = Color(0xFF202E3C);
  static const darkButtonBorderColor = Color(0xFF282F36);

  static const walletConnectURLColor = Color(0xFF4B5565);

//  static const gradient1 = Color(0xFF0F27FF);
  static const gradient1 = buttonPrimary;
  static const gradient2 = Color(0xFF045d68);
//  static const gradient2 = Color(0xFFBF0FFF);
  static const onGradient = Color(0xFFFFFFFF);
  static const pillColor = Color(0x40FFFFFF);

  static const titleColor = Color.fromARGB(255, 97, 240, 254);

  static const textTitle = Color(0xFFFFFFFF);
  static const textLabel = primary;
  static const textLightGrey = color6;
  static const textInputPlaceholder = Color.fromARGB(1, 116, 116, 116);
  static const borderInput = Color.fromARGB(1, 204, 204, 204);

  static const textError = error;

  static const buttonBackground = buttonPrimary;
  static const buttonBackgroundDisabled = Color(0x33DDDDDD);
  static const cardBackground = menuBg;
  static const navbarBackground = menuBg;
  static const panelBackground = Color.fromARGB(255, 23, 23, 23);

  static const menuActive = Color.fromARGB(255, 27, 222, 245);
  static const menuInactive = Color.fromARGB(255, 152, 157, 162);

  static const refreshIndicatorBackground = cardBackground;

  // *** New Palette *** //

  static const primary10 = Color(0xFFCCFCFF);
  static const primary20 = Color(0xFFB0F9FE);
  static const primary30 = Color(0xFF61F0FE);

  ///Main primary option. Used as for primary buttons, highlighted text, active icons
  static const primary40 = Color(0xFF1ADEF5);
  static const primary50 = Color(0xFF03C1DB);
  static const primary60 = Color(0xFF019AB8);
  static const primary90 = Color(0xFF112C35);
  static const grey50 = Color(0xFF808B9B);
  static const grey60 = Color(0xFF4B5565);
  static const grey70 = Color(0xFF202E3C);
  static const grey80 = Color(0xFF151E27);
  static const grey90 = Color(0xFF101820);
  static const grey100 = Color(0xFF0C131B);

  static const error40 = Color(0xFFF97066);
  static const error90 = Color(0xFF381D1E);

  static const success40 = Color(0xFF47CD89);
  static const success90 = Color(0xFF11322D);

  static const warning10 = Color(0xFFFABC3C);
  static const warning40 = Color(0xFFCDA747);
  static const warning90 = Color(0xFF322D11);
}

class xLightThemeColors {
  static const shouldInvertIcon = false;

  static const primary = Color(0xFF131313);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF1F3F4);
  static const successIncoming = Color(0xFF179C6C);
  static const pending = Color(0xFFEAB754);
  static const error = Color(0xFFFF007B);

  static const color1 = Color(0xFFF5F5F5);
  static const color2 = Color(0xFFE6E6E6);
  static const color3 = Color(0xFFCCCCCC);
  static const color4 = Color(0xFFABABAB);
  static const color5 = Color(0xFF919191);
  static const color6 = Color(0xFF747474);
  static const color7 = Color(0xFF5E5E5E);
  static const color8 = Color(0xFF454545);
  static const color9 = Color(0xFF2E2E2E);

  static const disabledStateBg = color2;

  static const inputFieldBg = color3;

  static const secondaryTypography = color6;
  static const buttonTap = color8;

  static const extraStrongBackground = surface;
  static const strongBackground = Color(0xFFF6F6F6);

  static const inputBorderColor = color3;

  static const gradient1 = Color(0xFF0F27FF);
  static const gradient2 = Color(0xFFBF0FFF);
  static const onGradient = Color(0xFFFFFFFF);
  static const pillColor = Color(0x40FFFFFF);

  static const textTitle = primary;
  static const textLabel = primary;
  static const textLightGrey = color6;
  static const textInputPlaceholder = Color.fromARGB(1, 116, 116, 116);
  static const borderInput = Color.fromARGB(1, 204, 204, 204);

  static const textError = error;

  static const buttonBackground = primary;
  static const buttonBackgroundDisabled = Color(0x33131313);
  static const cardBackground = extraStrongBackground;
  static const navbarBackground = extraStrongBackground;
  static const panelBackground = Color.fromARGB(255, 243, 243, 243);

  static const menuActive = primary;
  static const menuInactive = Color(0x99131313);
}

abstract class ThemeFontSizes {
  ///10
  static const tiny = 10.0;

  ///12
  static const small = 12.0;

  ///14
  static const normal = small + 2;

  ///16
  static const large = normal + 2;

  ///18
  static const extraLarge = large + 2;

  ///24
  static const huge = extraLarge + 8;

  ///36
  static const enormous = huge + 8;

  static const label = large;
  static const input = normal;
  static const sectionTitle = extraLarge;
  static const pageTitle = huge;
  static const pageSubtitle = large;

  static const loginTitle = 36;

  static const errorLabel = 12.5;

  static const letterSpacing = -0.02;
}

abstract class ThemeFonts {
  static final primary = GoogleFonts.spaceGrotesk().fontFamily;
  static final secondary = GoogleFonts.poppins().fontFamily;
}
