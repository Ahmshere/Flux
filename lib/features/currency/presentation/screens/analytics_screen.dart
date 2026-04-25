import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';
import '../state/analytics_notifier.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});
  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
  int _selectedDays = 7;
  static const _dayOptions = [7, 14, 30];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _load());
  }

  void _load() {
    final state = ref.read(currencyProvider);
    final from  = state.fromRate?.code ?? 'USD';
    final to    = state.toRate?.code   ?? 'EUR';
    ref.read(analyticsProvider.notifier).load(
      fromCode: from, toCode: to, days: _selectedDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.appColors;
    final s       = ref.watch(stringsProvider);
    final state   = ref.watch(currencyProvider);
    final an      = ref.watch(analyticsProvider);
    final from    = state.fromRate;
    final to      = state.toRate;

    return Column(children: [
      // ── Пара + период ────────────────────────────────────────────────────
      Row(children: [
        Expanded(
          child: Text(
            from != null && to != null
                ? '${from.flag} ${from.code}  /  ${to.flag} ${to.code}'
                : '—',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: c.textPrimary),
          ),
        ),
        // Переключатель периода
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border),
          ),
          child: Row(
            children: _dayOptions.map((d) {
              final active = d == _selectedDays;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDays = d);
                  _load();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text('${d}d',
                    style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: active ? Colors.white : c.textSecondary,
                    )),
                ),
              );
            }).toList(),
          ),
        ),
      ]),
      const Gap(16),

      // ── Большой график ────────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: an.isLoading
            ? SizedBox(height: 180,
                child: Center(child: CircularProgressIndicator(
                    color: AppTheme.accent, strokeWidth: 2)))
            : an.data.isEmpty
                ? SizedBox(height: 180,
                    child: Center(child: Text(s.chartLoading,
                        style: TextStyle(color: c.textSecondary))))
                : _BigChart(data: an.data),
      ),
      const Gap(12),

      // ── Stat cards ────────────────────────────────────────────────────────
      if (an.data.isNotEmpty) _StatsGrid(data: an.data, toCode: to?.code ?? ''),
      const Gap(12),

      // ── Тренд / волатильность ─────────────────────────────────────────────
      if (an.data.isNotEmpty) _InsightCard(data: an.data),
    ]);
  }
}

// ── Большой график ────────────────────────────────────────────────────────────
class _BigChart extends StatelessWidget {
  final List<double> data;
  const _BigChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
        data.length, (i) => FlSpot(i.toDouble(), data[i]));
    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final pad  = (maxY - minY) * 0.15;

    return SizedBox(
      height: 180,
      child: LineChart(LineChartData(
        minY: minY - pad,
        maxY: maxY + pad,
        gridData: FlGridData(
          show: true,
          horizontalInterval: (maxY - minY) / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withOpacity(0.04), strokeWidth: 1),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              getTitlesWidget: (v, _) => Text(
                _fmtRate(v),
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.white.withOpacity(0.35),
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (data.length / 4).ceilToDouble(),
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                final daysAgo = data.length - 1 - i;
                return Text(
                  daysAgo == 0 ? 'now' : '-${daysAgo}d',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.35),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => spots.map((s) =>
              LineTooltipItem(_fmtRate(s.y),
                const TextStyle(color: Colors.white, fontSize: 11,
                    fontFamily: 'monospace', fontWeight: FontWeight.w600)),
            ).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppTheme.accent,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (s, _) => s.x == data.length - 1,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4, color: AppTheme.accent,
                strokeWidth: 2, strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [AppTheme.accent.withOpacity(0.2),
                         AppTheme.accent.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      )),
    );
  }

  static String _fmtRate(double v) {
    if (v < 0.01)  return v.toStringAsFixed(5);
    if (v < 1)     return v.toStringAsFixed(4);
    if (v < 100)   return v.toStringAsFixed(3);
    return v.toStringAsFixed(2);
  }
}

// ── Stat grid ─────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final List<double> data;
  final String toCode;
  const _StatsGrid({required this.data, required this.toCode});

  @override
  Widget build(BuildContext context) {
    final min   = data.reduce((a, b) => a < b ? a : b);
    final max   = data.reduce((a, b) => a > b ? a : b);
    final avg   = data.fold(0.0, (s, v) => s + v) / data.length;
    final chg   = (data.last - data.first) / data.first * 100;
    final isUp  = chg >= 0;

    return Row(children: [
      _StatCard(label: 'Min', value: _f(min), color: AppTheme.red),
      const Gap(8),
      _StatCard(label: 'Max', value: _f(max), color: AppTheme.green),
      const Gap(8),
      _StatCard(label: 'Avg', value: _f(avg),
          color: context.appColors.textPrimary),
      const Gap(8),
      _StatCard(
        label: 'Change',
        value: '${isUp ? '+' : ''}${chg.toStringAsFixed(2)}%',
        color: isUp ? AppTheme.green : AppTheme.red,
      ),
    ]);
  }

  String _f(double v) {
    if (v < 0.001) return v.toStringAsFixed(6);
    if (v < 1)     return v.toStringAsFixed(4);
    return v.toStringAsFixed(3);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value,
      required this.color});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(
              fontSize: 9, color: c.textSecondary,
              fontWeight: FontWeight.w600, letterSpacing: 0.05)),
          const Gap(4),
          Text(value, style: TextStyle(
              fontSize: 12, color: color,
              fontWeight: FontWeight.w700, fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

// ── Insight card ──────────────────────────────────────────────────────────────
class _InsightCard extends StatelessWidget {
  final List<double> data;
  const _InsightCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final c   = context.appColors;
    final chg = (data.last - data.first) / data.first * 100;
    final isUp = chg >= 0;

    // Волатильность = среднее отклонение от среднего
    final avg  = data.fold(0.0, (s, v) => s + v) / data.length;
    final vol  = data.map((v) => (v - avg).abs()).fold(0.0, (s, v) => s + v)
                 / data.length / avg * 100;
    final volLabel = vol < 0.5 ? 'Low 🟢' : vol < 1.5 ? 'Medium 🟡' : 'High 🔴';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Insights', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: c.textSecondary, letterSpacing: 0.08)),
        const Gap(10),
        _InsightRow(
          icon: isUp ? '📈' : '📉',
          label: 'Trend',
          value: isUp
              ? 'Rising +${chg.abs().toStringAsFixed(2)}%'
              : 'Falling −${chg.abs().toStringAsFixed(2)}%',
          color: isUp ? AppTheme.green : AppTheme.red,
        ),
        const Gap(8),
        _InsightRow(
          icon: '〰️',
          label: 'Volatility',
          value: volLabel,
          color: c.textPrimary,
        ),
        const Gap(8),
        _InsightRow(
          icon: '🕐',
          label: 'Best time to exchange',
          value: isUp ? 'Exchange now' : 'Consider waiting',
          color: isUp ? AppTheme.green : AppTheme.amber,
        ),
      ]),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _InsightRow({required this.icon, required this.label,
      required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const Gap(10),
      Expanded(child: Text(label,
          style: TextStyle(fontSize: 13, color: c.textSecondary))),
      Text(value, style: TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: color)),
    ]);
  }
}
