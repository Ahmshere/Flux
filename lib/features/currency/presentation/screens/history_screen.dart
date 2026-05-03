import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/lang_provider.dart';
import '../../data/models/history_model.dart';
import '../state/history_notifier.dart';
import '../state/currency_notifier.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c       = context.appColors;
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        title: Text('History', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700,
            color: c.textPrimary)),
        iconTheme: IconThemeData(color: c.textPrimary),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('Clear all',
                style: TextStyle(color: AppTheme.red,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: history.isEmpty
          ? _EmptyHistory()
          : _HistoryList(history: history),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appColors.surface,
        title: Text('Clear history',
          style: TextStyle(color: context.appColors.textPrimary)),
        content: Text('Delete all conversion history?',
          style: TextStyle(color: context.appColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
              style: TextStyle(color: context.appColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clear();
              Navigator.pop(context);
            },
            child: const Text('Clear',
              style: TextStyle(color: AppTheme.red,
                  fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Пустое состояние ──────────────────────────────────────────────────────────
class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Center(child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('🕐', style: const TextStyle(fontSize: 48)),
        const Gap(16),
        Text('No history yet', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600,
            color: c.textPrimary)),
        const Gap(6),
        Text('Your conversions will appear here',
          style: TextStyle(fontSize: 13, color: c.textSecondary)),
      ],
    ));
  }
}

// ── Список истории ────────────────────────────────────────────────────────────
class _HistoryList extends ConsumerWidget {
  final List<HistoryEntry> history;
  const _HistoryList({required this.history});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;

    // Группируем по дням
    final grouped = <String, List<HistoryEntry>>{};
    for (final entry in history) {
      final key = _dayKey(entry.dateTime);
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: grouped.length,
      itemBuilder: (_, i) {
        final day     = grouped.keys.elementAt(i);
        final entries = grouped[day]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // День-разделитель
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(day, style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: c.textSecondary, letterSpacing: 0.05)),
            ),
            // Карточка дня
            Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: c.border),
              ),
              child: Column(
                children: entries.asMap().entries.map((e) {
                  final idx   = e.key;
                  final entry = e.value;
                  return Column(children: [
                    _HistoryRow(
                      entry: entry,
                      onTap: () => _applyToConverter(context, ref, entry),
                      onDelete: () =>
                          ref.read(historyProvider.notifier).remove(entry),
                    ),
                    if (idx < entries.length - 1)
                      Divider(height: 1, indent: 16,
                          endIndent: 16, color: c.border),
                  ]);
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyToConverter(
      BuildContext context, WidgetRef ref, HistoryEntry entry) {
    // Применяем запись к конвертеру
    final state = ref.read(currencyProvider);
    final rates = state.rates;
    final from  = rates.where((r) => r.code == entry.fromCode).firstOrNull;
    final to    = rates.where((r) => r.code == entry.toCode).firstOrNull;
    if (from != null && to != null) {
      final n = ref.read(currencyProvider.notifier);
      n.setFromRate(from);
      n.setToRate(to);
      n.setAmount(entry.amount);
    }
    Navigator.pop(context);
  }

  String _dayKey(DateTime dt) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day   = DateTime(dt.year, dt.month, dt.day);
    final diff  = today.difference(day).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}

// ── Строка записи ─────────────────────────────────────────────────────────────
class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryRow({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  String _fmt(double v) {
    if (v < 0.0001) return v.toStringAsFixed(6);
    if (v < 1)      return v.toStringAsFixed(4);
    return v.toStringAsFixed(2);
  }

  String _time(DateTime dt) {
    return '${dt.hour.toString().padLeft(2,'0')}:'
        '${dt.minute.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Dismissible(
      key: Key('${entry.timestamp}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded,
            color: AppTheme.red, size: 20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          child: Row(children: [
            // Валюты
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('${_fmt(entry.amount)} ${entry.fromCode}',
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                      fontFamily: 'monospace')),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('→', style: TextStyle(
                      color: c.textSecondary, fontSize: 14)),
                ),
                Text('${_fmt(entry.result)} ${entry.toCode}',
                  style: TextStyle(fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                      fontFamily: 'monospace')),
              ]),
              const Gap(3),
              Text(
                '1 ${entry.fromCode} = ${_fmt(entry.rate)} ${entry.toCode}',
                style: TextStyle(fontSize: 10,
                    color: c.textSecondary,
                    fontFamily: 'monospace'),
              ),
            ]),
            const Spacer(),
            // Время + иконка "применить"
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_time(entry.dateTime),
                style: TextStyle(fontSize: 11,
                    color: c.textSecondary)),
              const Gap(4),
              Icon(Icons.replay_rounded,
                  size: 14, color: c.textSecondary.withOpacity(0.5)),
            ]),
          ]),
        ),
      ),
    );
  }
}
