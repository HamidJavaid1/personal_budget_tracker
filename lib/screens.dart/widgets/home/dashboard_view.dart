import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_budget_tracker/model/catagoryconifig.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.isDark,
    required this.onRefresh,
    required this.onOpenSettings,
    required this.onToggleTheme,
    required this.income,
    required this.expense,
    required this.balance,
    required this.moneyFormat,
    required this.expenseByCategory,
    required this.categories,
  });

  final bool isDark;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSettings;
  final VoidCallback onToggleTheme;
  final double income;
  final double expense;
  final double balance;
  final NumberFormat moneyFormat;
  final Map<String, double> expenseByCategory;
  final List<CategoryConfig> categories;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey<String>('dashboard'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'SmartBudget',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFFEAF8FF)
                            : const Color(0xFF0E2453),
                      ),
                    ),
                    Text(
                      'Design your money flow, beautifully.',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF98D6FF)
                            : const Color(0xFF4D689B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onOpenSettings,
                icon: const Icon(Icons.settings_rounded),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: onToggleTheme,
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _GlassBalanceCard(
            isDark: isDark,
            balance: balance,
            moneyFormat: moneyFormat,
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _StatCard(
                  title: 'Income',
                  value: moneyFormat.format(income),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF00C27A),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  title: 'Expense',
                  value: moneyFormat.format(expense),
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFFFF4D6D),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PieChartCard(
            categoryTotals: expenseByCategory,
            isDark: isDark,
            moneyFormat: moneyFormat,
            categories: categories,
          ),
        ],
      ),
    );
  }
}

class _GlassBalanceCard extends StatelessWidget {
  const _GlassBalanceCard({
    required this.isDark,
    required this.balance,
    required this.moneyFormat,
  });

  final bool isDark;
  final double balance;
  final NumberFormat moneyFormat;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? <Color>[
                      const Color(0xFF32DFFF).withValues(alpha: 0.25),
                      const Color(0xFF7F5CFF).withValues(alpha: 0.18),
                    ]
                  : <Color>[
                      Colors.white.withValues(alpha: 0.68),
                      const Color(0xFFC8DCFF).withValues(alpha: 0.55),
                    ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.9),
              width: 1.1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFA3DFFF)
                          : const Color(0xFF2B4D89),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.auto_graph_rounded),
                ],
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: balance),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutExpo,
                builder: (context, value, _) {
                  return Text(
                    moneyFormat.format(value),
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFEAF8FF)
                          : const Color(0xFF102858),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                balance >= 0
                    ? 'Great pace this month.'
                    : 'Spending alert: tune your categories.',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFBBEAFF)
                      : const Color(0xFF385FA0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.88),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.categoryTotals,
    required this.isDark,
    required this.moneyFormat,
    required this.categories,
  });

  final Map<String, double> categoryTotals;
  final bool isDark;
  final NumberFormat moneyFormat;
  final List<CategoryConfig> categories;

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList();
    final totalExpense = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.value,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.92),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Category Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(Icons.pie_chart_rounded),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: entries.isEmpty || totalExpense <= 0
                ? const Center(
                    child: Text('Add expenses to animate the chart.'),
                  )
                : PieChart(
                    PieChartData(
                      centerSpaceRadius: 54,
                      sectionsSpace: 3,
                      startDegreeOffset: -90,
                      sections: entries.map((entry) {
                        final config = categories.firstWhere(
                          (c) => c.name == entry.key,
                          orElse: () => const CategoryConfig(
                            'Other',
                            Icons.category_rounded,
                            Color(0xFF42A5F5),
                          ),
                        );
                        return PieChartSectionData(
                          color: config.color,
                          value: entry.value,
                          title:
                              '${((entry.value / totalExpense) * 100).toStringAsFixed(0)}%',
                          radius: 62,
                          titleStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                  ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: entries.map((entry) {
              final config = categories.firstWhere(
                (c) => c.name == entry.key,
                orElse: () => const CategoryConfig(
                  'Other',
                  Icons.category_rounded,
                  Color(0xFF42A5F5),
                ),
              );
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${entry.key}: ${moneyFormat.format(entry.value)}'),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
