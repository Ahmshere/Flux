import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/pro/pro_provider.dart';
import '../../../../core/theme/app_theme.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  /// Показывает paywall как bottom sheet
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PaywallScreen(),
    );
    return result ?? false;
  }

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _loading = false;

  Future<void> _purchase() async {
    setState(() => _loading = true);
    try {
      // TODO: реальная покупка через purchases_flutter
      // final offerings = await Purchases.getOfferings();
      // await Purchases.purchasePackage(package);
      await Future.delayed(const Duration(seconds: 1)); // имитация
      await ref.read(proProvider.notifier).unlock();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
              backgroundColor: AppTheme.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _loading = true);
    try {
      await ref.read(proProvider.notifier).restore();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nothing to restore'),
              backgroundColor: AppTheme.amber),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24, 12, 24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),

          // ── Иконка + название ─────────────────────────────────────────────
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentLight],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(
                color: AppTheme.accent.withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 6),
              )],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset('assets/icon.png', fit: BoxFit.cover),
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

          const Gap(16),

          const Text('Flux PRO',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: -0.5),
          ).animate().fadeIn(delay: 100.ms),

          const Gap(6),

          Text('Unlock everything',
            style: TextStyle(fontSize: 14,
                color: Colors.white.withOpacity(0.5)),
          ).animate().fadeIn(delay: 150.ms),

          const Gap(28),

          // ── Фичи ─────────────────────────────────────────────────────────
          ...[
            _Feature(icon: '⭐', title: 'Favorites',
                sub: 'Save & track your currency pairs'),
            _Feature(icon: '📶', title: 'Offline mode',
                sub: 'Works without internet connection'),
            _Feature(icon: '🚫', title: 'No ads',
                sub: 'Clean experience, no distractions'),
            _Feature(icon: '📊', title: 'Full analytics',
                sub: '30-day charts and insights'),
          ].asMap().entries.map((e) => e.value
              .animate()
              .fadeIn(delay: Duration(milliseconds: 200 + e.key * 80))
              .slideX(begin: 0.2, end: 0)),

          const Gap(28),

          // ── Кнопка покупки ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('\$1.99 / month',
                      style: TextStyle(fontSize: 17,
                          fontWeight: FontWeight.w700)),
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),

          const Gap(12),

          // ── Восстановить покупки ─────────────────────────────────────────
          TextButton(
            onPressed: _loading ? null : _restore,
            child: Text('Restore purchases',
              style: TextStyle(fontSize: 13,
                  color: Colors.white.withOpacity(0.4))),
          ),

          const Gap(4),

          Text('Cancel anytime · Secure payment',
            style: TextStyle(fontSize: 11,
                color: Colors.white.withOpacity(0.25))),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final String icon, title, sub;
  const _Feature({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon,
              style: const TextStyle(fontSize: 20))),
        ),
        const Gap(14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: Colors.white)),
            const Gap(2),
            Text(sub, style: TextStyle(fontSize: 12,
                color: Colors.white.withOpacity(0.45))),
          ],
        )),
        const Icon(Icons.check_circle_rounded,
            color: AppTheme.green, size: 20),
      ]),
    );
  }
}
