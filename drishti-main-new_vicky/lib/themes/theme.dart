import 'package:srisridrishti/themes/text_styles/heading_style.dart';
import 'package:srisridrishti/themes/text_styles/subheading_style.dart';
import 'package:srisridrishti/themes/text_styles/title_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor500,
    appBarTheme: const AppBarTheme(
      color: AppColors.primaryColor100,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: HeadingStyles.heading1(),
      displayMedium: TitleStyles.title1(),
      titleMedium: SubheadingStyles.subheading1(),
    ),
  );
}

class AppColors {
  static const Color primaryColor = Color(0xFF7D5EFF);
  static const Color primaryBackgroundColor = Color(0xfffeceefd);
  static const Color primaryColor700 = Color(0xFF094FB1);

  static const Color primaryColor500 = Color(0xFF3f4fdd);
  static const Color primaryColor300 = Color(0xFF5C9FFB);
  static const Color primaryColor100 = Color(0xFFB4D2FD);
  static const Color primaryColor50 = Color(0xFFE7F1FE);
  static const Color secondaryColor = Color(0xFF0000FF);
  static const Color accentSuccessColor500 = Color(0xFF53B483);
  static const Color accentSuccessColor100 = Color(0xFFCFEDD0);

  static const Color accentDestructiveColor500 = Color(0xFFDC4C44);
  static const Color accentDestructiveColor100 = Color(0xFFF3C7C5);

  static const Color accentAlertColor500 = Color(0xFFFFCE00);
  static const Color accentAlertColor100 = Color(0xFFFFF0B0);
  static const Color accentInfoColor500 = Color(0xFF0C6FF9);
  static const Color accentInfoColor100 = Color(0xFFB4D2FD);

  static const Color priceColor = Color(0xFFD4AF37);

  static Color white_09 = const Color(0x00ffffff).withOpacity(0.9);
  static Color white = const Color(0xffffffff);
  static Color black = const Color(0xff000000);
  static Color dark_purple_B226B2 = const Color(0xFFB226B2);
  static Color pink_FF6DA7 = const Color(0xFFFF6DA7);
  static const Color black_333333 = Color(0xFF333333);
  static const Color cardColor1_FFE3E3 = Color(0xFFFFE3E3);
  static const Color cardColor2_FEC9C9 = Color(0xFFFEC9C9);
  static const Color brown_511D1D = Color(0xFF511D1D);

  //bottom sheet colors
  static Color cardBgColor = const Color(0xffFEFEFE);
  static Color courseBgColor = const Color(0xFFE3D0EE);
  static Color btnBgColor = const Color(0xFF3BBD30);
  static Color grey = const Color(0xffCECECE);
  static const Color lightgrey_DEDEDE = Color(0xFFDEDEDE);
  static const Color grey_4F4F4F = Color(0xFF4F4F4F);
  static const Color grey_333333 = Color(0xFF333333);

  static const Color purple_7D5EFF = Color(0xFF7D5EFF);
  static const Color lightgrey_828282 = Color(0xFF828282);
  static const Color lightgrey_E0E0E0 = Color(0xFFE0E0E0);
  static const Color lightgrey_BDBDBD = Color(0xFFBDBDBD);
  static const Color lightgrey_818181 = Color(0xFF818181);
  static const Color lightpurple_72B1FF = Color(0xFF72B1FF);
  static const Color lightblue_EBF4FF = Color(0xFFEBF4FF);
}
