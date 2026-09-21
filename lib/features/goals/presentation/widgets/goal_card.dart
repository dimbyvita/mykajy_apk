import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/goal.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final String symbol;
  final VoidCallback? onAddSavings;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.symbol,
    this.onAddSavings,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fmt = NumberFormat('#,##0.00', 'fr');
    final pct = goal.progressPercent;
    final isComplete = goal.isCompleted;

    Color statusColor;
    String statusLabel;
    if (isComplete) {
      statusColor = const Color(0xFF1EAD6F);
      statusLabel = '✅ Atteint';
    } else if (goal.isOverdue) {
      statusColor = const Color(0xFFE8561A);
      statusLabel = '⚠️ En retard';
    } else {
      statusColor = primary;
      statusLabel = '${goal.daysLeft}j restants';
    }

    return Dismissible(
      key: Key(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A3048)
                : const Color(0xFFE4E9F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(goal.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isComplete)
                  IconButton(
                    onPressed: onAddSavings,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: primary, size: 18),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: primary.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isComplete ? const Color(0xFF1EAD6F) : primary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$symbol ${fmt.format(goal.savedAmount)} épargnés',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
                Text(
                  '${(pct * 100).toStringAsFixed(0)}% / $symbol ${fmt.format(goal.targetAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isComplete
                        ? const Color(0xFF1EAD6F)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// TODO Implement this library.