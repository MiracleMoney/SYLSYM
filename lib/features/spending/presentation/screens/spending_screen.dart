import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/add_expense_dialog.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/semi_circle_gauge_chart.dart';
import 'package:miraclemoney/features/salary/presentation/widgets/month_selector.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/expense_list_widget.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/expense_empty_state.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/category_budget_widget.dart';
import 'package:miraclemoney/data/services/firestore_service.dart';

class SpendingScreen extends StatefulWidget {
  final bool isFocused;
  const SpendingScreen({super.key, this.isFocused = false});

  @override
  State<SpendingScreen> createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  final List<ExpenseModel> _expenses = [];
  DateTime _selectedMonth = DateTime.now();
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, double> _categoryBudgets = {}; // 카테고리별 예산 데이터
  Map<String, dynamic> _rawBudgetData = {}; // 전체 예산 데이터 (세부 항목 포함)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadExpenses();
  }

  @override
  void didUpdateWidget(covariant SpendingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 현재 탭으로 돌아왔을 때 데이터를 다시 불러옵니다.
    if (widget.isFocused && !oldWidget.isFocused) {
      _loadExpenses();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Firebase에서 지출 데이터 불러오기
  Future<void> _loadExpenses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 지출 데이터 로드
      final expensesData = await _firestoreService.loadExpenses(_selectedMonth);
      final expenses = expensesData
          .map((data) => ExpenseModel.fromJson(data))
          .toList();

      // salary_data에서 totalIncome 가져오기
      await _firestoreService.loadSalaryData(targetDate: _selectedMonth);

      // 예산 데이터 로드
      await _loadBudgetData();

      setState(() {
        _expenses.clear();
        _expenses.addAll(expenses);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('지출 데이터를 불러오는데 실패했습니다: $e')));
      }
    }
  }

  /// 예산 데이터 로드
  Future<void> _loadBudgetData() async {
    try {
      final budgetData = await _firestoreService.loadBudget(_selectedMonth);

      if (budgetData != null) {
        _rawBudgetData = budgetData; // 저장해둠
        final Map<String, double> categoryTotals = {};

        // 각 카테고리별로 세부 항목들의 예산을 합산
        budgetData.forEach((categoryKey, categoryData) {
          if (categoryData is Map<String, dynamic>) {
            double total = 0;
            categoryData.forEach((itemKey, value) {
              total += (value as num).toDouble();
            });
            categoryTotals[categoryKey] = total;
          }
        });

        _categoryBudgets = categoryTotals;
      } else {
        // 예산 데이터가 없으면 기본값으로 설정
        _rawBudgetData = {};
        _categoryBudgets = {
          'FixedExpenses': 0,
          'LivingExpenses': 0,
          'InvestmentExpenses': 0,
          'SavingExpenses': 0,
          'InterestExpenses': 0,
        };
      }
    } catch (e) {
      // 에러 발생 시 기본값으로 설정
      _rawBudgetData = {};
      _categoryBudgets = {
        'FixedExpenses': 0,
        'LivingExpenses': 0,
        'InvestmentExpenses': 0,
        'SavingExpenses': 0,
        'InterestExpenses': 0,
      };
    }
  }

  /// 지출 추가
  Future<void> _addExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.addExpense(expense.toJson());
      await _loadExpenses(); // 데이터 다시 불러오기

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('지출이 추가되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('지출 추가에 실패했습니다: $e')));
      }
    }
  }

  /// 지출 수정
  Future<void> _updateExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.updateExpense(
        expense.id,
        expense.toJson(),
        expense.date,
      );
      await _loadExpenses(); // 데이터 다시 불러오기

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('지출이 수정되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('지출 수정에 실패했습니다: $e')));
      }
    }
  }

  /// 지출 삭제
  Future<void> _deleteExpense(String expenseId) async {
    try {
      // 삭제할 지출 찾기 (날짜 정보 필요)
      final expense = _expenses.firstWhere((e) => e.id == expenseId);

      await _firestoreService.deleteExpense(expenseId, expense.date);
      await _loadExpenses(); // 데이터 다시 불러오기

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('지출이 삭제되었습니다')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('지출 삭제에 실패했습니다: $e')));
      }
    }
  }

  void _showAddExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(
        onExpenseAdded: _addExpense,
        initialDate: _selectedMonth,
      ),
    );
  }

  void _showEditExpenseDialog(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (context) => AddExpenseDialog(
        onExpenseAdded: _addExpense,
        existingExpense: expense,
        onExpenseUpdated: _updateExpense,
        onExpenseDeleted: _deleteExpense,
      ),
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
        automaticallyImplyLeading: false,
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
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
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
                      _loadExpenses();
                    },
                    onNextMonth: () {
                      setState(() {
                        _selectedMonth = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                        );
                      });
                      _loadExpenses();
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
                    budget: _categoryBudgets.values.fold<double>(
                      0.0,
                      (sum, val) => sum + val,
                    ),
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
                        child: ExpenseListWidget(
                          expenses: monthExpenses,
                          onExpenseTap: _showEditExpenseDialog,
                        ),
                      ),

                // 예산 대비 지출 탭
                SingleChildScrollView(
                  child: CategoryBudgetWidget(
                    expenses: monthExpenses,
                    categoryBudgets: _categoryBudgets,
                    rawBudgetData: _rawBudgetData, // 추가 전달
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final screenWidth = MediaQuery.of(context).size.width;
          final iconSize = screenWidth > 600
              ? screenWidth * 0.055
              : screenWidth * 0.07;

          return FloatingActionButton(
            onPressed: _showAddExpenseDialog,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.add, color: Colors.white, size: iconSize),
          );
        },
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
