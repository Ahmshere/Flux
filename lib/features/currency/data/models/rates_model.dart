import 'package:hive/hive.dart';
import '../../domain/entities/rate.dart';

part 'rates_model.g.dart';

@HiveType(typeId: 0)
class RatesModel extends HiveObject {
  @HiveField(0)
  final Map<String, double> rates; // code → rateToUsd

  @HiveField(1)
  final int timestamp; // Unix ms — когда закешировали

  RatesModel({required this.rates, required this.timestamp});

  bool get isFresh {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < const Duration(hours: 12).inMilliseconds;
  }

  /// Преобразуем в список сущностей Rate, используя справочник метаданных
  List<Rate> toRates() {
    return rates.entries
        .where((e) => _meta.containsKey(e.key))
        .map((e) {
          final m = _meta[e.key]!;
          return Rate(
            code: e.key,
            name: m.name,
            symbol: m.symbol,
            flag: m.flag,
            rateToUsd: e.value,
          );
        })
        .toList()
      ..sort((a, b) => _order.indexOf(a.code).compareTo(_order.indexOf(b.code)));
  }

  factory RatesModel.fromJson(Map<String, dynamic> json) {
    final ratesJson = json['rates'] as Map<String, dynamic>;
    return RatesModel(
      rates: ratesJson.map((k, v) => MapEntry(k, (v as num).toDouble())),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// Порядок отображения валют
const _order = [
  'USD', 'EUR', 'ILS', 'GBP', 'JPY', 'CHF', 'CAD',
  'AUD', 'CNY', 'AED', 'RUB', 'BTC', 'ETH',
];

class _CurrencyMeta {
  final String name;
  final String symbol;
  final String flag;
  const _CurrencyMeta(this.name, this.symbol, this.flag);
}

const _meta = {
  'USD': _CurrencyMeta('US Dollar',         '\$',  '🇺🇸'),
  'EUR': _CurrencyMeta('Euro',               '€',  '🇪🇺'),
  'ILS': _CurrencyMeta('Israeli Shekel',     '₪',  '🇮🇱'),
  'GBP': _CurrencyMeta('British Pound',      '£',  '🇬🇧'),
  'JPY': _CurrencyMeta('Japanese Yen',       '¥',  '🇯🇵'),
  'CHF': _CurrencyMeta('Swiss Franc',        'Fr', '🇨🇭'),
  'CAD': _CurrencyMeta('Canadian Dollar',    'C\$','🇨🇦'),
  'AUD': _CurrencyMeta('Australian Dollar',  'A\$','🇦🇺'),
  'CNY': _CurrencyMeta('Chinese Yuan',       '¥',  '🇨🇳'),
  'AED': _CurrencyMeta('UAE Dirham',         'د.إ','🇦🇪'),
  'RUB': _CurrencyMeta('Russian Ruble',      '₽',  '🇷🇺'),
  'BTC': _CurrencyMeta('Bitcoin',            '₿',  '🪙'),
  'ETH': _CurrencyMeta('Ethereum',           'Ξ',  '🔷'),
};
