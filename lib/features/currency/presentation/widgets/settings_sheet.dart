import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c      = context.appColors;
    final s      = ref.watch(stringsProvider);
    final isDark = context.isDark;
    final lang   = ref.watch(langProvider);

    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 12, 20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(20),

          Text(s.settings, style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w700,
            color: c.textPrimary, letterSpacing: -0.5,
          )),
          const Gap(24),

          // ── Theme ──────────────────────────────────────────────────────────
          _Label(s.theme),
          const Gap(8),
          _SegmentRow(items: [
            _Seg(
              label: '🌙  ${s.themeDark}',
              active: isDark,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setMode(ThemeMode.dark),
            ),
            _Seg(
              label: '☀️  ${s.themeLight}',
              active: !isDark,
              onTap: () => ref
                  .read(themeModeProvider.notifier)
                  .setMode(ThemeMode.light),
            ),
          ]),
          const Gap(24),

          // ── Language ───────────────────────────────────────────────────────
          _Label(s.language),
          const Gap(8),
          _SegmentRow(items: [
            _Seg(
              label: '🇬🇧  EN',
              active: lang == AppLang.en,
              onTap: () =>
                  ref.read(langProvider.notifier).setLang(AppLang.en),
            ),
            _Seg(
              label: '🇩🇪  DE',
              active: lang == AppLang.de,
              onTap: () =>
                  ref.read(langProvider.notifier).setLang(AppLang.de),
            ),
            _Seg(
              label: '🇷🇺  RU',
              active: lang == AppLang.ru,
              onTap: () =>
                  ref.read(langProvider.notifier).setLang(AppLang.ru),
            ),
          ]),
          const Gap(28),

          Center(
            child: Text('Flux PRO  v1.0.0',
              style: TextStyle(fontSize: 12, color: c.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: context.appColors.textSecondary, letterSpacing: 0.08,
  ));
}

class _Seg {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Seg({required this.label, required this.active, required this.onTap});
}

class _SegmentRow extends StatelessWidget {
  final List<_Seg> items;
  const _SegmentRow({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: items.map((item) => Expanded(
          child: GestureDetector(
            onTap: item.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: item.active ? AppTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: item.active ? Colors.white : c.textSecondary,
                )),
            ),
          ),
        )).toList(),
      ),
    );
  }
}
