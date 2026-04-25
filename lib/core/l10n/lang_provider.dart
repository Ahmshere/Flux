import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

const _prefKey = 'app_lang';

final langProvider = StateNotifierProvider<LangNotifier, AppLang>((ref) {
  return LangNotifier();
});

final stringsProvider = Provider<S>((ref) {
  return S(ref.watch(langProvider));
});

class LangNotifier extends StateNotifier<AppLang> {
  LangNotifier() : super(AppLang.en) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      state = AppLang.values.firstWhere(
            (l) => l.name == saved,
        orElse: () => AppLang.en,
      );
    }
  }

  Future<void> setLang(AppLang lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, lang.name);
  }
}