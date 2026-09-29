import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the customer's chosen UI language and lets every platform use the
/// same locale source. Feature copy can be migrated incrementally without
/// scattering locale state through pages.
class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('ar')) {
    unawaited(_restore());
  }

  static const _storageKey = 'rose_perfume.locale';

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_storageKey);
    if (mounted && (code == 'ar' || code == 'en')) state = Locale(code!);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, next.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleController, Locale>(
  (ref) => LocaleController(),
);
