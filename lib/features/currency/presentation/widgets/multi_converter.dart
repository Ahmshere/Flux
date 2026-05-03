import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/pro/pro_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/rate.dart';
import '../state/currency_notifier.dart';
import '../screens/paywall_screen.dart';

// Бесплатно показываем 5 валют, PRO — все
const _freeLimit = 5;

class MultiConverter extends ConsumerStatefulWidget {
  const MultiConverter({super.key});

  @override
  ConsumerState<MultiConverter> createState() => _MultiConverterState();
}

class _MultiConverterState extends ConsumerState<MultiConverter> {
  final _ctrl = TextEditingController(text: '100');
  double _amount = 100;

  // Порядок валют в мульти-списке
  static const _order = [
    'USD', 'EUR', 'GBP', 'ILS', 'JPY',
    'CHF', 'CAD', 'AUD', 'CNY', 'AED', 'RUB', 'BTC', 'ETH',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c      = context.appColors;
    final s      = ref.watch(stringsProvider);
    final state  = ref.watch(currencyProvider);
    final isPro  = ref.watch(proProvider);
    final rates  = state.rates;
    final base   = state.fromRate;

    if (base == null || rates.isEmpty) return const SizedBox.shrink();

    // Сортируем по нашему порядку, исключаем базовую валюту
    final sorted = _order
        .map((code) => rates.where((r) => r.code == code).firstOrNull)
        .whereType<Rate>()
        .where((r) => r.code != base.code)
        .toList();

    // Ограничение для бесплатных
    final visible   = isPro ? sorted : sorted.take(_freeLimit).toList();
    final lockedCnt = sorted.length - visible.length;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Заголовок + поле ввода ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(children: [
              Text('${base.flag}  ${base.code}',
                style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w700, color: c.textPrimary)),
              const Spacer(),
              // Поле ввода суммы
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _ctrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                      fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) {
                    final n = double.tryParse(v.replaceAll(',', '.'));
                    if (n != null && n > 0) {
                      setState(() => _amount = n);
                    }
                  },
                ),
              ),
            ]),
          ),

          Divider(height: 16, color: c.border),

          // ── Список валют ───────────────────────────────────────────────────
          ...visible.asMap().entries.map((e) {
            final i    = e.key;
            final rate = e.value;
            final result = Rate.convert(
                amount: _amount, from: base, to: rate);

            return Column(children: [
              _RateRow(
                rate: rate,
                result: result,
                amount: _amount,
                base: base,
              ),
              if (i < visible.length - 1 || lockedCnt > 0)
                Divider(height: 1, indent: 16,
                    endIndent: 16, color: c.border),
            ]);
          }),

          // ── Заблокированные валюты (PRO) ───────────────────────────────────
          if (lockedCnt > 0)
            GestureDetector(
              onTap: () => PaywallScreen.show(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.06),
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(20)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  const Icon(Icons.lock_rounded,
                      size: 13, color: AppTheme.accent),
                  const Gap(6),
                  Text(
                    'PRO — unlock $lockedCnt more currencies',
                    style: const TextStyle(fontSize: 12,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w500),
                  ),
                ]),
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Строка одной валюты ───────────────────────────────────────────────────────
class _RateRow extends StatelessWidget {
  final Rate rate;
  final double result;
  final double amount;
  final Rate base;

  const _RateRow({
    required this.rate,
    required this.result,
    required this.amount,
    required this.base,
  });

  String _fmt(double v) {
    if (v < 0.00001) return v.toStringAsFixed(8);
    if (v < 0.001)   return v.toStringAsFixed(6);
    if (v < 1)       return v.toStringAsFixed(4);
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return GestureDetector(
      // Копируем по тапу
      onTap: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: _fmt(result)));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${_fmt(result)} ${rate.code} copied'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(children: [
          // Флаг
          Text(rate.flag, style: const TextStyle(fontSize: 20)),
          const Gap(10),
          // Код + название
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rate.code, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: c.textPrimary)),
            Text(rate.name, style: TextStyle(
                fontSize: 10, color: c.textSecondary)),
          ]),
          const Spacer(),
          // Результат
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_fmt(result), style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600,
                color: c.textPrimary, fontFamily: 'monospace')),
            // Мелко: курс 1 к 1
            Text(
              '1 ${base.code} = ${_fmt(Rate.exchangeRate(base, rate))} ${rate.code}',
              style: TextStyle(fontSize: 9,
                  color: c.textSecondary, fontFamily: 'monospace'),
            ),
          ]),
        ]),
      ),
    );
  }
}
