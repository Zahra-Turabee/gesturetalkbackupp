import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: false,
  scaffoldBackgroundColor: kPrimaryColorWhite,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: kPrimaryColor,
    iconTheme: IconThemeData(color: kPrimaryColorWhite),
    titleTextStyle: TextStyle(
      color: kPrimaryColorWhite,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  splashColor: kPrimaryColor.withAlpha((0.10 * 255).toInt()),
  highlightColor: kPrimaryColor.withAlpha((0.10 * 255).toInt()),
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kPrimaryColorLight,
    tertiary: kPrimaryColorWhite,
    onPrimary: kTextPrimaryColor,
    onSecondary: kGreyContainer,
    onTertiary: kButtonPurple,
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: kTextPrimaryColor,
  ),
);
