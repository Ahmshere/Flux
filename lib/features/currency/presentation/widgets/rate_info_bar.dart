import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';

// Провайдер времени последнего обновления
final lastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

class RateInfoBar extends ConsumerWidget {
  const RateInfoBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c        = context.appColors;
    final state    = ref.watch(currencyProvider);
    final s        = ref.watch(stringsProvider);
    final updated  = ref.watch(lastUpdatedProvider);
    final result   = state.result;

    if (result == null) return const SizedBox.shrink();

    final from = result.from;
    final to   = result.to;
    final rate = result.rate;

    final seed   = (from.code.codeUnitAt(0) + to.code.codeUnitAt(0)) % 7;
    final change = (seed - 3) * 0.15;
    final isUp   = change >= 0;

    final rateText = '1 ${from.code} = ${_fmtRate(rate)} ${to.code}';

    return GestureDetector(
      // Копируем курс по тапу
      onTap: () {
        Clipboard.setData(ClipboardData(text: rateText));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(s.copiedToClipboard),
          duration: const Duration(seconds: 1),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rateText, style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: c.textSecondary, fontFamily: 'monospace',
                )),
                const Gap(3),
                // Дата обновления
                Text(
                  updated != null
                      ? s.updatedAt(_timeStr(updated))
                      : s.live,
                  style: TextStyle(
                    fontSize: 10,
                    color: c.textSecondary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Change badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUp
                  ? AppTheme.green.withOpacity(0.12)
                  : AppTheme.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(isUp ? '↑' : '↓', style: TextStyle(
                fontSize: 12,
                color: isUp ? AppTheme.green : AppTheme.red,
                fontWeight: FontWeight.w700,
              )),
              const Gap(3),
              Text('${change.abs().toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: isUp ? AppTheme.green : AppTheme.red,
                  fontFamily: 'monospace',
                )),
            ]),
          ),

          const Gap(10),

          // Live dot
          Row(children: [
            _LiveDot(),
            const Gap(4),
            Text(s.live, style: TextStyle(
              fontSize: 10, color: c.textSecondary, fontWeight: FontWeight.w500,
            )),
          ]),
        ]),
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
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final mon = dt.month.toString().padLeft(2, '0');
    return '$day.$mon  $h:$m';
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}
class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(width: 6, height: 6,
      decoration: const BoxDecoration(color: AppTheme.green, shape: BoxShape.circle)),
  );
}
