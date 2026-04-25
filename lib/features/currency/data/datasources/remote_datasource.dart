import 'package:dio/dio.dart';
import '../models/rates_model.dart';

abstract interface class RemoteDatasource {
  Future<RatesModel> fetchRates();
  Future<List<double>> fetchHistory({
    required String base,
    required String target,
    required int days,
  });
}

class RemoteDatasourceImpl implements RemoteDatasource {
  final Dio _dio;

  // frankfurter.app — бесплатно, без ключа, не блокирует
  static const _base = 'https://api.frankfurter.app';

  RemoteDatasourceImpl(this._dio);

  @override
  Future<RatesModel> fetchRates() async {
    // frankfurter возвращает: { "base": "USD", "rates": { "EUR": 0.92, ... } }
    final resp = await _dio.get(
      '$_base/latest',
      queryParameters: {
        'from': 'USD',
        'to': 'EUR,ILS,GBP,JPY,CHF,CAD,AUD,CNY,AED,RUB',
        // BTC/ETH frankfurter не поддерживает — добавим вручную ниже
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }

    final data = resp.data as Map<String, dynamic>;
    final rates = Map<String, dynamic>.from(data['rates'] as Map);

    // Добавляем USD как базу
    rates['USD'] = 1.0;

    // BTC и ETH — статичные приблизительные значения как fallback
    // В реальном приложении можно добавить отдельный запрос к coingecko
    rates['BTC'] = 0.0000152;
    rates['ETH'] = 0.000276;

    return RatesModel.fromJson({'rates': rates});
  }

  @override
  Future<List<double>> fetchHistory({
    required String base,
    required String target,
    required int days,
  }) async {
    // BTC/ETH frankfurter не поддерживает — возвращаем mock
    if (base == 'BTC' || base == 'ETH' ||
        target == 'BTC' || target == 'ETH') {
      return _mockHistory(days, seed: base.hashCode + target.hashCode);
    }

    final end   = DateTime.now();
    final start = end.subtract(Duration(days: days));

    final resp = await _dio.get(
      '$_base/${_fmt(start)}..${_fmt(end)}',
      queryParameters: {
        'from': base,
        'to': target,
      },
    );

    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');

    final data   = resp.data as Map<String, dynamic>;
    final ratesMap = data['rates'] as Map<String, dynamic>;

    // Сортируем по дате и возвращаем значения
    final sorted = ratesMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sorted.map((e) {
      final day = e.value as Map<String, dynamic>;
      return (day[target] as num).toDouble();
    }).toList();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<double> _mockHistory(int days, {int seed = 0}) {
    double v = 1.0 + (seed % 10) * 0.1;
    return List.generate(days, (i) {
      v += v * 0.008 * (i % 3 == 0 ? 1 : -0.6);
      return v;
    });
  }
}