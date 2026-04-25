class NaturalInputParser {
  static const _aliases = <String, String>{
    'dollar': 'USD',
    'dollars': 'USD',
    'usd': 'USD',
    'euro': 'EUR',
    'euros': 'EUR',
    'eur': 'EUR',
    'shekel': 'ILS',
    'shekels': 'ILS',
    'ils': 'ILS',
    'pound': 'GBP',
    'pounds': 'GBP',
    'gbp': 'GBP',
    'yen': 'JPY',
    'jpy': 'JPY',
    'franc': 'CHF',
    'chf': 'CHF',
    'yuan': 'CNY',
    'cny': 'CNY',
    'dirham': 'AED',
    'aed': 'AED',
    'ruble': 'RUB',
    'rubles': 'RUB',
    'rub': 'RUB',
    'bitcoin': 'BTC',
    'btc': 'BTC',
    'ethereum': 'ETH',
    'ether': 'ETH',
    'eth': 'ETH',
    '\u0434\u043e\u043b\u043b\u0430\u0440': 'USD',
    '\u0434\u043e\u043b\u043b\u0430\u0440\u044b': 'USD',
    '\u0431\u0430\u043a\u0441': 'USD',
    '\u0431\u0430\u043a\u0441\u044b': 'USD',
    '\u0435\u0432\u0440\u043e': 'EUR',
    '\u0448\u0435\u043a\u0435\u043b\u044c': 'ILS',
    '\u0448\u0435\u043a\u0435\u043b\u0438': 'ILS',
    '\u0444\u0443\u043d\u0442': 'GBP',
    '\u0444\u0443\u043d\u0442\u044b': 'GBP',
    '\u0438\u0435\u043d\u0430': 'JPY',
    '\u0444\u0440\u0430\u043d\u043a': 'CHF',
    '\u044e\u0430\u043d\u044c': 'CNY',
    '\u0434\u0438\u0440\u0445\u0430\u043c': 'AED',
    '\u0440\u0443\u0431\u043b\u044c': 'RUB',
    '\u0440\u0443\u0431\u043b\u0438': 'RUB',
    '\u0440\u0443\u0431': 'RUB',
    '\u0431\u0438\u0442\u043a\u043e\u0438\u043d': 'BTC',
    '\u044d\u0444\u0438\u0440': 'ETH',
  };

  // Разделитель: пробел + (to | in | во | в) + пробел
  static final _sep = RegExp(
    r'\s+(?:to|in|\u0432\u043e|\u0432)\s+',
    caseSensitive: false,
  );

  static ParseResult? parse(String input) {
    final str = input.trim();
    if (str.isEmpty) return null;

    final sepMatch = _sep.firstMatch(str);
    if (sepMatch == null) return null;

    final left = str.substring(0, sepMatch.start).trim();
    final right = str.substring(sepMatch.end).trim();
    if (left.isEmpty || right.isEmpty) return null;

    final leftTokens = left.split(RegExp(r'\s+'));
    double? amount;
    String? fromWord;

    // "100 usd"
    final n1 = double.tryParse(leftTokens.first.replaceAll(',', '.'));
    if (n1 != null && leftTokens.length >= 2) {
      amount = n1;
      fromWord = leftTokens[1];
    } else if (leftTokens.length >= 2) {
      // "usd 100"
      final n2 = double.tryParse(leftTokens.last.replaceAll(',', '.'));
      if (n2 != null) {
        amount = n2;
        fromWord = leftTokens.first;
      }
    }

    if (amount == null || fromWord == null || amount <= 0) return null;

    final toWord = right.split(RegExp(r'\s+')).first;
    final fromCode = _resolve(fromWord);
    final toCode = _resolve(toWord);

    if (fromCode == null || toCode == null || fromCode == toCode) return null;

    return ParseResult(amount: amount, fromCode: fromCode, toCode: toCode);
  }

  static String? _resolve(String word) {
    final lower = word.toLowerCase();
    if (_aliases.containsKey(lower)) return _aliases[lower];
    final upper = word.toUpperCase();
    if (_aliases.values.contains(upper)) return upper;
    return null;
  }
}

class ParseResult {
  final double amount;
  final String fromCode;
  final String toCode;

  const ParseResult({
    required this.amount,
    required this.fromCode,
    required this.toCode,
  });

  @override
  String toString() => 'ParseResult($amount $fromCode -> $toCode)';
}