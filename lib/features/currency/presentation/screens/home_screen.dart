import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/lang_provider.dart';
import '../state/currency_notifier.dart';
import '../widgets/natural_input_widget.dart';
import '../widgets/converter_card.dart';
import '../widgets/rate_info_bar.dart';
import '../widgets/mini_chart.dart';
import '../widgets/quick_amounts.dart';
import '../widgets/error_view.dart';
import '../widgets/settings_sheet.dart';
import 'analytics_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(currencyProvider.notifier).init();
      ref.read(lastUpdatedProvider.notifier).state = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c     = context.appColors;
    final state = ref.watch(currencyProvider);
    final s     = ref.watch(stringsProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: state.isLoading
            ? _LoadingView(label: s.loading)
            : Column(children: [
                const _Header(),
                if (state.error != null && state.rates.isEmpty)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ErrorView(message: state.error!),
                    ),
                  )
                else
                  Expanded(child: _buildBody(c, state, s)),
              ]),
      ),
    );
  }

  Widget _buildBody(AppColors c, CurrencyState state, S s) {
    return Column(children: [
      if (state.error != null && state.rates.isNotEmpty)
        _OfflineBanner(label: s.offlineCache),
      Expanded(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              const Gap(8),
              _Tabs(selected: _tab, onChanged: (i) => setState(() => _tab = i)),
              const Gap(12),
              if (_tab == 0) _converterTab(),
              if (_tab == 1) const AnalyticsTab(),
              if (_tab == 2) const FavoritesTab(),
              const Gap(32),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _converterTab() => const Column(children: [
    NaturalInputWidget(), Gap(12),
    QuickAmounts(),       Gap(12),
    ConverterCard(),      Gap(12),
    RateInfoBar(),        Gap(12),
    MiniChart(),
  ]);
}

// ── Loading ───────────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  final String label;
  const _LoadingView({required this.label});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const CircularProgressIndicator(color: AppTheme.accent),
      const Gap(16),
      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 14)),
    ]));
  }
}

// ── Offline banner ────────────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  final String label;
  const _OfflineBanner({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: AppTheme.amber.withOpacity(0.15),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      const Text('⚠️', style: TextStyle(fontSize: 14)),
      const Gap(8),
      Text(label, style: TextStyle(fontSize: 12,
          color: AppTheme.amber, fontWeight: FontWeight.w500)),
    ]),
  );
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  const _Header();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c            = context.appColors;
    final isRefreshing = ref.watch(
        currencyProvider.select((s) => s.isRefreshing));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        Text('Flux', style: TextStyle(fontSize: 20,
            fontWeight: FontWeight.w700, color: c.textPrimary,
            letterSpacing: -0.5)),
        const Gap(6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.accent, AppTheme.accentLight]),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('PRO', style: TextStyle(color: Colors.white,
              fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ),
        const Spacer(),
        _IconBtn(
          onTap: isRefreshing ? null : () async {
            HapticFeedback.lightImpact();
            await ref.read(currencyProvider.notifier).refresh();
            ref.read(lastUpdatedProvider.notifier).state = DateTime.now();
          },
          child: isRefreshing
              ? const SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('↻', style: TextStyle(fontSize: 18)),
        ),
        const Gap(6),
        _IconBtn(
          onTap: () => SettingsSheet.show(context),
          child: const Text('⚙️', style: TextStyle(fontSize: 16)),
        ),
      ]),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _IconBtn({required this.onTap, required this.child});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: c.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border)),
        child: Center(child: child),
      ),
    );
  }
}

// ── Tabs ──────────────────────────────────────────────────────────────────────
class _Tabs extends ConsumerWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _Tabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c      = context.appColors;
    final s      = ref.watch(stringsProvider);
    final labels = [s.tabConverter, s.tabAnalytics, s.tabFavorites];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border)),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppTheme.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(labels[i], textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : c.textSecondary)),
              ),
            ),
          );
        }),
      ),
    );
  }
}
