import '../entities/rate.dart';

abstract interface class CurrencyRepository {
  /// Получить актуальные курсы (сначала кеш, потом сеть)
  Future<List<Rate>> getRates();

  /// Принудительно обновить с сервера
  Future<List<Rate>> refreshRates();

  /// Получить историю курса за N дней (для графика)
  Future<List<double>> getRateHistory({
    required String fromCode,
    required String toCode,
    required int days,
  });

  /// Сохранить избранные пары
  Future<void> saveFavorites(List<String> pairs);

  /// Загрузить избранные пары
  Future<List<String>> loadFavorites();
}
