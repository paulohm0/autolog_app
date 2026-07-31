import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModeKey = 'theme_mode';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeCubit({required SharedPreferences prefs})
    : _prefs = prefs,
      super(_readInitial(prefs));

  static ThemeMode _readInitial(SharedPreferences prefs) {
    final saved = prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> changeThemeMode(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_themeModeKey, mode.name);
  }
}
