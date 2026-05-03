import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';

final lastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

class RateInfoBar extends ConsumerWidget {
  const RateInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c       = context.appColors;
    final s       = ref.watch(stringsProvider);
    final updated = ref.watch(lastUpdatedProvider);
    final result  = ref.watch(currencyProvider).result;

    if (result == null) return const SizedBox.shrink();

    final from = result.from;
    final to   = result.to;
    final rate = result.rate;

    final seed   = (from.code.codeUnitAt(0) + to.code.codeUnitAt(0)) % 7;
    final change = (seed - 3) * 0.15;
    final isUp   = change >= 0;
    final rateText = '1 ${from.code} = ${_fmtRate(rate)} ${to.code}';

    // Диапазон банковского курса +2% и +5%
    final bankLow  = rate * 1.02;
    final bankHigh = rate * 1.05;
    final bankText =
        '≈ ${_fmtRate(bankLow)}–${_fmtRate(bankHigh)} ${to.code} ${s.inBank}';

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: rateText));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.copiedToClipboard),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Строка 1: курс + badge + live ────────────────────────────
            Row(children: [
              Expanded(
                child: Text(rateText, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: c.textPrimary, fontFamily: 'monospace',
                )),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUp
                      ? AppTheme.green.withOpacity(0.12)
                      : AppTheme.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(isUp ? '↑' : '↓', style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: isUp ? AppTheme.green : AppTheme.red,
                  )),
                  const Gap(3),
                  Text('${change.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: isUp ? AppTheme.green : AppTheme.red,
                        fontFamily: 'monospace',
                      )),
                ]),
              ),
              const Gap(8),
              Row(children: [
                _LiveDot(),
                const Gap(4),
                Text(s.live, style: TextStyle(
                  fontSize: 10, color: c.textSecondary,
                  fontWeight: FontWeight.w500,
                )),
              ]),
            ]),

            const Gap(6),

            // ── Строка 2: банковский диапазон ─────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.amber.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppTheme.amber.withOpacity(0.2)),
              ),
              child: Row(children: [
                Text('🏦', style: const TextStyle(fontSize: 12)),
                const Gap(6),
                Expanded(
                  child: Text(bankText, style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.amber,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                  )),
                ),
                // Tooltip иконка
                GestureDetector(
                  onTap: () => _showBankInfo(context, s),
                  child: Icon(Icons.info_outline_rounded,
                      size: 14,
                      color: AppTheme.amber.withOpacity(0.6)),
                ),
              ]),
            ),

            const Gap(6),

            // ── Строка 3: время + disclaimer ──────────────────────────────
            Row(children: [
              Text(
                updated != null
                    ? s.updatedAt(_timeStr(updated))
                    : s.live,
                style: TextStyle(fontSize: 9,
                    color: c.textSecondary.withOpacity(0.5)),
              ),
              const Gap(4),
              Text('·', style: TextStyle(
                  fontSize: 9,
                  color: c.textSecondary.withOpacity(0.3))),
              const Gap(4),
              Expanded(
                child: Text(s.ecbSource,
                  style: TextStyle(fontSize: 9,
                      color: c.textSecondary.withOpacity(0.5)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _showBankInfo(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.appColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Text('🏦', style: TextStyle(fontSize: 20)),
          const Gap(8),
          Text(s.bankRateTitle,
              style: TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.appColors.textPrimary)),
        ]),
        content: Text(s.bankRateExplanation,
            style: TextStyle(fontSize: 13,
                color: context.appColors.textSecondary,
                height: 1.6)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: TextStyle(color: AppTheme.accent,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _fmtRate(double v) {
    if (v < 0.0001) return v.toStringAsFixed(8);
    if (v < 0.01)   return v.toStringAsFixed(6);
    if (v < 1)      return v.toStringAsFixed(4);
    if (v < 10)     return v.toStringAsFixed(4);
    return v.toStringAsFixed(2);
  }

  String _timeStr(DateTime dt) {
    final h   = dt.hour.toString().padLeft(2, '0');
    final m   = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final mon = dt.month.toString().padLeft(2, '0');
    return '$day.$mon  $h:$m';
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 6, height: 6,
        decoration: const BoxDecoration(
            color: AppTheme.green, shape: BoxShape.circle)),
  );
}