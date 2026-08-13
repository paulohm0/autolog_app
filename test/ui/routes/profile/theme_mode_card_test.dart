import 'package:autolog_app/core/di/injector.dart';
import 'package:autolog_app/core/theme/app_theme.dart';
import 'package:autolog_app/ui/cubit/theme/theme_cubit.dart';
import 'package:autolog_app/ui/routes/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Teste de Widget, verifica se o comportamento de widget é o esperado.

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<ThemeCubit>(ThemeCubit(prefs: prefs));
  });

  tearDown(() {
    getIt.reset();
  });

  Future<void> pumpCard(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(body: ThemeModeCard()),
      ),
    );
  }

  testWidgets(
    'switch is on when the mode is system and the system theme is dark',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpCard(tester);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    },
  );

  testWidgets(
    'switch is off when the mode is system and the system theme is light',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await pumpCard(tester);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    },
  );

  testWidgets(
    'switch is on when the mode is explicitly dark, regardless of the system theme',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await getIt<ThemeCubit>().changeThemeMode(ThemeMode.dark);

      await pumpCard(tester);

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    },
  );

  testWidgets('tapping the switch changes the theme mode to dark', (
    tester,
  ) async {
    await pumpCard(tester);

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(getIt<ThemeCubit>().state, ThemeMode.dark);
  });
}
