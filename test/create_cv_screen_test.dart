import 'package:cvgenius/presentation/screens/create_cv_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CreateCvScreen builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CreateCvScreen(),
        ),
      ),
    );

    // Verify if the initial step is displayed
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Edad'), findsOneWidget);
    expect(find.text('Email'), findsNothing);

    // Enter text in the name and age fields
    await tester.enterText(find.byType(TextFormField).at(0), 'Juan Pérez');
    await tester.enterText(find.byType(TextFormField).at(1), '30');

    // Tap on the 'Continuar' button
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    // Verify if the next step is displayed
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Telefono'), findsOneWidget);
  });
}