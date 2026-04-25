import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/currency/data/datasources/local_datasource.dart';
import '../../features/currency/data/datasources/remote_datasource.dart';
import '../../features/currency/data/repository_impl.dart';
import '../../features/currency/domain/repositories/currency_repository.dart';
import '../../features/currency/domain/usecases/convert_currency.dart';
import '../network/api_client.dart';

// ─── Инфраструктура ──────────────────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) => ApiClient.create());

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

// ─── Datasources ─────────────────────────────────────────────────────────────

final remoteDatasourceProvider = Provider<RemoteDatasource>((ref) {
  return RemoteDatasourceImpl(ref.read(dioProvider));
});

final localDatasourceProvider = Provider<LocalDatasource>((ref) {
  return LocalDatasourceImpl();
});

// ─── Repository ───────────────────────────────────────────────────────────────

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepositoryImpl(
    remote: ref.read(remoteDatasourceProvider),
    local: ref.read(localDatasourceProvider),
    connectivity: ref.read(connectivityProvider),
  );
});

// ─── Use cases ────────────────────────────────────────────────────────────────

final convertCurrencyProvider = Provider<ConvertCurrencyUseCase>((ref) {
  return ConvertCurrencyUseCase();
});
