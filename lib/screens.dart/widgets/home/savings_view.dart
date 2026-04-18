import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_budget_tracker/model/savinggoalmodel.dart';

class SavingsView extends StatelessWidget {
  const SavingsView({
    super.key,
    required this.isDark,
    required this.goals,
    required this.moneyFormatter,
    required this.goalColor,
    required this.savingTips,
  });

  final bool isDark;
  final List<SavingGoal> goals;
  final String Function(double amount) moneyFormatter;
  final Color Function(double ratio) goalColor;
  final List<(String, String, IconData)> savingTips;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey<String>('saving_goals'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: <Widget>[
        Text(
          'Savings Tips & Goals',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFFEAF8FF) : const Color(0xFF0E2453),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.92),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.auto_awesome_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'AI Saving Coach',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...savingTips.map((tip) {
                final (title, body, icon) = tip;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: isDark
                            ? <Color>[
                                const Color(0xFF18345A),
                                const Color(0xFF102A4A),
                              ]
                            : <Color>[
                                const Color(0xFFE7F2FF),
                                const Color(0xFFDDF0FF),
                              ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(icon, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                body,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFFBDE6FF)
                                      : const Color(0xFF48688F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...goals.map((goal) {
          final progress = goal.progress.clamp(0.0, 1.0);
          final remaining = (goal.targetAmount - goal.savedAmount).clamp(
            0.0,
            double.infinity,
          );

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
                    Expanded(
                      child: Text(
                        goal.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      '${moneyFormatter(goal.savedAmount)} / ${moneyFormatter(goal.targetAmount)}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    minHeight: 11,
                    value: progress,
                    color: goalColor(progress),
                    backgroundColor: Colors.white.withValues(
                      alpha: isDark ? 0.18 : 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${moneyFormatter(remaining)}',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF9EDBFF)
                        : const Color(0xFF5875A8),
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
