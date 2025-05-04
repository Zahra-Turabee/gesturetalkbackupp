// ignore_for_file: use_full_hex_values_for_flutter_colors

import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class AppThemeColors {
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color getTertiary(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary;
  }

  static Color getquaternary(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }

  static Color getfifth(BuildContext context) {
    return Theme.of(context).colorScheme.onTertiary;
  }

  static Color getsplashcolor(BuildContext context) {
    return Theme.of(context).splashColor;
  }

  static Color getblack(BuildContext context) {
    return Theme.of(context).shadowColor;
  }
}

// ✅ Main Colors
const kPrimaryColor = Color(0xFF8E26A0); // Purple
const kPrimaryColorLight = Color(0xFFB0B0B0); // Grey
const kPrimaryColorWhite = Color(0xFFFFFFFF); // White
const kPrimaryColorDark = Color(0xFF6A1B83); // Darker Purple
const kGreyColor = Color(0xFFB0B0B0);

// ✅ Text Colors
const kTextPrimaryColor = Color(0xFF000000); // Black
const kTextWhite = Color(0xFFFFFFFF); // White
const kTextGrey = Color(0xFF767676); // Neutral Grey

// ✅ Backgrounds
const kBackgroundColor = Color(0xFFF6F6F6); // Light Grey Background
const kBackgroundDark = Color(0xFF1E1E1E); // Dark Theme Background
const kSplashBackgroundColor = Color(0xFF8E26A0); // Splash Screen Background

// ✅ Buttons, Containers
const kButtonPurple = Color(0xFF8E26A0);
const kButtonGrey = Color(0xFFB0B0B0);
const kGreyContainer = Color(0xFFE0E0E0);
const kWhiteContainer = Color(0xFFFFFFFF);

// ✅ Divider & Borders
const kDividerColor = Color(0xFFE7E7E7);
const kBorderColor = Color(0xFFE6E6E6);

// ✅ Gradients
const kGradientPurpleGrey = LinearGradient(
  colors: [Color(0xFF8E26A0), Color(0xFFB0B0B0)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kGradientPurpleWhite = LinearGradient(
  colors: [Color(0xFF8E26A0), Color(0xFFFFFFFF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ✅ Reusable Gradient & Border Function
LinearGradient kAppGradient() => const LinearGradient(
  colors: [Color(0xFF8E26A0), Color(0xFFB0B0B0)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

GradientBoxBorder kGradientBorder() =>
    GradientBoxBorder(gradient: kAppGradient(), width: 1);
