import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/history_model.dart';
import '../../domain/entities/rate.dart';

const _boxName  = 'conversion_history';
const _maxItems = 100; // максимум записей

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  return HistoryNotifier();
});

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  HistoryNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final box = await Hive.openBox<HistoryEntry>(_boxName);
    // Сортируем: последние сверху
    final entries = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = entries;
  }

  Future<void> add({
    required Rate from,
    required Rate to,
    required double amount,
    required double result,
    required double rate,
  }) async {
    // Не сохраняем одинаковые подряд
    if (state.isNotEmpty) {
      final last = state.first;
      if (last.fromCode == from.code &&
          last.toCode   == to.code   &&
          last.amount   == amount) return;
    }

    final entry = HistoryEntry(
      fromCode:  from.code,
      toCode:    to.code,
      amount:    amount,
      result:    result,
      rate:      rate,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final box = await Hive.openBox<HistoryEntry>(_boxName);
    await box.add(entry);

    // Ограничиваем размер
    if (box.length > _maxItems) {
      final oldest = box.values.toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      await oldest.first.delete();
    }

    state = [entry, ...state.take(_maxItems - 1)];
  }

  Future<void> clear() async {
    final box = await Hive.openBox<HistoryEntry>(_boxName);
    await box.clear();
    state = [];
  }

  Future<void> remove(HistoryEntry entry) async {
    await entry.delete();
    state = state.where((e) => e != entry).toList();
  }
}
