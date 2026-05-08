import 'package:hive/hive.dart';
import '../../domain/entities/rate.dart';

part 'rates_model.g.dart';

@HiveType(typeId: 0)
class RatesModel extends HiveObject {
  @HiveField(0)
  final Map<String, double> rates;

  @HiveField(1)
  final int timestamp;

  RatesModel({required this.rates, required this.timestamp});

  bool get isFresh {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - timestamp) < const Duration(hours: 12).inMilliseconds;
  }

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
      ..sort((a, b) {
        final ai = _order.indexOf(a.code);
        final bi = _order.indexOf(b.code);
        return (ai < 0 ? 999 : ai).compareTo(bi < 0 ? 999 : bi);
      });
  }

  factory RatesModel.fromJson(Map<String, dynamic> json) {
    final ratesJson = json['rates'] as Map<String, dynamic>;
    return RatesModel(
      rates: ratesJson.map((k, v) => MapEntry(k, (v as num).toDouble())),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

/// Порядок отображения — сначала бесплатные, потом PRO
const _order = [
  // ── Бесплатные (5) ──────────────────────────────────────────────────────
  'USD', 'EUR', 'GBP', 'ILS', 'INR',
  // ── PRO ─────────────────────────────────────────────────────────────────
  'JPY', 'CHF', 'CAD', 'AUD', 'CNY',
  'HKD', 'SGD', 'NOK', 'SEK', 'DKK',
  'PLN', 'CZK', 'HUF', 'RON', 'TRY',
  'ZAR', 'BRL', 'MXN', 'IDR', 'KRW',
  'MYR', 'PHP', 'THB', 'NZD', 'AED',
  // ── Крипто (PRO) ────────────────────────────────────────────────────────
  'BTC', 'ETH',
];

class _CurrencyMeta {
  final String name;
  final String symbol;
  final String flag;
  const _CurrencyMeta(this.name, this.symbol, this.flag);
}

const _meta = {
  // ── Бесплатные ────────────────────────────────────────────────────────────
  'USD': _CurrencyMeta('US Dollar',          r'$',   '🇺🇸'),
  'EUR': _CurrencyMeta('Euro',               '€',    '🇪🇺'),
  'GBP': _CurrencyMeta('British Pound',      '£',    '🇬🇧'),
  'ILS': _CurrencyMeta('Israeli Shekel',     '₪',    '🇮🇱'),
  'INR': _CurrencyMeta('Indian Rupee',       '₹',    '🇮🇳'),
  // ── PRO — Азия/Океания ────────────────────────────────────────────────────
  'JPY': _CurrencyMeta('Japanese Yen',       '¥',    '🇯🇵'),
  'CNY': _CurrencyMeta('Chinese Yuan',       '¥',    '🇨🇳'),
  'HKD': _CurrencyMeta('Hong Kong Dollar',   'HK\$', '🇭🇰'),
  'SGD': _CurrencyMeta('Singapore Dollar',   'S\$',  '🇸🇬'),
  'KRW': _CurrencyMeta('South Korean Won',   '₩',    '🇰🇷'),
  'IDR': _CurrencyMeta('Indonesian Rupiah',  'Rp',   '🇮🇩'),
  'MYR': _CurrencyMeta('Malaysian Ringgit',  'RM',   '🇲🇾'),
  'PHP': _CurrencyMeta('Philippine Peso',    '₱',    '🇵🇭'),
  'THB': _CurrencyMeta('Thai Baht',          '฿',    '🇹🇭'),
  'NZD': _CurrencyMeta('New Zealand Dollar', 'NZ\$', '🇳🇿'),
  'AUD': _CurrencyMeta('Australian Dollar',  'A\$',  '🇦🇺'),
  // ── PRO — Европа ──────────────────────────────────────────────────────────
  'CHF': _CurrencyMeta('Swiss Franc',        'Fr',   '🇨🇭'),
  'NOK': _CurrencyMeta('Norwegian Krone',    'kr',   '🇳🇴'),
  'SEK': _CurrencyMeta('Swedish Krona',      'kr',   '🇸🇪'),
  'DKK': _CurrencyMeta('Danish Krone',       'kr',   '🇩🇰'),
  'PLN': _CurrencyMeta('Polish Zloty',       'zł',   '🇵🇱'),
  'CZK': _CurrencyMeta('Czech Koruna',       'Kč',   '🇨🇿'),
  'HUF': _CurrencyMeta('Hungarian Forint',   'Ft',   '🇭🇺'),
  'RON': _CurrencyMeta('Romanian Leu',       'lei',  '🇷🇴'),
  'TRY': _CurrencyMeta('Turkish Lira',       '₺',    '🇹🇷'),
  // ── PRO — Америка ─────────────────────────────────────────────────────────
  'CAD': _CurrencyMeta('Canadian Dollar',    'C\$',  '🇨🇦'),
  'BRL': _CurrencyMeta('Brazilian Real',     'R\$',  '🇧🇷'),
  'MXN': _CurrencyMeta('Mexican Peso',       'MX\$', '🇲🇽'),
  // ── PRO — Африка/Ближний Восток ───────────────────────────────────────────
  'ZAR': _CurrencyMeta('South African Rand', 'R',    '🇿🇦'),
  'AED': _CurrencyMeta('UAE Dirham',         'د.إ',  '🇦🇪'),
  // ── PRO — Крипто ─────────────────────────────────────────────────────────
  'BTC': _CurrencyMeta('Bitcoin',            '₿',    '🪙'),
  'ETH': _CurrencyMeta('Ethereum',           'Ξ',    '🔷'),
};