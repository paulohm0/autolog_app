import 'package:autolog_app/ui/cubit/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('initial state', () {
    test('starts with ThemeMode.system when there is no saved preference', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, ThemeMode.system);
    });

    test('starts with the theme mode saved in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();

      final cubit = ThemeCubit(prefs: prefs);

      expect(cubit.state, ThemeMode.dark);
    });
  });

  group('changeThemeMode', () {
    test('emits the new theme mode and persists it in SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = ThemeCubit(prefs: prefs);

      await cubit.changeThemeMode(ThemeMode.dark);

      expect(cubit.state, ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');
      await cubit.close();
    });
  });
}
