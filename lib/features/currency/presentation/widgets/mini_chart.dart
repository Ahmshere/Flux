import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/l10n/lang_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../state/currency_notifier.dart';

class MiniChart extends ConsumerWidget {
  const MiniChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c     = context.appColors;
    final s     = ref.watch(stringsProvider);
    final state = ref.watch(currencyProvider);
    final data  = state.chartData;
    final from  = state.fromRate;
    final to    = state.toRate;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.days7, style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: c.textSecondary, letterSpacing: 0.08,
              )),
              if (from != null && to != null)
                Text('${from.code} / ${to.code}', style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: c.textSecondary, fontFamily: 'monospace',
                )),
            ],
          ),
          const Gap(12),

          // Chart
          SizedBox(
            height: 100,
            child: data.isEmpty
                ? Center(child: Text(s.chartLoading,
                style: TextStyle(color: c.textSecondary, fontSize: 12)))
                : _buildChart(data),
          ),
          const Gap(12),

          // Stats
          if (data.isNotEmpty) _StatsRow(data: data, s: s),
        ],
      ),
    );
  }

  Widget _buildChart(List<double> data) {
    final spots = List.generate(
        data.length, (i) => FlSpot(i.toDouble(), data[i]));
    final minY = data.reduce((a, b) => a < b ? a : b);
    final maxY = data.reduce((a, b) => a > b ? a : b);
    final pad  = (maxY - minY) * 0.2;

    return LineChart(LineChartData(
      minY: minY - pad,
      maxY: maxY + pad,
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: const FlTitlesData(show: false),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (spots) => spots.map((s) => LineTooltipItem(
            s.y.toStringAsFixed(4),
            const TextStyle(color: Colors.white, fontSize: 11,
                fontFamily: 'monospace', fontWeight: FontWeight.w600),
          )).toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: AppTheme.accent,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, _) => spot.x == data.length - 1,
            getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
              radius: 4, color: AppTheme.accent,
              strokeWidth: 2, strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [
                AppTheme.accent.withOpacity(0.25),
                AppTheme.accent.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}

// ── Статистика под графиком ───────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<double> data;
  final dynamic s; // S из stringsProvider

  const _StatsRow({required this.data, required this.s});

  @override
  Widget build(BuildContext context) {
    final min  = data.reduce((a, b) => a < b ? a : b);
    final max  = data.reduce((a, b) => a > b ? a : b);
    final avg  = data.fold(0.0, (sum, v) => sum + v) / data.length;
    final chg  = (data.last - data.first) / data.first * 100;

    return Row(children: [
      _StatCell(label: s.statMin, value: _fmt(min), color: AppTheme.red),
      _StatCell(label: s.statMax, value: _fmt(max), color: AppTheme.green),
      _StatCell(label: s.statAvg, value: _fmt(avg),
          color: context.appColors.textPrimary),
      _StatCell(
        label: s.stat7d,
        value: '${chg >= 0 ? '+' : ''}${chg.toStringAsFixed(2)}%',
        color: chg >= 0 ? AppTheme.green : AppTheme.red,
      ),
    ]);
  }

  String _fmt(double v) {
    if (v < 0.001) return v.toStringAsFixed(6);
    if (v < 1)     return v.toStringAsFixed(4);
    return v.toStringAsFixed(2);
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCell({required this.label, required this.value,
    required this.color});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(label, style: TextStyle(
            fontSize: 9, color: c.textSecondary,
            fontWeight: FontWeight.w600, letterSpacing: 0.05,
          )),
          const Gap(3),
          Text(value, style: TextStyle(
            fontSize: 11, color: color,
            fontWeight: FontWeight.w600, fontFamily: 'monospace',
          ), overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}