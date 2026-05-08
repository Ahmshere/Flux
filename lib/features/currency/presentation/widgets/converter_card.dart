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
import 'animated_number.dart';

const _freeCodes = ['USD', 'EUR', 'GBP', 'ILS', 'INR'];

class ConverterCard extends ConsumerWidget {
  const ConverterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c      = context.appColors;
    final state  = ref.watch(currencyProvider);
    final isPro  = ref.watch(proProvider);
    final rates  = isPro
        ? state.rates
        : state.rates.where((r) => _freeCodes.contains(r.code)).toList();

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(children: [
        _CurrencyRow(
          rate: state.fromRate,
          allRates: rates,
          isFrom: true,
          amount: state.amount,
          isPro: isPro,
          onRateChanged: (r) =>
              ref.read(currencyProvider.notifier).setFromRate(r),
          onAmountChanged: (v) =>
              ref.read(currencyProvider.notifier).setAmount(v),
        ),
        Stack(alignment: Alignment.center, children: [
          Divider(height: 1, color: c.border),
          _SwapButton(onTap: () {
            HapticFeedback.lightImpact();
            ref.read(currencyProvider.notifier).swap();
          }),
        ]),
        _CurrencyRow(
          rate: state.toRate,
          allRates: rates,
          isFrom: false,
          amount: state.result?.result,
          isPro: isPro,
          onRateChanged: (r) =>
              ref.read(currencyProvider.notifier).setToRate(r),
        ),
        if (!isPro) _UnlockMoreCurrencies(),
      ]),
    );
  }
}

class _UnlockMoreCurrencies extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final s = ref.watch(stringsProvider);
    return GestureDetector(
      onTap: () => _showCurrencyList(context, s),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.08),
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20)),
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.lock_rounded, size: 13, color: AppTheme.accent),
          const Gap(6),
          Text('PRO — unlock 25+ currencies',
              style: const TextStyle(fontSize: 12,
                  color: AppTheme.accent, fontWeight: FontWeight.w500)),
          const Gap(4),
          const Icon(Icons.info_outline_rounded,
              size: 13, color: AppTheme.accent),
        ]),
      ),
    );
  }

  void _showCurrencyList(BuildContext context, dynamic s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: context.appColors.bg,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(
                    color: context.appColors.border,
                    borderRadius: BorderRadius.circular(2))),
            const Gap(16),
            Text('PRO Currencies',
                style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary)),
            const Gap(8),
            Text(s.proUnlockCurrencies,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13,
                    color: context.appColors.textSecondary,
                    height: 1.8,
                    fontFamily: 'monospace')),
            const Gap(20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  PaywallScreen.show(context);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                child: const Text('Unlock PRO',
                    style: TextStyle(color: Colors.white,
                        fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencyRow extends ConsumerWidget {
  final Rate? rate;
  final List<Rate> allRates;
  final bool isFrom;
  final bool isPro;
  final double? amount;
  final ValueChanged<Rate> onRateChanged;
  final ValueChanged<double>? onAmountChanged;

  const _CurrencyRow({
    required this.rate,
    required this.allRates,
    required this.isFrom,
    required this.isPro,
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
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: c.surface2, shape: BoxShape.circle),
          child: Center(child: Text(rate?.flag ?? '🌍',
              style: const TextStyle(fontSize: 22))),
        ),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<Rate>(
                  value: allRates.contains(rate) ? rate : null,
                  isDense: true,
                  dropdownColor: c.surface,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      color: c.textPrimary, letterSpacing: -0.3),
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
        SizedBox(
          width: 130,
          child: isFrom
              ? _AmountInput(
              amount: amount ?? 0,
              onChanged: onAmountChanged)
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
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
            color: _focused ? AppTheme.accent : c.textPrimary,
            fontFamily: 'monospace'),
        decoration: const InputDecoration(
            border: InputBorder.none, isDense: true,
            contentPadding: EdgeInsets.zero),
        onChanged: (v) {
          final n = double.tryParse(v.replaceAll(',', '.'));
          if (n != null && n > 0) widget.onChanged?.call(n);
        },
      ),
    );
  }
}

// ── Результат с анимацией (TO) ────────────────────────────────────────────────
class _AmountResult extends ConsumerWidget {
  final double? amount;
  const _AmountResult({this.amount});

  static String _fmt(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(2)}M';
    if (v < 0.001)    return v.toStringAsFixed(8);
    if (v < 1)        return v.toStringAsFixed(4);
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final s = ref.watch(stringsProvider);

    if (amount == null) {
      return Text('—', textAlign: TextAlign.right,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
              color: c.textPrimary, fontFamily: 'monospace'));
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: _fmt(amount!)));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.copiedToClipboard),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        // ── Анимированное число ───────────────────────────────────────────
        AnimatedNumber(
          value: amount!,
          formatter: _fmt,
          style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600,
            color: c.textPrimary, fontFamily: 'monospace',
          ),
        ),
        Text(s.tapToCopy,
            style: TextStyle(fontSize: 9, color: c.textSecondary)),
      ]),
    );
  }
}

// ── Swap ──────────────────────────────────────────────────────────────────────
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
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 300));
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
          decoration: BoxDecoration(color: c.surface,
              shape: BoxShape.circle,
              border: Border.all(color: c.border, width: 1.5)),
          child: const Center(
              child: Text('⇅', style: TextStyle(fontSize: 15))),
        ),
      ),
    );
  }
}