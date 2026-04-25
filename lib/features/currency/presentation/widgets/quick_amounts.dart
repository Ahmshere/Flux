import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';

class QuickAmounts extends ConsumerWidget {
  const QuickAmounts({super.key});

  static const _amounts = [10.0, 50.0, 100.0, 500.0, 1000.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c       = context.appColors;
    final current = ref.watch(currencyProvider.select((s) => s.amount));

    return Row(
      children: _amounts.map((amount) {
        final active = current == amount;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(currencyProvider.notifier).setAmount(amount);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppTheme.accent : c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: active ? AppTheme.accent : c.border,
                  ),
                ),
                child: Text(
                  _label(amount),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : c.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _label(double v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }
}