import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getConfigLight() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, brightness: Brightness.light),
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          modalBackgroundColor: Colors.white,
        ),
        
      );
  ThemeData getConfigDark() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue, brightness: Brightness.dark),
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.blue,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.black,
    modalBackgroundColor: Colors.black,
  ),
  );
}
