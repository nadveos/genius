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
            AnimatedContainer(
                duration: const Duration(seconds: 5),
                alignment: Alignment.center,
                curve: Curves.easeInCirc,
                child: Image.asset(
                  'assets/logo.png',
                  width: 200,
                )),
            Card(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppLocalizations.of(context)!.bienvenido,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const Divider(),
                      Text(
                        AppLocalizations.of(context)!.bienvenidoMsg,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
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
                child:  Text(AppLocalizations.of(context)!.empesemos)),
          ],
        ),
      ),
    );
  }
}
