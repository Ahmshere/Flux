import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/nlp/natural_parser.dart';
import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';

class NaturalInputWidget extends ConsumerStatefulWidget {
  const NaturalInputWidget({super.key});

  @override
  ConsumerState<NaturalInputWidget> createState() =>
      _NaturalInputWidgetState();
}

class _NaturalInputWidgetState extends ConsumerState<NaturalInputWidget> {
  final _controller = TextEditingController();
  bool _parsed = false;

  static const _suggestions = [
    '100 usd to ils',
    '50 eur in btc',
    '1000 rub to usd',
    '1 btc in eur',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final result = NaturalInputParser.parse(value);
    if (result != null) {
      final rates = ref.read(currencyProvider).rates;
      final from = rates.where((r) => r.code == result.fromCode).firstOrNull;
      final to   = rates.where((r) => r.code == result.toCode).firstOrNull;
      if (from != null && to != null) {
        final n = ref.read(currencyProvider.notifier);
        n.setFromRate(from);
        n.setToRate(to);
        n.setAmount(result.amount);
        setState(() => _parsed = true);
        return;
      }
    }
    setState(() => _parsed = false);
  }

  void _fill(String suggestion) {
    _controller.text = suggestion;
    _onChanged(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final s = ref.watch(stringsProvider);

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _parsed ? AppTheme.accent : c.border,
          width: _parsed ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(children: [
            Text(
              s.smartInput,
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: c.textSecondary, letterSpacing: 0.06,
              ),
            ),
            if (_parsed) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  s.recognized,
                  style: const TextStyle(
                    fontSize: 10, color: AppTheme.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ]),
          const Gap(8),

          // Input field
          TextField(
            controller: _controller,
            onChanged: _onChanged,
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600,
              color: c.textPrimary, letterSpacing: -0.3,
            ),
            decoration: InputDecoration(
              hintText: s.smartInputHint,
              hintStyle: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w400,
                color: c.textSecondary,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const Gap(10),

          // Suggestion chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => _fill(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: c.surface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.border),
                    ),
                    child: Text(s,
                      style: TextStyle(
                        fontSize: 12, color: c.textSecondary,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}