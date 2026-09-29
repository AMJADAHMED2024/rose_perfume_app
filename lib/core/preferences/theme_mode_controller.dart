import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.light) {
    unawaited(_restore());
  }

  static const _storageKey = 'rose_perfume.theme_mode';

  Future<void> _restore() async {
    final preferences = await SharedPreferences.getInstance();
    final isDark = preferences.getBool(_storageKey) ?? false;
    if (mounted) state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_storageKey, next == ThemeMode.dark);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) => ThemeModeController(),
);
