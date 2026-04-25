import '../entities/rate.dart';

class ConvertCurrencyUseCase {
  /// Результат конвертации
  ConversionResult call({
    required double amount,
    required Rate from,
    required Rate to,
  }) {
    final result = Rate.convert(amount: amount, from: from, to: to);
    final rate = Rate.exchangeRate(from, to);
    final inverseRate = Rate.exchangeRate(to, from);

    return ConversionResult(
      amount: amount,
      result: result,
      from: from,
      to: to,
      rate: rate,
      inverseRate: inverseRate,
    );
  }
}

class ConversionResult {
  final double amount;
  final double result;
  final Rate from;
  final Rate to;
  final double rate;        // 1 FROM = X TO
  final double inverseRate; // 1 TO   = X FROM

  const ConversionResult({
    required this.amount,
    required this.result,
    required this.from,
    required this.to,
    required this.rate,
    required this.inverseRate,
  });
}
