class Rate {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final double rateToUsd; // сколько единиц этой валюты за 1 USD

  const Rate({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.rateToUsd,
  });

  /// Конвертация: amount единиц [from] → сколько будет в [to]
  static double convert({
    required double amount,
    required Rate from,
    required Rate to,
  }) {
    // amount / rateToUsd = сумма в USD, потом * rateToUsd цели
    return (amount / from.rateToUsd) * to.rateToUsd;
  }

  /// Обменный курс: 1 единица [from] = X единиц [to]
  static double exchangeRate(Rate from, Rate to) {
    return to.rateToUsd / from.rateToUsd;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Rate && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Rate($code, $rateToUsd)';
}
