import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/rate.dart';
import '../state/currency_notifier.dart';

class ConverterCard extends ConsumerWidget {
  const ConverterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c     = context.appColors;
    final state = ref.watch(currencyProvider);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(children: [
        // FROM
        _CurrencyRow(
          rate: state.fromRate,
          allRates: state.rates,
          isFrom: true,
          amount: state.amount,
          onRateChanged: (r) =>
              ref.read(currencyProvider.notifier).setFromRate(r),
          onAmountChanged: (v) =>
              ref.read(currencyProvider.notifier).setAmount(v),
        ),

        // Divider + Swap
        Stack(
          alignment: Alignment.center,
          children: [
            Divider(height: 1, color: c.border),
            _SwapButton(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(currencyProvider.notifier).swap();
              },
            ),
          ],
        ),

        // TO
        _CurrencyRow(
          rate: state.toRate,
          allRates: state.rates,
          isFrom: false,
          amount: state.result?.result,
          onRateChanged: (r) =>
              ref.read(currencyProvider.notifier).setToRate(r),
        ),
      ]),
    );
  }
}

// ── Строка валюты ─────────────────────────────────────────────────────────────

class _CurrencyRow extends ConsumerWidget {
  final Rate? rate;
  final List<Rate> allRates;
  final bool isFrom;
  final double? amount;
  final ValueChanged<Rate> onRateChanged;
  final ValueChanged<double>? onAmountChanged;

  const _CurrencyRow({
    required this.rate,
    required this.allRates,
    required this.isFrom,
    required this.onRateChanged,
    this.amount,
    this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        // Flag
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: c.surface2, shape: BoxShape.circle),
          child: Center(
            child: Text(rate?.flag ?? '🌍',
                style: const TextStyle(fontSize: 22)),
          ),
        ),
        const Gap(12),

        // Selector
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<Rate>(
                  value: rate,
                  isDense: true,
                  dropdownColor: c.surface,
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: c.textPrimary, letterSpacing: -0.3,
                  ),
                  items: allRates.map((r) => DropdownMenuItem(
                    value: r,
                    child: Text('${r.flag}  ${r.code}'),
                  )).toList(),
                  onChanged: (r) {
                    if (r != null) {
                      HapticFeedback.selectionClick();
                      onRateChanged(r);
                    }
                  },
                ),
              ),
              const Gap(2),
              Text(rate?.name ?? '',
                  style: TextStyle(fontSize: 11, color: c.textSecondary)),
            ],
          ),
        ),
        const Gap(8),

        // Amount
        SizedBox(
          width: 130,
          child: isFrom
              ? _AmountInput(amount: amount ?? 0, onChanged: onAmountChanged)
              : _AmountResult(amount: amount),
        ),
      ]),
    );
  }
}

// ── Ввод суммы (FROM) ─────────────────────────────────────────────────────────

class _AmountInput extends StatefulWidget {
  final double amount;
  final ValueChanged<double>? onChanged;
  const _AmountInput({required this.amount, this.onChanged});

  @override
  State<_AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<_AmountInput> {
  late final TextEditingController _ctrl;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _fmt(widget.amount));
  }

  @override
  void didUpdateWidget(_AmountInput old) {
    super.didUpdateWidget(old);
    if (!_focused && old.amount != widget.amount) {
      _ctrl.text = _fmt(widget.amount);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: TextField(
        controller: _ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600,
          color: _focused ? AppTheme.accent : c.textPrimary,
          fontFamily: 'monospace',
        ),
        decoration: const InputDecoration(
          border: InputBorder.none, isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) {
          final n = double.tryParse(v.replaceAll(',', '.'));
          if (n != null && n > 0) widget.onChanged?.call(n);
        },
      ),
    );
  }
}

// ── Результат (TO) — копируется по тапу ──────────────────────────────────────

class _AmountResult extends ConsumerWidget {
  final double? amount;
  const _AmountResult({this.amount});

  String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v < 0.001)    return v.toStringAsFixed(8);
    if (v < 1)        return v.toStringAsFixed(4);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final s = ref.watch(stringsProvider);
    final text = amount != null ? _fmt(amount!) : '—';

    return GestureDetector(
      onTap: () {
        if (amount == null) return;
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.copiedToClipboard),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w600,
              color: c.textPrimary, fontFamily: 'monospace',
            ),
          ),
          // Подсказка "нажмите чтобы скопировать"
          if (amount != null)
            Text(s.tapToCopy,
              style: TextStyle(fontSize: 9, color: c.textSecondary),
            ),
        ],
      ),
    );
  }
}

// ── Кнопка Swap ───────────────────────────────────────────────────────────────

class _SwapButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SwapButton({required this.onTap});

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: () { _ctrl.forward(from: 0); widget.onTap(); },
      child: RotationTransition(
        turns: _ctrl,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: c.surface, shape: BoxShape.circle,
            border: Border.all(color: c.border, width: 1.5),
          ),
          child: const Center(
            child: Text('⇅', style: TextStyle(fontSize: 15)),
          ),
        ),
      ),
    );
  }
}