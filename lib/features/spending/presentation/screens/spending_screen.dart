import 'package:flutter/material.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/add_expense_dialog.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/total_expense_card.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/category_filter_widget.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/expense_list_widget.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/expense_empty_state.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({super.key});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  final List<ExpenseModel> _expenses = [];
  String _selectedFilter = 'All'; // All, FixedExpenses, LivingExpenses, etc.

  void _addExpense(ExpenseModel expense) {
    setState(() {
      _expenses.add(expense);
    });
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(onExpenseAdded: _addExpense),
    );
  }

  List<ExpenseModel> _getFilteredExpenses() {
    if (_selectedFilter == 'All') {
      return _expenses;
    }
    return _expenses.where((e) => e.category == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _getFilteredExpenses();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '지출',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 총 지출 카드
            TotalExpenseCard(expenses: filteredExpenses),
            const SizedBox(height: 24),

            // 카테고리별 필터
            CategoryFilterWidget(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
            const SizedBox(height: 24),

            // 지출 목록 또는 빈 상태
            if (filteredExpenses.isEmpty)
              const ExpenseEmptyState()
            else
              ExpenseListWidget(expenses: filteredExpenses),

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: const Color(0xFF5B7EFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
