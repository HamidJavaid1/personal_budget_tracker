import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_budget_tracker/model/catagoryconifig.dart';
import 'package:personal_budget_tracker/model/savinggoalmodel.dart';
import 'package:personal_budget_tracker/model/transaction.dart';
import 'package:personal_budget_tracker/model/transactiondraft.dart';
import 'package:personal_budget_tracker/screens.dart/addentrybottomsheet.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/budget_goals_view.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/dashboard_view.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/home_bottom_navigation.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/limitreachnotification.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/savings_view.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/setbudgetgoalsview.dart';
import 'package:personal_budget_tracker/screens.dart/widgets/home/transactions_view.dart';
import 'package:personal_budget_tracker/sevices.dart/db_helper.dart';
import 'package:personal_budget_tracker/widgets/app_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onCurrencyChanged,
    this.selectedCurrency = 'USD',
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onCurrencyChanged;
  final String selectedCurrency;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final DBHelper _dbHelper = DBHelper();
  final Set<String> _notifiedGoalKeys = <String>{};
  final Set<String> _notifiedBudgetKeys = <String>{};
  Timer? _topNotificationTimer;

  static const List<(String, String, IconData)>
  _savingTips = <(String, String, IconData)>[
    (
      'AI Tip: Split Smartly',
      'Follow 50/30/20 and auto-move savings first, then spend from what remains.',
      Icons.pie_chart_rounded,
    ),
    (
      'AI Tip: Weekly Buffer',
      'Keep a weekly spending cap with a 10% buffer to avoid end-of-month stress.',
      Icons.shield_rounded,
    ),
    (
      'AI Tip: Subscription Cleanup',
      'Review recurring payments monthly and remove low-value subscriptions.',
      Icons.subscriptions_rounded,
    ),
    (
      'AI Tip: Emergency First',
      'Build an emergency fund target before increasing lifestyle spending.',
      Icons.health_and_safety_rounded,
    ),
  ];

  static const List<(String, String)> _currencyOptions = <(String, String)>[
    ('USD', 'US Dollar'),
    ('EUR', 'Euro'),
    ('GBP', 'British Pound'),
    ('JPY', 'Japanese Yen'),
    ('INR', 'Indian Rupee'),
    ('AED', 'UAE Dirham'),
    ('AFN', 'Afghan Afghani'),
    ('ALL', 'Albanian Lek'),
    ('AMD', 'Armenian Dram'),
    ('ANG', 'Netherlands Antillean Guilder'),
    ('AOA', 'Angolan Kwanza'),
    ('ARS', 'Argentine Peso'),
    ('AWG', 'Aruban Florin'),
    ('AUD', 'Australian Dollar'),
    ('AZN', 'Azerbaijani Manat'),
    ('BAM', 'Bosnia-Herzegovina Mark'),
    ('BBD', 'Barbadian Dollar'),
    ('BDT', 'Bangladeshi Taka'),
    ('BGN', 'Bulgarian Lev'),
    ('BHD', 'Bahraini Dinar'),
    ('BIF', 'Burundian Franc'),
    ('BMD', 'Bermudan Dollar'),
    ('BND', 'Brunei Dollar'),
    ('BOB', 'Bolivian Boliviano'),
    ('BRL', 'Brazilian Real'),
    ('BSD', 'Bahamian Dollar'),
    ('BTN', 'Bhutanese Ngultrum'),
    ('BWP', 'Botswanan Pula'),
    ('BYN', 'Belarusian Ruble'),
    ('BZD', 'Belize Dollar'),
    ('CAD', 'Canadian Dollar'),
    ('CDF', 'Congolese Franc'),
    ('CHF', 'Swiss Franc'),
    ('CLP', 'Chilean Peso'),
    ('CNY', 'Chinese Yuan'),
    ('COP', 'Colombian Peso'),
    ('CRC', 'Costa Rican Colon'),
    ('CUP', 'Cuban Peso'),
    ('CZK', 'Czech Koruna'),
    ('DKK', 'Danish Krone'),
    ('DOP', 'Dominican Peso'),
    ('DZD', 'Algerian Dinar'),
    ('EGP', 'Egyptian Pound'),
    ('ETB', 'Ethiopian Birr'),
    ('FJD', 'Fijian Dollar'),
    ('GEL', 'Georgian Lari'),
    ('GHS', 'Ghanaian Cedi'),
    ('GMD', 'Gambian Dalasi'),
    ('GNF', 'Guinean Franc'),
    ('GTQ', 'Guatemalan Quetzal'),
    ('HKD', 'Hong Kong Dollar'),
    ('HNL', 'Honduran Lempira'),
    ('HRK', 'Croatian Kuna'),
    ('HUF', 'Hungarian Forint'),
    ('IDR', 'Indonesian Rupiah'),
    ('ILS', 'Israeli New Shekel'),
    ('IQD', 'Iraqi Dinar'),
    ('IRR', 'Iranian Rial'),
    ('ISK', 'Icelandic Krona'),
    ('JMD', 'Jamaican Dollar'),
    ('JOD', 'Jordanian Dinar'),
    ('KES', 'Kenyan Shilling'),
    ('KGS', 'Kyrgystani Som'),
    ('KHR', 'Cambodian Riel'),
    ('KRW', 'South Korean Won'),
    ('KWD', 'Kuwaiti Dinar'),
    ('KZT', 'Kazakhstani Tenge'),
    ('LAK', 'Laotian Kip'),
    ('LBP', 'Lebanese Pound'),
    ('LKR', 'Sri Lankan Rupee'),
    ('MAD', 'Moroccan Dirham'),
    ('MDL', 'Moldovan Leu'),
    ('MGA', 'Malagasy Ariary'),
    ('MKD', 'Macedonian Denar'),
    ('MMK', 'Myanmar Kyat'),
    ('MNT', 'Mongolian Tugrik'),
    ('MOP', 'Macanese Pataca'),
    ('MUR', 'Mauritian Rupee'),
    ('MVR', 'Maldivian Rufiyaa'),
    ('MXN', 'Mexican Peso'),
    ('MYR', 'Malaysian Ringgit'),
    ('NAD', 'Namibian Dollar'),
    ('NGN', 'Nigerian Naira'),
    ('NOK', 'Norwegian Krone'),
    ('NPR', 'Nepalese Rupee'),
    ('NZD', 'New Zealand Dollar'),
    ('OMR', 'Omani Rial'),
    ('PAB', 'Panamanian Balboa'),
    ('PEN', 'Peruvian Sol'),
    ('PHP', 'Philippine Peso'),
    ('PKR', 'Pakistani Rupee'),
    ('PLN', 'Polish Zloty'),
    ('QAR', 'Qatari Riyal'),
    ('RON', 'Romanian Leu'),
    ('RSD', 'Serbian Dinar'),
    ('RUB', 'Russian Ruble'),
    ('SAR', 'Saudi Riyal'),
    ('SEK', 'Swedish Krona'),
    ('SGD', 'Singapore Dollar'),
    ('THB', 'Thai Baht'),
    ('TRY', 'Turkish Lira'),
    ('TWD', 'New Taiwan Dollar'),
    ('UAH', 'Ukrainian Hryvnia'),
    ('UGX', 'Ugandan Shilling'),
    ('UYU', 'Uruguayan Peso'),
    ('UZS', 'Uzbekistani Som'),
    ('VND', 'Vietnamese Dong'),
    ('XOF', 'West African CFA Franc'),
    ('YER', 'Yemeni Rial'),
    ('ZAR', 'South African Rand'),
    ('ZMW', 'Zambian Kwacha'),
  ];

  late NumberFormat _moneyFormat;

  List<SavingGoal> goals = [];

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

  Map<String, double> _budgetGoals = <String, double>{
    'Food': 10000,
    'Transport': 2200,
    'Bills': 3000,
    'Shopping': 2260,
    'Health': 2200,
    'Entertainment': 2280,
  };

  @override
  void initState() {
    super.initState();

    _updateMoneyFormatter(widget.selectedCurrency);

    _entryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _alertAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);

    _loadData();
    _loadGoals();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCurrency != widget.selectedCurrency) {
      _updateMoneyFormatter(widget.selectedCurrency);
    }
  }

  void _updateMoneyFormatter(String currencyCode) {
    _moneyFormat = NumberFormat.simpleCurrency(
      name: currencyCode,
      decimalDigits: 0,
    );
  }

  Future<void> _showCurrencySettingsSheet() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final maxHeight = MediaQuery.of(context).size.height * 0.72;
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              color: isDark ? const Color(0xFF101936) : Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Settings • Currency',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _currencyOptions.length,
                      itemBuilder: (context, index) {
                        final (code, label) = _currencyOptions[index];
                        final selected = widget.selectedCurrency == code;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          leading: Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? const Color(0xFF2B6EF7)
                                : (isDark
                                      ? const Color(0xFFA1BCD5)
                                      : const Color(0xFF6A81AA)),
                          ),
                          title: Text('$code • $label'),
                          onTap: () {
                            widget.onCurrencyChanged(code);
                            setState(() {
                              _updateMoneyFormatter(code);
                            });
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _topNotificationTimer?.cancel();
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
    _showBudgetLimitNotifications();
  }

  Future<void> _loadGoals() async {
    final data = await _dbHelper.getGoals();
    if (!mounted) return;
    setState(() {
      goals = data;
    });
    _showReachedGoalNotifications(data);
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

  void _showTopNotification({
    required Widget content,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    _topNotificationTimer?.cancel();
    messenger.removeCurrentMaterialBanner();
    messenger.showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        backgroundColor: Colors.transparent,
        elevation: 0,
        forceActionsBelow: false,
        content: content,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _topNotificationTimer?.cancel();
              messenger.removeCurrentMaterialBanner();
              onAction();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );

    _topNotificationTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      messenger.removeCurrentMaterialBanner();
    });
  }

  String _goalNotificationKey(SavingGoal goal) {
    return goal.id?.toString() ?? '${goal.title}_${goal.createdAt}';
  }

  void _showReachedGoalNotifications(List<SavingGoal> loadedGoals) {
    final reachedGoals = loadedGoals
        .where((goal) => goal.progress >= 1)
        .where(
          (goal) => !_notifiedGoalKeys.contains(_goalNotificationKey(goal)),
        )
        .toList();

    if (reachedGoals.isEmpty) return;

    for (final goal in reachedGoals) {
      _notifiedGoalKeys.add(_goalNotificationKey(goal));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      for (final goal in reachedGoals) {
        _showTopNotification(
          content: LimitReachNotification.goalReached(
            goalTitle: goal.title,
            savedAmount: goal.savedAmount,
            targetAmount: goal.targetAmount,
            moneyFormatter: _moneyFormat.format,
          ),
          actionLabel: 'Check',
          onAction: () {
            if (!mounted) return;
            setState(() => _currentTab = 3);
          },
        );
      }
    });
  }

  void _showBudgetLimitNotifications() {
    final expenseMap = _expenseByCategory;
    final newlyExceeded = _budgetGoals.entries.where((entry) {
      final spent = expenseMap[entry.key] ?? 0;
      final exceeds = spent > entry.value;
      if (!exceeds) {
        _notifiedBudgetKeys.remove(entry.key);
        return false;
      }
      return !_notifiedBudgetKeys.contains(entry.key);
    }).toList();

    if (newlyExceeded.isEmpty) return;

    for (final entry in newlyExceeded) {
      _notifiedBudgetKeys.add(entry.key);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      for (final entry in newlyExceeded) {
        final spent = expenseMap[entry.key] ?? 0;
        final overBy = spent - entry.value;

        _showTopNotification(
          content: LimitReachNotification.budgetExceeded(
            category: entry.key,
            overBy: _moneyFormat.format(overBy),
          ),
          actionLabel: 'View',
          onAction: () {
            if (!mounted) return;
            setState(() => _currentTab = 2);
          },
        );
      }
    });
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

  Future<void> _openSetBudgetGoals() async {
    final updatedGoals = await Navigator.of(context).push<Map<String, double>>(
      MaterialPageRoute(
        builder: (_) => Setbudgetgoalsview(initialGoals: _budgetGoals),
      ),
    );

    if (!mounted || updatedGoals == null) return;
    setState(() {
      _budgetGoals = updatedGoals;
    });
    _showBudgetLimitNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButton: _currentTab == 3
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddTransactionSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigation(isDark),
      body: AppBackground(
        isDark: isDark,
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
                2 => _buildBudgetGoals(isDark),
                _ => _buildSavingGoals(isDark),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isDark) {
    return DashboardView(
      isDark: isDark,
      onRefresh: _loadData,
      onOpenSettings: _showCurrencySettingsSheet,
      onToggleTheme: widget.onToggleTheme,
      income: _income,
      expense: _expense,
      balance: _balance,
      moneyFormat: _moneyFormat,
      expenseByCategory: _expenseByCategory,
      categories: _categories,
    );
  }

  Widget _buildTransactions(bool isDark) {
    return TransactionsView(
      isDark: isDark,
      transactions: _transactions,
      categories: _categories,
      moneyFormatter: _moneyFormat.format,
    );
  }

  Widget _buildBudgetGoals(bool isDark) {
    final alertAnimation = Tween<double>(begin: 0.95, end: 1.02).animate(
      CurvedAnimation(
        parent: _alertAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    return BudgetGoalsView(
      isDark: isDark,
      expenseByCategory: _expenseByCategory,
      budgetGoals: _budgetGoals,
      alertAnimation: alertAnimation,
      goalColor: _goalColor,
      moneyFormatter: _moneyFormat.format,
      onEditGoals: _openSetBudgetGoals,
    );
  }

  Widget _buildSavingGoals(bool isDark) {
    return SavingsView(
      isDark: isDark,
      goals: goals,
      moneyFormatter: _moneyFormat.format,
      goalColor: _goalColor,
      savingTips: _savingTips,
    );
  }

  Widget _buildBottomNavigation(bool isDark) {
    return HomeBottomNavigation(
      isDark: isDark,
      currentTab: _currentTab,
      onTabChanged: (index) => setState(() => _currentTab = index),
    );
  }
}
