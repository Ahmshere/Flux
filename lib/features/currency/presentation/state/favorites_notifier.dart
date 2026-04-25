import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

class FavoritesNotifier extends StateNotifier<List<String>> {
  final ref;
  FavoritesNotifier(this.ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(currencyRepositoryProvider);
    final saved = await repo.loadFavorites();
    state = saved;
  }

  Future<void> toggle(String pair) async {
    if (state.contains(pair)) {
      state = state.where((p) => p != pair).toList();
    } else {
      state = [...state, pair];
    }
    final repo = ref.read(currencyRepositoryProvider);
    await repo.saveFavorites(state);
  }

  bool isFavorite(String pair) => state.contains(pair);
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier(ref);
});
