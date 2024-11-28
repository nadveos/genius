import 'package:cvgenius/config/router/router.dart';
import 'package:cvgenius/config/theme/app_theme.dart';
import 'package:cvgenius/presentation/providers/isar_user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(themeProvider) ? ThemeMode.dark : ThemeMode.light;
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
    debugShowCheckedModeBanner: false,
      title: 'Cv Genius',
      theme: themeMode == ThemeMode.light
          ? AppTheme().getConfigLight()
          : AppTheme().getConfigDark(),
      routerConfig: approuter,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: locale,
      supportedLocales: const [
        Locale('es'), // Spanish
        Locale('en'), // English
      ],
    );
  }
}
