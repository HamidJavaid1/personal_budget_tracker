import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_budget_tracker/model/catagoryconifig.dart';
import 'package:personal_budget_tracker/model/transaction.dart';

class TransactionsView extends StatelessWidget {
  const TransactionsView({
    super.key,
    required this.isDark,
    required this.transactions,
    required this.categories,
    required this.moneyFormatter,
  });

  final bool isDark;
  final List<TransactionModel> transactions;
  final List<CategoryConfig> categories;
  final String Function(double amount) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final sorted = <TransactionModel>[
      ...transactions,
    ]..sort((a, b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return ListView(
      key: const ValueKey<String>('activity'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: <Widget>[
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFEAF8FF) : const Color(0xFF0E2453),
          ),
        ),
        const SizedBox(height: 12),
        if (sorted.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.9),
            ),
            child: const Text(
              'No entries yet. Tap Add to create your first item.',
            ),
          ),
        ...sorted.map((tx) {
          final category = categories.firstWhere(
            (c) => c.name == tx.category,
            orElse: () => const CategoryConfig(
              'Other',
              Icons.category_rounded,
              Color(0xFF42A5F5),
            ),
          );
          final isIncome = tx.type.toLowerCase() == 'income';

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.95),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tx.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${tx.category} • ${DateFormat.MMMd().format(DateTime.parse(tx.date))}',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF9EDBFF)
                              : const Color(0xFF5875A8),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isIncome ? '+' : '-'}${moneyFormatter(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isIncome
                        ? const Color(0xFF00C27A)
                        : const Color(0xFFFF5B7F),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
