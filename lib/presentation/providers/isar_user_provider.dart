
import 'package:cvgenius/domain/entities/user.dart';
import 'package:cvgenius/infrastructure/infrastructure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isarUserProvider = Provider<UserCvDataSourceImpl>((ref) {
  return UserCvDataSourceImpl();
});
 final isarRealUserProvider = StreamProvider<List<UserCv>>((ref) {
  final isarUserService = ref.read(isarUserProvider);
  return isarUserService.getAllCvs();
});
class SelectedThemeNotifier extends StateNotifier<int> {
  SelectedThemeNotifier() : super(0);

  void selectTheme(int index) => state = index;
}

final selectedThemeProvider = StateNotifierProvider<SelectedThemeNotifier, int>(
  (ref) => SelectedThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  void toggleTheme() => state = !state;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);
final localeProvider = Provider<Locale>((ref) {
  return WidgetsBinding.instance.platformDispatcher.locale;
});