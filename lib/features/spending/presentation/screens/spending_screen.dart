import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/add_expense_dialog.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/semi_circle_gauge_chart.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/month_selector_widget.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/expense_list_widget.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/expense_empty_state.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/category_budget_widget.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({super.key});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen>
    with SingleTickerProviderStateMixin {
  final List<ExpenseModel> _expenses = [];
  DateTime _selectedMonth = DateTime.now();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  List<ExpenseModel> _getMonthExpenses() {
    return _expenses.where((expense) {
      return expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final monthExpenses = _getMonthExpenses();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          '지출',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size24,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () {
              // 상세 화면으로 이동 (나중에 구현)
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 배경 흰색 영역
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // 월 선택
                MonthSelectorWidget(
                  selectedMonth: _selectedMonth,
                  onMonthChanged: (month) {
                    setState(() {
                      _selectedMonth = month;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // 반원 게이지 차트
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SemiCircleGaugeChart(
                    expenses: monthExpenses,
                    selectedMonth: _selectedMonth,
                  ),
                ),
                const SizedBox(height: 20),

                // 탭바
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Spends'),
                      Tab(text: 'Categories'),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // 탭 내용
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Spends 탭
                monthExpenses.isEmpty
                    ? const ExpenseEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: ExpenseListWidget(expenses: monthExpenses),
                      ),

                // Categories 탭
                SingleChildScrollView(
                  child: CategoryBudgetWidget(expenses: monthExpenses),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
