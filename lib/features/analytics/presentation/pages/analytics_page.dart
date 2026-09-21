import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../onboarding/data/onboarding_datasource.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalyticsController>();
    final prefs = Get.find<OnboardingDatasource>();
    final symbol = prefs.currencySymbol;
    final fmt = NumberFormat('#,##0.00', 'fr');
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────────────────
              Text(
                'Analytiques',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 20),

              // ── Period toggle ──────────────────────────────────────
              Obx(
                () => _PeriodToggle(
                  selected: ctrl.period.value,
                  onChanged: ctrl.setPeriod,
                ),
              ),
              const SizedBox(height: 20),

              // ── Summary cards ──────────────────────────────────────
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Revenus',
                        value: '$symbol ${fmt.format(ctrl.periodIncome)}',
                        icon: Icons.arrow_downward_rounded,
                        color: const Color(0xFF1EAD6F),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Dépenses',
                        value: '$symbol ${fmt.format(ctrl.periodExpense)}',
                        icon: Icons.arrow_upward_rounded,
                        color: const Color(0xFFE8561A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Net',
                        value:
                            '${ctrl.periodNet >= 0 ? '+' : ''}$symbol ${fmt.format(ctrl.periodNet)}',
                        icon: Icons.account_balance_wallet_outlined,
                        color: ctrl.periodNet >= 0
                            ? const Color(0xFF1EAD6F)
                            : const Color(0xFFE8561A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Bar chart ──────────────────────────────────────────
              Text(
                'Évolution des transactions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Revenus (vert) vs Dépenses (orange)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.45),
                ),
              ),
              const SizedBox(height: 14),

              Obx(
                () => _BarChartCard(
                  buckets: ctrl.buckets,
                  symbol: symbol,
                ),
              ),

              const SizedBox(height: 28),

              // ── Line chart ─────────────────────────────────────────
              Text(
                'Flux monétaire',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Évolution du solde dans le temps',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.45),
                ),
              ),
              const SizedBox(height: 14),

              Obx(
                () => _LineChartCard(
                  points: ctrl.flowPoints,
                  symbol: symbol,
                  period: ctrl.period.value,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Period toggle ──────────────────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  final AnalyticsPeriod selected;
  final void Function(AnalyticsPeriod) onChanged;

  const _PeriodToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AnalyticsPeriod>(
      segments: const [
        ButtonSegment(
          value: AnalyticsPeriod.weekly,
          label: Text('Semaine'),
        ),
        ButtonSegment(
          value: AnalyticsPeriod.monthly,
          label: Text('Mois'),
        ),
        ButtonSegment(
          value: AnalyticsPeriod.annual,
          label: Text('Année'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
      style: SegmentedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Bar chart ──────────────────────────────────────────────────────────

class _BarChartCard extends StatelessWidget {
  final List<PeriodBucket> buckets;
  final String symbol;

  const _BarChartCard({
    required this.buckets,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return const _EmptyChart();
    }

    final maxY = buckets.fold(
          0.0,
          (m, b) => b.income > m
              ? b.income
              : (b.expense > m ? b.expense : m),
        ) *
        1.25;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A3048)
              : const Color(0xFFE4E9F0),
        ),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 100 : maxY,

          // ── Tooltip ───────────────────────────────────────────────
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  Theme.of(context).colorScheme.surface,

              getTooltipItem: (group, gi, rod, ri) {
                final index = group.x.toInt();

                if (index < 0 || index >= buckets.length) {
                  return null;
                }

                final b = buckets[index];

                return BarTooltipItem(
                  ri == 0
                      ? '▲ $symbol ${b.income.toStringAsFixed(0)}'
                      : '▼ $symbol ${b.expense.toStringAsFixed(0)}',
                  TextStyle(
                    fontSize: 11,
                    color: ri == 0
                        ? const Color(0xFF1EAD6F)
                        : const Color(0xFFE8561A),
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),

          // ── Titles ────────────────────────────────────────────────
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  v == 0
                      ? ''
                      : '${(v / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();

                  if (i < 0 || i >= buckets.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      buckets[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),

          // ── Grid ──────────────────────────────────────────────────
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.07),
              strokeWidth: 1,
            ),
          ),

          borderData: FlBorderData(
            show: false,
          ),

          // ── Bars ─────────────────────────────────────────────────
          barGroups: List.generate(
            buckets.length,
            (i) {
              final b = buckets[i];

              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: b.income,
                    color: const Color(0xFF1EAD6F),
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: b.expense,
                    color: const Color(0xFFE8561A),
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
                barsSpace: 4,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Line chart ─────────────────────────────────────────────────────────

class _LineChartCard extends StatelessWidget {
  final List<FlowPoint> points;
  final String symbol;
  final AnalyticsPeriod period;

  const _LineChartCard({
    required this.points,
    required this.symbol,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyChart();
    }

    final primary = Theme.of(context).colorScheme.primary;

    final minY = points.fold(
      double.infinity,
      (m, p) => p.balance < m ? p.balance : m,
    );

    final maxY = points.fold(
      -double.infinity,
      (m, p) => p.balance > m ? p.balance : m,
    );

    final padding = (maxY - minY) * 0.2;

    final safeMin = minY - padding;

    final safeMax =
        maxY + padding == safeMin ? safeMin + 100 : maxY + padding;

    // ── Decide label interval ──────────────────────────────────────

    int labelEvery;

    switch (period) {
      case AnalyticsPeriod.weekly:
        labelEvery = 1;
        break;

      case AnalyticsPeriod.monthly:
        labelEvery = 5;
        break;

      case AnalyticsPeriod.annual:
        labelEvery = 30;
        break;
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A3048)
              : const Color(0xFFE4E9F0),
        ),
      ),
      child: LineChart(
        LineChartData(
          minY: safeMin,
          maxY: safeMax,

          clipData: const FlClipData.all(),

          // ── Tooltip ───────────────────────────────────────────────
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  Theme.of(context).colorScheme.surface,

              getTooltipItems: (spots) {
                return spots.map((s) {
                  final idx = s.x
                      .toInt()
                      .clamp(0, points.length - 1);

                  final p = points[idx];

                  final label =
                      period == AnalyticsPeriod.weekly
                          ? DateFormat('E d', 'fr').format(p.date)
                          : DateFormat('d MMM', 'fr').format(p.date);

                  return LineTooltipItem(
                    '$label\n'
                    '$symbol '
                    '${NumberFormat('#,##0', 'fr').format(p.balance)}',
                    TextStyle(
                      fontSize: 11,
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList();
              },
            ),
          ),

          // ── Titles ────────────────────────────────────────────────
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46,
                getTitlesWidget: (v, _) => Text(
                  '${(v / 1000).toStringAsFixed(0)}k',
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.4),
                  ),
                ),
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: labelEvery.toDouble(),
                getTitlesWidget: (v, _) {
                  final i = v.toInt();

                  if (i < 0 || i >= points.length) {
                    return const SizedBox();
                  }

                  final d = points[i].date;

                  final label =
                      period == AnalyticsPeriod.weekly
                          ? DateFormat('E', 'fr').format(d)
                          : period == AnalyticsPeriod.monthly
                              ? '${d.day}'
                              : DateFormat('MMM', 'fr').format(d);

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.45),
                      ),
                    ),
                  );
                },
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),

          // ── Grid ──────────────────────────────────────────────────
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.07),
              strokeWidth: 1,
            ),
          ),

          borderData: FlBorderData(
            show: false,
          ),

          // ── Line ──────────────────────────────────────────────────
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                points.length,
                (i) => FlSpot(
                  i.toDouble(),
                  points[i].balance,
                ),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: primary,
              barWidth: 2.5,
              isStrokeCapRound: true,

              dotData: const FlDotData(
                show: false,
              ),

              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary.withOpacity(0.2),
                    primary.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty chart ────────────────────────────────────────────────────────

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A3048)
              : const Color(0xFFE4E9F0),
        ),
      ),
      child: Center(
        child: Text(
          'Ajoutez des transactions pour voir les graphiques',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.35),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}