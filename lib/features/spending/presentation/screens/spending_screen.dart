import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/add_expense_dialog.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/semi_circle_gauge_chart.dart';
import 'package:miraclemoney/features/salary/presentation/widgets/month_selector.dart';
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
        title: Text(
          '지출',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 배경 흰색 영역
          Container(
            color: Colors.white,
            child: Column(
              children: [
                // 월 선택
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: MonthSelector(
                    currentMonth: _selectedMonth,
                    onPreviousMonth: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month - 1,
                        );
                      });
                    },
                    onNextMonth: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                    },
                  ),
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
                const SizedBox(height: 5),

                // 탭바
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: TabBar(
                    controller: _tabController,
                    indicator: _CenteredUnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: Color(0xFFE9435A),
                        width: 1.5,
                      ),
                      widthFraction: 0.5,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: Sizes.size16,
                    ),
                    tabs: const [
                      Tab(text: '지출 내역'),
                      Tab(text: '예산 대비 지출'),
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
                // 지출 내역 탭
                monthExpenses.isEmpty
                    ? const ExpenseEmptyState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: ExpenseListWidget(expenses: monthExpenses),
                      ),

                // 예산 대비 지출 탭
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

class _CenteredUnderlineTabIndicator extends Decoration {
  final BorderSide borderSide;
  final double widthFraction;

  const _CenteredUnderlineTabIndicator({
    required this.borderSide,
    this.widthFraction = 0.7,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CenteredUnderlinePainter(
      borderSide: borderSide,
      widthFraction: widthFraction,
      onChanged: onChanged,
    );
  }
}

class _CenteredUnderlinePainter extends BoxPainter {
  final BorderSide borderSide;
  final double widthFraction;

  _CenteredUnderlinePainter({
    required this.borderSide,
    required this.widthFraction,
    VoidCallback? onChanged,
  }) : super(onChanged);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);
    final width = configuration.size!.width;
    final indicatorWidth = width * widthFraction;
    final horizontalInset = (width - indicatorWidth) / 2;

    final rect =
        Offset(
          offset.dx + horizontalInset,
          configuration.size!.height - borderSide.width,
        ) &
        Size(indicatorWidth, borderSide.width);

    final paint = borderSide.toPaint();
    canvas.drawRect(rect, paint);
  }
}
