import 'package:hive_flutter/hive_flutter.dart';
import '../models/rates_model.dart';

abstract interface class LocalDatasource {
  Future<RatesModel?> getCachedRates();
  Future<void> saveRates(RatesModel model);
  Future<List<String>> getFavorites();
  Future<void> saveFavorites(List<String> pairs);
}

class LocalDatasourceImpl implements LocalDatasource {
  static const _ratesBoxName = 'rates_cache';
  static const _ratesKey = 'latest';
  static const _favoritesBoxName = 'favorites';
  static const _favoritesKey = 'pairs';

  @override
  Future<RatesModel?> getCachedRates() async {
    final box = await Hive.openBox<RatesModel>(_ratesBoxName);
    return box.get(_ratesKey);
  }

  @override
  Future<void> saveRates(RatesModel model) async {
    final box = await Hive.openBox<RatesModel>(_ratesBoxName);
    await box.put(_ratesKey, model);
  }

  @override
  Future<List<String>> getFavorites() async {
    final box = await Hive.openBox<List>(_favoritesBoxName);
    final raw = box.get(_favoritesKey);
    return raw?.cast<String>() ?? [];
  }

  @override
  Future<void> saveFavorites(List<String> pairs) async {
    final box = await Hive.openBox<List>(_favoritesBoxName);
    await box.put(_favoritesKey, pairs);
  }
}
