import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:personal_budget_tracker/model/catagoryconifig.dart';
import 'package:personal_budget_tracker/model/transactiondraft.dart';

class AddEntryBottomSheet extends StatefulWidget {
  const AddEntryBottomSheet({super.key, required this.categories});

  final List<CategoryConfig> categories;

  @override
  State<AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

class _AddEntryBottomSheetState extends State<AddEntryBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final DateTime _entryDate = DateTime.now();

  static const Set<String> _expenseCategoryNames = <String>{
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Health',
    'Entertainment',
    'Other',
  };

  static const Set<String> _incomeCategoryNames = <String>{
    'Salary',
    'Freelancing',
    'Business',
    'Investment',
    'Bonus',
    'Other',
  };

  String _type = 'expense';
  String _category = 'Food';
  String _titleError = '';
  String _amountError = '';

  String get _formattedEntryDate =>
      DateFormat('dd MMM yyyy').format(_entryDate);

  List<CategoryConfig> get _visibleCategories {
    final targetNames = _type == 'income'
        ? _incomeCategoryNames
        : _expenseCategoryNames;
    return widget.categories
        .where((cat) => targetNames.contains(cat.name))
        .toList();
  }

  void _setType(String newType) {
    if (_type == newType) return;

    setState(() {
      _type = newType;
      final visible = _visibleCategories;
      final isCurrentVisible = visible.any((cat) => cat.name == _category);
      if (!isCurrentVisible && visible.isNotEmpty) {
        _category = visible.first.name;
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = _category;
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String categoryName) {
    _category = categoryName;
    if (_titleController.text.isEmpty) {
      _titleController.text = categoryName;
    }
    setState(() {});
  }

  void _validateAndSubmit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    setState(() {
      _titleError = title.isEmpty ? 'Please fill title field' : '';
      _amountError = (amount == null || amount <= 0)
          ? 'Please enter valid amount'
          : '';
    });

    if (_titleError.isEmpty && _amountError.isEmpty) {
      debugPrint(
        'Adding: Type=$_type, Title=$title, Amount=$amount, Category=$_category',
      );

      Navigator.of(context).pop(
        TransactionDraft(
          title: title,
          amount: amount!,
          type: _type,
          category: _category,
          date: _entryDate.toIso8601String(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: isDark
                ? <Color>[const Color(0xFF122143), const Color(0xFF0E1429)]
                : <Color>[const Color(0xFFEEF5FF), const Color(0xFFD5E6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF36FFE9) : Colors.white,
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 52,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF36FFE9)
                          : const Color(0xFF2B6EF7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Add Entry',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFEAF8FF)
                        : const Color(0xFF06142F),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _setType('expense'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _type == 'expense'
                                  ? const Color(
                                      0xFFFF5B7F,
                                    ).withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _type == 'expense'
                                    ? const Color(0xFFFF5B7F)
                                    : Colors.grey,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_outward_rounded,
                                  size: 16,
                                  color: _type == 'expense'
                                      ? const Color(0xFFFF5B7F)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Expense',
                                  style: TextStyle(
                                    fontWeight: _type == 'expense'
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _type == 'expense'
                                        ? const Color(0xFFFF5B7F)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _setType('income'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _type == 'income'
                                  ? const Color(
                                      0xFF00C27A,
                                    ).withValues(alpha: 0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _type == 'income'
                                    ? const Color(0xFF00C27A)
                                    : Colors.grey,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 16,
                                  color: _type == 'income'
                                      ? const Color(0xFF00C27A)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Income',
                                  style: TextStyle(
                                    fontWeight: _type == 'income'
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _type == 'income'
                                        ? const Color(0xFF00C27A)
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _titleController,
                  onChanged: (_) => setState(() => _titleError = ''),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    helperText: _titleError.isNotEmpty
                        ? null
                        : 'Category will auto-fill',
                    errorText: _titleError.isNotEmpty ? _titleError : null,
                    errorMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _amountController,
                  onChanged: (_) => setState(() => _amountError = ''),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: const Icon(Icons.attach_money_rounded),
                    errorText: _amountError.isNotEmpty ? _amountError : null,
                    errorMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.calendar_today_rounded, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Date: $_formattedEntryDate (auto)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2B6EF7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _validateAndSubmit,
                    child: const Text('Save Entry'),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFEAF8FF)
                        : const Color(0xFF0A2450),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _visibleCategories.map((cat) {
                    final selected = _category == cat.name;
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _onCategorySelected(cat.name),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? cat.color.withValues(alpha: 0.22)
                              : Colors.white.withValues(
                                  alpha: isDark ? 0.07 : 0.6,
                                ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: selected
                                ? cat.color
                                : Colors.white.withValues(
                                    alpha: isDark ? 0.18 : 0.9,
                                  ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(cat.icon, color: cat.color, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
