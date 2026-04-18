import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_budget_tracker/model/catagoryconifig.dart';
import 'package:personal_budget_tracker/model/transaction.dart';
import 'package:personal_budget_tracker/model/transactiondraft.dart';
import 'package:personal_budget_tracker/screens.dart/addentrybottomsheet.dart';
import 'package:personal_budget_tracker/sevices.dart/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    this.selectedCurrency = 'USD',
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final String selectedCurrency;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DBHelper _dbHelper = DBHelper();
  late final NumberFormat _moneyFormat;

  late final AnimationController _entryAnimationController;
  late final AnimationController _alertAnimationController;

  List<TransactionModel> _transactions = <TransactionModel>[];
  int _currentTab = 0;

  static final List<CategoryConfig> _categories = <CategoryConfig>[
    CategoryConfig('Food', Icons.restaurant_rounded, Color(0xFFFF8A65)),
    CategoryConfig(
      'Transport',
      Icons.directions_bus_rounded,
      Color(0xFF5C6BC0),
    ),
    CategoryConfig('Bills', Icons.receipt_long_rounded, Color(0xFFFFC107)),
    CategoryConfig('Shopping', Icons.shopping_bag_rounded, Color(0xFFAB47BC)),
    CategoryConfig('Health', Icons.favorite_rounded, Color(0xFF26A69A)),
    CategoryConfig('Entertainment', Icons.movie_rounded, Color(0xFFEF5350)),
    CategoryConfig(
      'Salary',
      Icons.account_balance_wallet_rounded,
      Color(0xFF66BB6A),
    ),
    CategoryConfig('Freelancing', Icons.laptop_mac_rounded, Color(0xFF00C27A)),
    CategoryConfig('Business', Icons.storefront_rounded, Color(0xFF26A69A)),
    CategoryConfig('Investment', Icons.show_chart_rounded, Color(0xFF4CAF50)),
    CategoryConfig('Bonus', Icons.card_giftcard_rounded, Color(0xFF8BC34A)),
    CategoryConfig('Other', Icons.category_rounded, Color(0xFF42A5F5)),
  ];

  static const Map<String, double> _budgetGoals = <String, double>{
    'Food': 350,
    'Transport': 220,
    'Bills': 300,
    'Shopping': 260,
    'Health': 200,
    'Entertainment': 180,
  };

  @override
  void initState() {
    super.initState();

    // Support any ISO currency code selected on the welcome screen.
    _moneyFormat = NumberFormat.simpleCurrency(
      name: widget.selectedCurrency,
      decimalDigits: 0,
    );

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _loadData();
  }

  @override
  void dispose() {
    _entryAnimationController.dispose();
    _alertAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await _dbHelper.getTransactions();
    if (!mounted) return;
    setState(() {
      _transactions = data;
    });
  }

  double get _income {
    return _transactions
        .where((tx) => tx.type.toLowerCase() == 'income')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _expense {
    return _transactions
        .where((tx) => tx.type.toLowerCase() == 'expense')
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get _balance => _income - _expense;

  Map<String, double> get _expenseByCategory {
    final map = <String, double>{};
    for (final tx in _transactions) {
      if (tx.type.toLowerCase() != 'expense') continue;
      map[tx.category] = (map[tx.category] ?? 0) + tx.amount;
    }
    return map;
  }

  Color _goalColor(double ratio) {
    if (ratio < 0.65) return const Color(0xFF00C853);
    if (ratio < 0.9) return const Color(0xFFFFD600);
    return const Color(0xFFFF3D00);
  }

  Future<void> _showAddTransactionSheet() async {
    final draft = await showModalBottomSheet<TransactionDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEntryBottomSheet(categories: _categories),
    );

    if (draft == null || !mounted) return;

    final isExpense = draft.type.toLowerCase() == 'expense';
    if (isExpense && draft.amount > _balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Out of balance: expense exceeds your current balance.',
          ),
          backgroundColor: Color(0xFFFF3D00),
        ),
      );
      return;
    }

    await _dbHelper.insert(
      TransactionModel(
        title: draft.title,
        amount: draft.amount,
        type: draft.type,
        category: draft.category,
        date: draft.date,
      ),
    );

    if (!mounted) return;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTransactionSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigation(isDark),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? <Color>[
                    const Color(0xFF050814),
                    const Color(0xFF101633),
                    const Color(0xFF13213E),
                  ]
                : <Color>[
                    const Color(0xFFD8E9FF),
                    const Color(0xFFEFF7FF),
                    const Color(0xFFF9FCFF),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _entryAnimationController,
              curve: Curves.easeOut,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 450),
              child: switch (_currentTab) {
                0 => _buildDashboard(isDark),
                1 => _buildTransactions(isDark),
                _ => _buildBudgetGoals(isDark),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isDark) {
    final categoryTotals = _expenseByCategory;

    return RefreshIndicator(
      onRefresh: _loadData,
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
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildGlassBalanceCard(isDark),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _statCard(
                  title: 'Income',
                  value: _moneyFormat.format(_income),
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF00C27A),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  title: 'Expense',
                  value: _moneyFormat.format(_expense),
                  icon: Icons.trending_down_rounded,
                  color: const Color(0xFFFF4D6D),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildPieChartCard(categoryTotals, isDark),
        ],
      ),
    );
  }

  Widget _buildGlassBalanceCard(bool isDark) {
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
                tween: Tween<double>(begin: 0, end: _balance),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutExpo,
                builder: (context, value, _) {
                  return Text(
                    _moneyFormat.format(value),
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
                _balance >= 0
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

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
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

  Widget _buildPieChartCard(Map<String, double> categoryTotals, bool isDark) {
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
                        final config = _categories.firstWhere(
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
              final config = _categories.firstWhere(
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
                child: Text(
                  '${entry.key}: ${_moneyFormat.format(entry.value)}',
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions(bool isDark) {
    final sorted = <TransactionModel>[
      ..._transactions,
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
          final category = _categories.firstWhere(
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
                  '${isIncome ? '+' : '-'}${_moneyFormat.format(tx.amount)}',
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

  Widget _buildBudgetGoals(bool isDark) {
    final spent = _expenseByCategory;
    final exceededCount = _budgetGoals.entries
        .where((entry) => (spent[entry.key] ?? 0) > entry.value)
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
            scale: Tween<double>(begin: 0.95, end: 1.02).animate(
              CurvedAnimation(
                parent: _alertAnimationController,
                curve: Curves.easeInOut,
              ),
            ),
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
        ..._budgetGoals.entries.map((entry) {
          final value = spent[entry.key] ?? 0;
          final ratio = entry.value == 0 ? 0.0 : value / entry.value;
          final color = _goalColor(ratio);

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
                      '${_moneyFormat.format(value)} / ${_moneyFormat.format(entry.value)}',
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
                      'Limit exceeded by ${_moneyFormat.format(value - entry.value)}',
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

  Widget _buildBottomNavigation(bool isDark) {
    final items = <(IconData, String)>[
      (Icons.space_dashboard_rounded, 'Dashboard'),
      (Icons.timeline_rounded, 'Activity'),
      (Icons.flag_rounded, 'Goals'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.95),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List<Widget>.generate(items.length, (index) {
            final item = items[index];
            final selected = _currentTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selected
                        ? (isDark
                              ? const Color(0xFF36FFE9).withValues(alpha: 0.2)
                              : const Color(0xFF2B6EF7).withValues(alpha: 0.14))
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        scale: selected ? 1.12 : 1,
                        child: Icon(
                          item.$1,
                          color: selected
                              ? (isDark
                                    ? const Color(0xFF36FFE9)
                                    : const Color(0xFF2B6EF7))
                              : (isDark
                                    ? const Color(0xFFA1BCD5)
                                    : const Color(0xFF6A81AA)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? (isDark
                                    ? const Color(0xFF36FFE9)
                                    : const Color(0xFF2B6EF7))
                              : (isDark
                                    ? const Color(0xFFA1BCD5)
                                    : const Color(0xFF6A81AA)),
                        ),
                        child: Text(item.$2),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
