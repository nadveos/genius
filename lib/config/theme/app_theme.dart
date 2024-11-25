import 'package:flutter/material.dart';

class AppTheme {


ThemeData getConfig()=>
  ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
  ),
  scaffoldBackgroundColor: Colors.grey[300],
    colorSchemeSeed: const Color(0xff1a1a1a),
  );
}