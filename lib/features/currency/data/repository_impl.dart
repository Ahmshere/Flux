import 'package:connectivity_plus/connectivity_plus.dart';

import '../domain/entities/rate.dart';
import '../domain/repositories/currency_repository.dart';
import 'datasources/local_datasource.dart';
import 'datasources/remote_datasource.dart';
import 'models/rates_model.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final RemoteDatasource _remote;
  final LocalDatasource _local;
  final Connectivity _connectivity;

  CurrencyRepositoryImpl({
    required RemoteDatasource remote,
    required LocalDatasource local,
    required Connectivity connectivity,
  })  : _remote = remote,
        _local = local,
        _connectivity = connectivity;

  @override
  Future<List<Rate>> getRates() async {
    final cached = await _local.getCachedRates();
    if (cached != null && cached.isFresh) return cached.toRates();

    final isOnline = await _isOnline();
    if (isOnline) {
      try {
        return await refreshRates();
      } catch (_) {
        if (cached != null) return cached.toRates();
        rethrow;
      }
    }
    if (cached != null) return cached.toRates();
    throw const NoInternetException();
  }

  @override
  Future<List<Rate>> refreshRates() async {
    final model = await _remote.fetchRates();
    await _local.saveRates(model);
    return model.toRates();
  }

  @override
  Future<List<double>> getRateHistory({
    required String fromCode,
    required String toCode,
    required int days,
  }) async {
    try {
      return await _remote.fetchHistory(
        base: fromCode,
        target: toCode,
        days: days,
      );
    } catch (_) {
      return _mockHistory(days);
    }
  }

  @override
  Future<void> saveFavorites(List<String> pairs) =>
      _local.saveFavorites(pairs);

  @override
  Future<List<String>> loadFavorites() => _local.getFavorites();

  Future<bool> _isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  List<double> _mockHistory(int days) {
    double v = 1.0;
    return List.generate(days, (i) {
      v += v * 0.005 * (i % 3 == 0 ? 1 : -0.7);
      return v;
    });
  }
}

class NoInternetException implements Exception {
  const NoInternetException();
  @override
  String toString() => 'No internet and cache is empty';
}