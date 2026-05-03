import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/rate.dart';
import '../../domain/repositories/currency_repository.dart';
import '../../domain/usecases/convert_currency.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/widget/home_widget_service.dart';
import 'history_notifier.dart';

class CurrencyState {
  final List<Rate> rates;
  final Rate? fromRate;
  final Rate? toRate;
  final double amount;
  final ConversionResult? result;
  final List<double> chartData;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const CurrencyState({
    this.rates        = const [],
    this.fromRate,
    this.toRate,
    this.amount       = 100,
    this.result,
    this.chartData    = const [],
    this.isLoading    = false,
    this.isRefreshing = false,
    this.error,
  });

  CurrencyState copyWith({
    List<Rate>? rates,
    Rate? fromRate,
    Rate? toRate,
    double? amount,
    ConversionResult? result,
    List<double>? chartData,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
  }) {
    return CurrencyState(
      rates:        rates        ?? this.rates,
      fromRate:     fromRate     ?? this.fromRate,
      toRate:       toRate       ?? this.toRate,
      amount:       amount       ?? this.amount,
      result:       result       ?? this.result,
      chartData:    chartData    ?? this.chartData,
      isLoading:    isLoading    ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error:        clearError ? null : (error ?? this.error),
    );
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final CurrencyRepository _repo;
  final ConvertCurrencyUseCase _converter;
  final Ref _ref;
  Timer? _bgTimer;
  Timer? _historyDebounce;
  Timer? _widgetDebounce;

  CurrencyNotifier(this._repo, this._converter, this._ref)
      : super(const CurrencyState()) {
    HomeWidgetService.init();
  }

  Future<void> init() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rates = await _repo.getRates();
      final from  = rates.firstWhere((r) => r.code == 'USD');
      final to    = rates.firstWhere((r) => r.code == 'EUR');
      state = state.copyWith(
          rates: rates, fromRate: from, toRate: to, isLoading: false);
      _recalc();
      _loadChart();
      _startBg();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setAmount(double v) {
    state = state.copyWith(amount: v);
    _recalc(save: true);
  }

  void setFromRate(Rate r) {
    state = state.copyWith(fromRate: r);
    _recalc(save: true);
    _loadChart();
  }

  void setToRate(Rate r) {
    state = state.copyWith(toRate: r);
    _recalc(save: true);
    _loadChart();
  }

  void swap() {
    final tmp = state.fromRate;
    state = state.copyWith(fromRate: state.toRate, toRate: tmp);
    _recalc(save: true);
    _loadChart();
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, clearError: true);
    try {
      final rates = await _repo.refreshRates();
      final from  = rates.firstWhere(
          (r) => r.code == state.fromRate?.code,
          orElse: () => rates.first);
      final to    = rates.firstWhere(
          (r) => r.code == state.toRate?.code,
          orElse: () => rates[1]);
      state = state.copyWith(
          rates: rates, fromRate: from, toRate: to, isRefreshing: false);
      _recalc();
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  void _recalc({bool save = false}) {
    final from = state.fromRate;
    final to   = state.toRate;
    if (from == null || to == null) return;

    final result = _converter(amount: state.amount, from: from, to: to);
    state = state.copyWith(result: result);

    if (save) {
      // История — дебаунс 2 сек
      _historyDebounce?.cancel();
      _historyDebounce = Timer(const Duration(seconds: 2), () {
        _ref.read(historyProvider.notifier).add(
          from:   from,
          to:     to,
          amount: state.amount,
          result: result.result,
          rate:   result.rate,
        );
      });

      // Виджет — дебаунс 1 сек
      _widgetDebounce?.cancel();
      _widgetDebounce = Timer(const Duration(seconds: 1), () {
        HomeWidgetService.update(
          from:   from,
          to:     to,
          amount: state.amount,
          result: result.result,
          rate:   result.rate,
        );
      });
    }
  }

  Future<void> _loadChart() async {
    final from = state.fromRate;
    final to   = state.toRate;
    if (from == null || to == null) return;
    try {
      final history = await _repo.getRateHistory(
          fromCode: from.code, toCode: to.code, days: 7);
      state = state.copyWith(chartData: history);
    } catch (_) {}
  }

  void _startBg() {
    _bgTimer?.cancel();
    _bgTimer = Timer.periodic(
        const Duration(minutes: 30), (_) => refresh());
  }

  @override
  void dispose() {
    _bgTimer?.cancel();
    _historyDebounce?.cancel();
    _widgetDebounce?.cancel();
    super.dispose();
  }
}

final currencyProvider =
    StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  return CurrencyNotifier(
    ref.read(currencyRepositoryProvider),
    ref.read(convertCurrencyProvider),
    ref,
  );
});
