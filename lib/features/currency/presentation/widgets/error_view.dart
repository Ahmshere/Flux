import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';

class ErrorView extends ConsumerWidget {
  final String message;
  const ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 36)),
          const Gap(12),
          Text(
            'Не удалось загрузить курсы',
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const Gap(6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: c.textSecondary),
          ),
          const Gap(16),
          GestureDetector(
            onTap: () => ref.read(currencyProvider.notifier).init(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Повторить',
                style: TextStyle(
                  color: Colors.white, fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
