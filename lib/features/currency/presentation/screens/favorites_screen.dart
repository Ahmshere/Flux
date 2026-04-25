import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/lang_provider.dart';
import '../../domain/entities/rate.dart';
import '../state/currency_notifier.dart';
import '../state/favorites_notifier.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   // final c         = context.appColors;
   // final s         = ref.watch(stringsProvider);
    final favorites = ref.watch(favoritesProvider);
    final state     = ref.watch(currencyProvider);
    final rates     = state.rates;

    return Column(children: [
      // ── PRO баннер ────────────────────────────────────────────────────────
      _ProBanner(),
      const Gap(12),

      // ── Кнопка добавить текущую пару ─────────────────────────────────────
      if (state.fromRate != null && state.toRate != null)
        _AddCurrentPair(
          from: state.fromRate!,
          to: state.toRate!,
        ),
      const Gap(12),

      // ── Список избранных ──────────────────────────────────────────────────
      if (favorites.isEmpty)
        _EmptyState()
      else
        _FavoritesList(favorites: favorites, rates: rates),
    ]);
  }
}

// ── PRO баннер ────────────────────────────────────────────────────────────────
class _ProBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3d2fa0), Color(0xFF7c6af7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Kurso PRO',
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w700)),
            const Gap(3),
            Text('Offline mode · No ads · Favorites',
              style: TextStyle(color: Colors.white.withOpacity(0.7),
                  fontSize: 12)),
          ]),
        ),
        GestureDetector(
          onTap: () {
            // TODO: открыть in-app purchase
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('\$1.99 / mo',
              style: TextStyle(color: Color(0xFF3d2fa0),
                  fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

// ── Добавить текущую пару ─────────────────────────────────────────────────────
class _AddCurrentPair extends ConsumerWidget {
  final Rate from, to;
  const _AddCurrentPair({required this.from, required this.to});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c       = context.appColors;
    final pair    = '${from.code}/${to.code}';
    final isFav   = ref.watch(favoritesProvider.select(
        (list) => list.contains(pair)));

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(favoritesProvider.notifier).toggle(pair);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFav ? AppTheme.accent : c.border,
            width: isFav ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Text('${from.flag} ${from.code}  →  ${to.flag} ${to.code}',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                color: c.textPrimary)),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isFav ? Icons.star_rounded : Icons.star_outline_rounded,
              key: ValueKey(isFav),
              color: isFav ? AppTheme.accent : c.textSecondary,
              size: 22,
            ),
          ),
          const Gap(4),
          Text(
            isFav ? 'Saved' : 'Save pair',
            style: TextStyle(
              fontSize: 12,
              color: isFav ? AppTheme.accent : c.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Пустое состояние ──────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(children: [
        const Text('⭐', style: TextStyle(fontSize: 40)),
        const Gap(12),
        Text('No favorites yet',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: c.textPrimary)),
        const Gap(6),
        Text('Go to Converter and save your favorite pairs',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: c.textSecondary)),
      ]),
    );
  }
}

// ── Список избранных ──────────────────────────────────────────────────────────
class _FavoritesList extends ConsumerWidget {
  final List<String> favorites;
  final List<Rate> rates;

  const _FavoritesList({required this.favorites, required this.rates});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: List.generate(favorites.length, (i) {
          final pair   = favorites[i];
          final parts  = pair.split('/');
          if (parts.length != 2) return const SizedBox.shrink();

          final from = rates.where((r) => r.code == parts[0]).firstOrNull;
          final to   = rates.where((r) => r.code == parts[1]).firstOrNull;
          if (from == null || to == null) return const SizedBox.shrink();

          final rate = Rate.exchangeRate(from, to);

          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Text('${from.flag} ${from.code}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
                const Gap(6),
                Text('→', style: TextStyle(color: c.textSecondary)),
                const Gap(6),
                Text('${to.flag} ${to.code}',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
                const Spacer(),
                Text(_fmtRate(rate),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                      color: c.textPrimary, fontFamily: 'monospace')),
                const Gap(12),
                // Удалить
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(favoritesProvider.notifier).toggle(pair);
                  },
                  child: Icon(Icons.star_rounded,
                      color: AppTheme.accent, size: 20),
                ),
              ]),
            ),
            if (i < favorites.length - 1)
              Divider(height: 1, color: c.border),
          ]);
        }),
      ),
    );
  }

  String _fmtRate(double v) {
    if (v < 0.0001) return v.toStringAsFixed(8);
    if (v < 0.01)   return v.toStringAsFixed(6);
    if (v < 1)      return v.toStringAsFixed(4);
    return v.toStringAsFixed(4);
  }
}
