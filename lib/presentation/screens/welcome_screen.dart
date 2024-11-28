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
            Text(AppLocalizations.of(context)!.bienvenido),
            Text(AppLocalizations.of(context)!.bienvenidoMsg , textAlign: TextAlign.center,),
            Text(AppLocalizations.of(context)!.bienvenidoMsg2, textAlign: TextAlign.center,),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  context.push('/create-cv');
                },
                child: const Text('Get Started'))
          ],
        ),
      ),
    );
  }
}
