import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mobile/data/entry_repository.dart';
import 'package:mobile/data/preferences_repository.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized in main()');
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  if (kIsWeb) {
    return EntryRepository(null);
  }
  return EntryRepository(ref.watch(isarProvider));
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(preferencesRepositoryProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._repo) : super(ThemeMode.light) {
    _load();
  }

  final PreferencesRepository _repo;

  Future<void> _load() async {
    try {
      final value = await _repo.getString('theme_mode');
      if (value == 'dark') {
        state = ThemeMode.dark;
      } else if (value == 'light') {
        state = ThemeMode.light;
      } else if (value == 'system') {
        state = ThemeMode.system;
      }
    } catch (_) {}
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await _repo.save('theme_mode', value);
  }
}

final preferencesRepositoryProvider = Provider((ref) => PreferencesRepository());

class AsyncStringNotifier extends StateNotifier<AsyncValue<String?>> {
  final PreferencesRepository repo;
  final String key;

  AsyncStringNotifier(this.repo, this.key) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final val = await repo.getString(key);
      state = AsyncValue.data(val);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> set(String? value) async {
    state = AsyncValue.data(value);
    await repo.save(key, value);
  }
}

final dailyGoalProvider = StateNotifierProvider<AsyncStringNotifier, AsyncValue<String?>>((ref) {
  return AsyncStringNotifier(ref.watch(preferencesRepositoryProvider), 'daily_goal');
});

final todaysFocusProvider = StateNotifierProvider<AsyncStringNotifier, AsyncValue<String?>>((ref) {
  return AsyncStringNotifier(ref.watch(preferencesRepositoryProvider), 'todays_focus');
});

