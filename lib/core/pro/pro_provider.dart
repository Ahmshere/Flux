import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _proKey = 'is_pro';

final proProvider = StateNotifierProvider<ProNotifier, bool>((ref) {
  return ProNotifier();
});

class ProNotifier extends StateNotifier<bool> {
  ProNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_proKey) ?? false;
  }

  Future<void> unlock() async {
    state = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, true);
  }

  Future<void> restore() async {
    // TODO: purchases_flutter integration
    // final info = await Purchases.restorePurchases();
    // if (info.entitlements.active.containsKey('pro')) unlock();
    await unlock();
  }

  Future<void> reset() async {
    state = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, false);
  }
}
