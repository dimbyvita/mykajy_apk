import 'package:get/get.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';

enum AnalyticsPeriod { weekly, monthly, annual }

/// One data point on the cash-flow curve
class FlowPoint {
  final DateTime date;
  final double balance; // cumulative balance at that date

  const FlowPoint({required this.date, required this.balance});
}

/// Bar-chart bucket (income vs expense for a given label)
class PeriodBucket {
  final String label;
  final double income;
  final double expense;

  const PeriodBucket({
    required this.label,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;
}

class AnalyticsController extends GetxController {
  final TransactionController _txCtrl;
  AnalyticsController({required TransactionController txCtrl})
      : _txCtrl = txCtrl;

  final period = AnalyticsPeriod.monthly.obs;

  // ── Derived lists (recomputed when period or transactions change) ──
  List<PeriodBucket> get buckets => _buildBuckets(_txCtrl.transactions);
  List<FlowPoint> get flowPoints => _buildFlow(_txCtrl.transactions);

  // ── Summary for selected period ────────────────────────────────────
  double get periodIncome =>
      buckets.fold(0.0, (s, b) => s + b.income);
  double get periodExpense =>
      buckets.fold(0.0, (s, b) => s + b.expense);
  double get periodNet => periodIncome - periodExpense;

  void setPeriod(AnalyticsPeriod p) => period.value = p;

  // ── Buckets builder ────────────────────────────────────────────────
  List<PeriodBucket> _buildBuckets(List<Transaction> all) {
    final now = DateTime.now();
    switch (period.value) {
      case AnalyticsPeriod.weekly:
        return _weeklyBuckets(all, now);
      case AnalyticsPeriod.monthly:
        return _monthlyBuckets(all, now);
      case AnalyticsPeriod.annual:
        return _annualBuckets(all, now);
    }
  }

  /// Last 7 days, one bucket per day
  List<PeriodBucket> _weeklyBuckets(List<Transaction> all, DateTime now) {
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    // Map by weekday index
    return List.generate(7, (i) {
      final day = days[i];
      final txs = all.where((t) {
        final td = DateTime(t.date.year, t.date.month, t.date.day);
        return td == day;
      });
      return PeriodBucket(
        label: labels[day.weekday - 1],
        income: txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount),
        expense:
            txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount),
      );
    });
  }

  /// Last 6 months, one bucket per month
  List<PeriodBucket> _monthlyBuckets(List<Transaction> all, DateTime now) {
    const monthLabels = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return List.generate(6, (i) {
      final offset = 5 - i;
      final target = DateTime(now.year, now.month - offset, 1);
      final m = ((target.month - 1) % 12 + 12) % 12;
      final y = target.year + (target.month <= 0 ? -1 : 0);
      final txs = all.where((t) => t.date.month == target.month &&
          t.date.year == target.year);
      return PeriodBucket(
        label: monthLabels[m],
        income: txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount),
        expense:
            txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount),
      );
    });
  }

  /// Last 12 months grouped by month (annual view)
  List<PeriodBucket> _annualBuckets(List<Transaction> all, DateTime now) {
    const monthLabels = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return List.generate(12, (i) {
      final offset = 11 - i;
      // Compute target month
      int month = now.month - offset;
      int year = now.year;
      while (month <= 0) { month += 12; year -= 1; }
      final txs = all.where((t) => t.date.month == month && t.date.year == year);
      return PeriodBucket(
        label: monthLabels[month - 1],
        income: txs.where((t) => t.isIncome).fold(0.0, (s, t) => s + t.amount),
        expense:
            txs.where((t) => t.isExpense).fold(0.0, (s, t) => s + t.amount),
      );
    });
  }

  // ── Cash-flow curve (cumulative balance over time) ─────────────────
  List<FlowPoint> _buildFlow(List<Transaction> all) {
    if (all.isEmpty) return [];

    final sorted = [...all]..sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();

    // Range depending on period
    DateTime start;
    switch (period.value) {
      case AnalyticsPeriod.weekly:
        start = now.subtract(const Duration(days: 6));
        break;
      case AnalyticsPeriod.monthly:
        start = DateTime(now.year, now.month, 1);
        break;
      case AnalyticsPeriod.annual:
        start = DateTime(now.year, 1, 1);
        break;
    }

    // Compute starting balance (all transactions before range)
    double runningBalance = sorted
        .where((t) => t.date.isBefore(start))
        .fold(0.0, (s, t) => t.isIncome ? s + t.amount : s - t.amount);

    // Build daily points in range
    final inRange =
        sorted.where((t) => !t.date.isBefore(start)).toList();

    final Map<DateTime, double> dailyNet = {};
    for (final t in inRange) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      dailyNet[day] =
          (dailyNet[day] ?? 0) + (t.isIncome ? t.amount : -t.amount);
    }

    // Fill every day from start to now
    final points = <FlowPoint>[];
    var cursor = DateTime(start.year, start.month, start.day);
    while (!cursor.isAfter(DateTime(now.year, now.month, now.day))) {
      runningBalance += dailyNet[cursor] ?? 0;
      points.add(FlowPoint(date: cursor, balance: runningBalance));
      cursor = cursor.add(const Duration(days: 1));
    }

    return points;
  }
}
// TODO Implement this library.