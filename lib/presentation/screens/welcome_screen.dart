import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 200,
            ),
            Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                      semanticsLabel: AppLocalizations.of(context)!.bienvenido,
                      AppLocalizations.of(context)!.bienvenido,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const Divider(),
                      Text(
                      semanticsLabel: AppLocalizations.of(context)!.bienvenidoMsg,
                        AppLocalizations.of(context)!.bienvenidoMsg,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      Text(
                      semanticsLabel: AppLocalizations.of(context)!.bienvenidoMsg2,
                        AppLocalizations.of(context)!.bienvenidoMsg2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  context.go('/create-cv');
                },
                child:  Text(
                semanticsLabel: AppLocalizations.of(context)!.empesemos,
                AppLocalizations.of(context)!.empesemos)),
          ],
        ),
      ),
    );
  }
}
