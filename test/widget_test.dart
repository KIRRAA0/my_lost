// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_lost/core/Utils/localization.dart';
import 'package:my_lost/core/Utils/theme_cubit.dart';
import 'package:my_lost/core/router/app_router.dart';
import 'package:my_lost/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Create required dependencies
    final localizationCubit = LocalizationCubit();
    final themeCubit = ThemeCubit();
    final appRouter = AppRouter();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      localizationCubit: localizationCubit,
      themeCubit: themeCubit,
      appRouter: appRouter,
    ));

    // Verify that the app starts and shows some expected content
    await tester.pumpAndSettle();
    
    // The app should load without errors - this is a basic smoke test
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
