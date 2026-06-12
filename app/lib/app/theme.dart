import "package:flutter/material.dart";

import "action_button_styles.dart";

final ThemeData fukkinTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D32),
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(kActionButtonMinWidth, kActionButtonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      textStyle: kActionButtonTextStyle,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(kActionButtonMinWidth, kActionButtonHeight),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      textStyle: kActionButtonTextStyle,
    ),
  ),
);
