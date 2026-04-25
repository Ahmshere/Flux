import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';

class AnalyticsState {
  final List<double> data;
  final bool isLoading;
  final String? error;

  const AnalyticsState({
    this.data = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    List<double>? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) => AnalyticsState(
    data: data ?? this.data,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
  );
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final ref;
  AnalyticsNotifier(this.ref) : super(const AnalyticsState());

  Future<void> load({
    required String fromCode,
    required String toCode,
    required int days,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(currencyRepositoryProvider);
      final data = await repo.getRateHistory(
        fromCode: fromCode,
        toCode: toCode,
        days: days,
      );
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref);
});
