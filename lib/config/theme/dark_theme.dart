import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  scaffoldBackgroundColor: kBackgroundDark,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: kPrimaryColorDark,
    iconTheme: IconThemeData(color: kPrimaryColorWhite),
    titleTextStyle: TextStyle(
      color: kPrimaryColorWhite,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  splashColor: kPrimaryColor.withAlpha((0.10 * 255).toInt()),
  highlightColor: kPrimaryColor.withAlpha((0.10 * 255).toInt()),
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColorWhite,
    secondary: kPrimaryColorLight,
    tertiary: kPrimaryColorDark,
    onPrimary: kTextWhite,
    onSecondary: kGreyContainer,
    onTertiary: kButtonGrey,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: kPrimaryColorWhite,
  ),
);
