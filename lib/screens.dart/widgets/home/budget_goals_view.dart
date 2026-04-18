import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BudgetGoalsView extends StatelessWidget {
  const BudgetGoalsView({
    super.key,
    required this.isDark,
    required this.expenseByCategory,
    required this.budgetGoals,
    required this.alertAnimation,
    required this.goalColor,
    required this.moneyFormatter,
  });

  final bool isDark;
  final Map<String, double> expenseByCategory;
  final Map<String, double> budgetGoals;
  final Animation<double> alertAnimation;
  final Color Function(double ratio) goalColor;
  final String Function(double amount) moneyFormatter;

  @override
  Widget build(BuildContext context) {
    final exceededCount = budgetGoals.entries
        .where((entry) => (expenseByCategory[entry.key] ?? 0) > entry.value)
        .length;

    return ListView(
      key: const ValueKey<String>('goals'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: <Widget>[
        Text(
          'Budget Goals',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFEAF8FF) : const Color(0xFF0E2453),
          ),
        ),
        const SizedBox(height: 8),
        if (exceededCount > 0)
          ScaleTransition(
            scale: alertAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFFF3D00).withValues(alpha: 0.2),
                border: Border.all(color: const Color(0xFFFF3D00)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF3D00),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You exceeded $exceededCount budget goal(s). Rebalance this week.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ...budgetGoals.entries.map((entry) {
          final value = expenseByCategory[entry.key] ?? 0;
          final ratio = entry.value == 0 ? 0.0 : value / entry.value;
          final color = goalColor(ratio);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.92),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    Text(
                      '${moneyFormatter(value)} / ${moneyFormatter(entry.value)}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: ratio.clamp(0, 1).toDouble(),
                  ),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, progress, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        minHeight: 11,
                        value: progress,
                        color: color,
                        backgroundColor: Colors.white.withValues(
                          alpha: isDark ? 0.18 : 0.7,
                        ),
                      ),
                    );
                  },
                ),
                if (ratio > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Limit exceeded by ${moneyFormatter(value - entry.value)}',
                      style: const TextStyle(
                        color: Color(0xFFFF3D00),
                        fontWeight: FontWeight.w700,
                      ),
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
