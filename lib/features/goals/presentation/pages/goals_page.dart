import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../onboarding/data/onboarding_datasource.dart';
import '../controllers/goal_controller.dart';
import '../widgets/goal_card.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GoalController>();
    final prefs = Get.find<OnboardingDatasource>();
    final symbol = prefs.currencySymbol;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Mes Objectifs',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => _showAddGoalSheet(context, ctrl, symbol),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nouveau'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary strip
            Obx(() => _SummaryStrip(
                  totalSaved: ctrl.totalSaved,
                  totalTarget: ctrl.totalTarget,
                  activeCount: ctrl.activeGoals.length,
                  completedCount: ctrl.completedGoals.length,
                  symbol: symbol,
                )),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: Obx(() {
                if (ctrl.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (ctrl.goals.isEmpty) {
                  return _EmptyGoals();
                }
                return RefreshIndicator(
                  onRefresh: ctrl.loadGoals,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: ctrl.goals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final goal = ctrl.goals[i];
                      return GoalCard(
                        goal: goal,
                        symbol: symbol,
                        onDelete: () => ctrl.deleteGoal(goal.id),
                        onAddSavings: () =>
                            _showAddSavingsSheet(context, ctrl, goal.id, symbol),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalSheet(
      BuildContext context, GoalController ctrl, String symbol) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final selectedEmoji = '🎯'.obs;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    final emojis = ['🎯', '🏠', '✈️', '🚗', '📱', '💍', '🎓', '💻', '🏖️', '🎸'];

    Get.bottomSheet(
      StatefulBuilder(builder: (ctx, setState) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 28,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('Nouvel objectif',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),

                // Emoji picker
                Text('Icône',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.45))),
                const SizedBox(height: 8),
                Obx(() => Wrap(
                      spacing: 8,
                      children: emojis.map((e) {
                        final sel = selectedEmoji.value == e;
                        return GestureDetector(
                          onTap: () => selectedEmoji.value = e,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: sel
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.15)
                                  : Theme.of(context).cardTheme.color,
                              border: Border.all(
                                color: sel
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFE4E9F0),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                                child: Text(e,
                                    style:
                                        const TextStyle(fontSize: 22))),
                          ),
                        );
                      }).toList(),
                    )),
                const SizedBox(height: 16),

                TextField(
                  controller: titleCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nom de l\'objectif'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Montant cible',
                      prefixText: '$symbol '),
                ),
                const SizedBox(height: 12),

                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE4E9F0),
                          width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).cardTheme.color,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.45)),
                        const SizedBox(width: 10),
                        Text(
                          'Date limite : ${DateFormat('d MMM yyyy', 'fr').format(selectedDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final title = titleCtrl.text.trim();
                      final amount = double.tryParse(
                          amountCtrl.text.trim().replaceAll(',', '.'));
                      if (title.isEmpty || amount == null || amount <= 0) return;
                      await ctrl.addGoal(
                        title: title,
                        emoji: selectedEmoji.value,
                        targetAmount: amount,
                        deadline: selectedDate,
                      );
                      Get.back();
                    },
                    child: const Text('Créer l\'objectif'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  void _showAddSavingsSheet(BuildContext context, GoalController ctrl,
      String goalId, String symbol) {
    final amountCtrl = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter une épargne',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: 'Montant', prefixText: '$symbol '),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(
                      amountCtrl.text.trim().replaceAll(',', '.'));
                  if (amount == null || amount <= 0) return;
                  await ctrl.addSavings(goalId, amount);
                  Get.back();
                },
                child: const Text('Ajouter'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final double totalSaved;
  final double totalTarget;
  final int activeCount;
  final int completedCount;
  final String symbol;

  const _SummaryStrip({
    required this.totalSaved,
    required this.totalTarget,
    required this.activeCount,
    required this.completedCount,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0', 'fr');
    final pct = totalTarget == 0
        ? 0.0
        : (totalSaved / totalTarget).clamp(0.0, 1.0);
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total épargné',
                        style: TextStyle(color: Colors.white60, fontSize: 12)),
                    Text(
                      '$symbol ${fmt.format(totalSaved)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              _StatBadge(label: 'Actifs', value: '$activeCount'),
              const SizedBox(width: 8),
              _StatBadge(
                  label: 'Complétés',
                  value: '$completedCount',
                  color: const Color(0xFF4AE89C)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4AE89C)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(pct * 100).toStringAsFixed(0)}% de $symbol ${fmt.format(totalTarget)} atteint',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎯', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          Text(
            'Aucun objectif pour l\'instant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Appuyez sur "Nouveau" pour en créer un',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
// TODO Implement this library.