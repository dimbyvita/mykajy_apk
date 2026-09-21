import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction.dart';
import '../controllers/transaction_controller.dart';
import '../widgets/transaction_tile.dart';
import '../../../onboarding/data/onboarding_datasource.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<TransactionController>();
    final prefs = Get.find<OnboardingDatasource>();

    final symbol = prefs.currencySymbol;
    final firstName = prefs.firstName.isEmpty ? 'vous' : prefs.firstName;
    final avatarDisplay = prefs.avatarEmoji.isNotEmpty
        ? prefs.avatarEmoji
        : (prefs.firstName.isNotEmpty ? prefs.firstName[0].toUpperCase() : '?');

    String fmt(double v) =>
        '$symbol ${NumberFormat('#,##0.00', 'fr').format(v)}';

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: ctrl.loadData,
            child: CustomScrollView(
              slivers: [
                // ── Header ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontFamily: 'Inter',
                            ),
                            children: [
                              const TextSpan(text: 'Money'),
                              TextSpan(
                                text: 'Track',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        _AvatarButton(display: avatarDisplay),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Greeting
                      Text(
                        'Bonjour, $firstName 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ── Balance card ─────────────────────────────────
                      Obx(() => _BalanceCard(
                            balance: fmt(ctrl.totalBalance.value),
                            expenses: fmt(ctrl.totalExpenses.value),
                            income: fmt(ctrl.totalIncome.value),
                          )),
                      const SizedBox(height: 26),

                      // ── Donut chart ──────────────────────────────────
                      if (ctrl.transactions.isNotEmpty) ...[
                        Text(
                          'Répartition du mois',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        _DonutCard(
                            transactions: ctrl.transactions, symbol: symbol),
                        const SizedBox(height: 26),
                      ],

                      // ── Transactions header ──────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions Récentes',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Tout voir'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ]),
                  ),
                ),

                // ── Transaction list ─────────────────────────────────
                ctrl.transactions.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyState(),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final tx = ctrl.recentTransactions[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: TransactionTile(
                                  transaction: tx,
                                  onDelete: () =>
                                      ctrl.deleteTransaction(tx.id),
                                ),
                              );
                            },
                            childCount: ctrl.recentTransactions.length,
                          ),
                        ),
                      ),
              ],
            ),
          );
        }),
      ),
      bottomNavigationBar: const _BottomNav(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context, ctrl),
        backgroundColor: const Color(0xFF1EAD6F),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ── Add-transaction bottom sheet ─────────────────────────────────────
  void _showAddSheet(BuildContext context, TransactionController ctrl) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final typeObs = TransactionType.expense.obs;

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
              Text(
                'Nouvelle transaction',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              Obx(() => SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Dépense'),
                        icon: Icon(Icons.arrow_upward_rounded),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Revenu'),
                        icon: Icon(Icons.arrow_downward_rounded),
                      ),
                    ],
                    selected: {typeObs.value},
                    onSelectionChanged: (s) => typeObs.value = s.first,
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Titre', prefixIcon: Icon(Icons.edit_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Montant',
                    prefixIcon: Icon(Icons.attach_money)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryCtrl,
                decoration: const InputDecoration(
                    labelText: 'Catégorie (optionnel)',
                    prefixIcon: Icon(Icons.label_outline)),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final amount =
                        double.tryParse(amountCtrl.text.trim().replaceAll(',', '.'));
                    if (title.isEmpty || amount == null || amount <= 0) return;
                    await ctrl.addTransaction(
                      title: title,
                      amount: amount,
                      type: typeObs.value,
                      date: DateTime.now(),
                      category: categoryCtrl.text.trim().isEmpty
                          ? null
                          : categoryCtrl.text.trim(),
                    );
                    Get.back();
                  },
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Balance card ───────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final String balance;
  final String expenses;
  final String income;

  const _BalanceCard({
    required this.balance,
    required this.expenses,
    required this.income,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, primary.withOpacity(0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solde Actuel',
              style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 6),
          Text(balance,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _Chip(
                  label: 'Dépenses Mensuelles',
                  value: '−$expenses',
                  icon: Icons.arrow_upward_rounded,
                  color: const Color(0xFFFF6B4A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Chip(
                  label: 'Revenus Mensuels',
                  value: '+$income',
                  icon: Icons.arrow_downward_rounded,
                  color: const Color(0xFF4AE89C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _Chip(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: color.withOpacity(0.22), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.white60, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donut card ─────────────────────────────────────────────────────────
class _DonutCard extends StatelessWidget {
  final List<Transaction> transactions;
  final String symbol;
  const _DonutCard({required this.transactions, required this.symbol});

  static const _colors = [
    Color(0xFF1A2B5C),
    Color(0xFFE8561A),
    Color(0xFF1EAD6F),
    Color(0xFFF5A623),
    Color(0xFF8B5CF6),
  ];

  @override
  Widget build(BuildContext context) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final Map<String, double> byCategory = {};
    for (final t in expenses) {
      final cat = t.category ?? 'Autres';
      byCategory[cat] = (byCategory[cat] ?? 0) + t.amount;
    }
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final visible = entries.take(5).toList();
    final total = visible.fold(0.0, (s, e) => s + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A3048)
              : const Color(0xFFE4E9F0),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 38,
                sections: List.generate(visible.length, (i) {
                  final pct = visible[i].value / total * 100;
                  return PieChartSectionData(
                    color: _colors[i % _colors.length],
                    value: visible[i].value,
                    title: '${pct.toStringAsFixed(0)}%',
                    radius: 38,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(visible.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _colors[i % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          visible[i].key,
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.65),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '−${visible[i].value.toStringAsFixed(0)}$symbol',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64,
              color:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 14),
          Text(
            'Aucune transaction pour l\'instant',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Appuyez sur + pour en ajouter une',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar button ──────────────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  final String display;
  const _AvatarButton({required this.display});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            display,
            style: TextStyle(
              fontSize: display.length == 1 ? 18 : 20,
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom navigation ──────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
                icon: Icons.home_rounded, label: 'Accueil', active: true),
            _NavItem(
                icon: Icons.list_alt_rounded, label: 'Transactions'),
            const SizedBox(width: 56),
            _NavItem(
                icon: Icons.donut_large_rounded, label: 'Budget'),
            _NavItem(icon: Icons.person_rounded, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem(
      {required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withOpacity(0.38);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
// TODO Implement this library.