import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:intl/intl.dart';
import 'package:miraclemoney/data/services/firestore_service.dart';
import 'package:miraclemoney/data/models/salary/salary_result_data.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _selectedMonth = DateTime.now();
  final FirestoreService _firestoreService = FirestoreService();
  SalaryResultData? _salaryResult;
  bool _isSalaryLoading = false;

  final List<String> _categoryOrder = const ['생활비', '고정비', '투자', '저축', '이자'];

  String _selectedCategory = '생활비';

  // 카테고리별 예산 데이터
  final Map<String, Map<String, TextEditingController>> _budgetControllers = {
    '생활비': {
      '식비': TextEditingController(text: '0'),
      '외식': TextEditingController(text: '0'),
      '배달 음식': TextEditingController(text: '0'),
      '커피': TextEditingController(text: '0'),
      '음료': TextEditingController(text: '0'),
      '술': TextEditingController(text: '0'),
      '생필품': TextEditingController(text: '0'),
      '담배': TextEditingController(text: '0'),
      '미용': TextEditingController(text: '0'),
      '옷': TextEditingController(text: '0'),
      '신발': TextEditingController(text: '0'),
      '액세서리': TextEditingController(text: '0'),
      '문화 생활': TextEditingController(text: '0'),
      '모임 회비': TextEditingController(text: '0'),
      '취미': TextEditingController(text: '0'),
      'OTT': TextEditingController(text: '0'),
      'OTT 외 구독 서비스': TextEditingController(text: '0'),
      '기타': TextEditingController(text: '0'),
    },
    '고정비': {
      '보험': TextEditingController(text: '0'),
      '통신비': TextEditingController(text: '0'),
      '대중교통': TextEditingController(text: '0'),
      '자동차 할부': TextEditingController(text: '0'),
      '자동차 보험': TextEditingController(text: '0'),
      '주유': TextEditingController(text: '0'),
      '월세': TextEditingController(text: '0'),
      '공과금': TextEditingController(text: '0'),
      '관리비': TextEditingController(text: '0'),
      '기타': TextEditingController(text: '0'),
    },
    '투자': {
      '연금 저축': TextEditingController(text: '0'),
      '퇴직 연금': TextEditingController(text: '0'),
      'ISA': TextEditingController(text: '0'),
      '일반계좌': TextEditingController(text: '0'),
    },
    '저축': {
      '비상금': TextEditingController(text: '0'),
      '단기 목표': TextEditingController(text: '0'),
      '주택 청약': TextEditingController(text: '0'),
      '내집 마련': TextEditingController(text: '0'),
      '기타': TextEditingController(text: '0'),
    },

    '이자': {
      '신용 대출': TextEditingController(text: '0'),
      '전세 대출': TextEditingController(text: '0'),
      '주택 담보 대출': TextEditingController(text: '0'),
      '기타 이자': TextEditingController(text: '0'),
    },
  };

  final TextEditingController _monthlyIncomeController = TextEditingController(
    text: '5000000',
  );

  // 월별 예산 스냅샷 (메모리 저장)
  final Map<String, Map<String, Map<String, double>>> _budgetSnapshots = {};

  double _totalExpense = 0;
  Map<String, double> _previousCategoryExpenses = {};

  @override
  void dispose() {
    for (var category in _budgetControllers.values) {
      for (var controller in category.values) {
        controller.dispose();
      }
    }
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadBudgetFromFirestore(_selectedMonth);
    _loadSalaryResult();
    _loadExpenses();
  }

  double _getCategoryTotal(String category) {
    double total = 0;
    for (var controller in _budgetControllers[category]!.values) {
      final value = double.tryParse(controller.text) ?? 0;
      total += value;
    }
    return total;
  }

  double _getPreviousCategoryTotal(String category) {
    final previousSnapshot = _getPreviousMonthSnapshot();
    if (previousSnapshot == null) {
      return 0;
    }

    final items = previousSnapshot[category];
    if (items == null) {
      return 0;
    }

    double total = 0;
    for (final value in items.values) {
      total += value;
    }
    return total;
  }

  double _getTotalBudget() {
    double total = 0;
    for (var category in _budgetControllers.keys) {
      total += _getCategoryTotal(category);
    }
    return total;
  }

  double _getPreviousTotalBudget() {
    final previousSnapshot = _getPreviousMonthSnapshot();
    if (previousSnapshot == null) {
      return 0;
    }

    double total = 0;
    for (final categoryItems in previousSnapshot.values) {
      for (final value in categoryItems.values) {
        total += value;
      }
    }
    return total;
  }

  void _changeMonth(int months) {
    _saveCurrentSnapshot();
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
    });
    _loadBudgetFromFirestore(_selectedMonth);
    _loadSalaryResult();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    try {
      // 선택 월의 예산 화면 → 이전 달의 실제 지출 연동
      final previousMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
      final expensesData = await _firestoreService.loadExpenses(previousMonth);
      double total = 0;
      final Map<String, double> categoryTotals = {};
      for (final data in expensesData) {
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final category = data['category'] as String? ?? '';
        total += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }
      if (mounted)
        setState(() {
          _totalExpense = total;
          _previousCategoryExpenses = categoryTotals;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _totalExpense = 0;
          _previousCategoryExpenses = {};
        });
    }
  }

  String _yearMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Map<String, Map<String, double>> _snapshotFromControllers() {
    final Map<String, Map<String, double>> snapshot = {};
    _budgetControllers.forEach((category, items) {
      snapshot[category] = {};
      items.forEach((label, controller) {
        final value = double.tryParse(controller.text) ?? 0;
        snapshot[category]![label] = value;
      });
    });
    return snapshot;
  }

  void _saveCurrentSnapshot() {
    final key = _yearMonthKey(_selectedMonth);
    _budgetSnapshots[key] = _snapshotFromControllers();
  }

  void _loadSnapshotForMonth(DateTime month) {
    final key = _yearMonthKey(month);
    final snapshot = _budgetSnapshots[key];

    _budgetControllers.forEach((category, items) {
      items.forEach((label, controller) {
        final value = snapshot?[category]?[label] ?? 0;
        controller.text = value.round().toString();
      });
    });

    setState(() {});
  }

  Map<String, Map<String, double>>? _getPreviousMonthSnapshot() {
    final previousMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
    );
    return _budgetSnapshots[_yearMonthKey(previousMonth)];
  }

  double? _getPreviousValue(String category, String label) {
    final snapshot = _getPreviousMonthSnapshot();
    return snapshot?[category]?[label];
  }

  /// 한글 서브카테고리 레이블 → 영문 키 변환
  String _getSubcategoryKey(String categoryKey, String koreanLabel) {
    final subcategories = ExpenseCategory.getSubcategories(categoryKey);
    final normalized = _normalizeCategoryLabel(koreanLabel);
    for (final entry in subcategories.entries) {
      if (_normalizeCategoryLabel(entry.value) == normalized) {
        return entry.key;
      }
    }
    return koreanLabel; // 매핑 실패 시 원본 반환
  }

  /// Firestore에서 해당 월 예산 데이터 불러오기
  Future<void> _loadBudgetFromFirestore(DateTime month) async {
    try {
      final data = await _firestoreService.loadBudget(month);
      if (data == null) {
        // Firestore에 데이터 없으면 메모리 스냅샷으로 폴백
        _loadSnapshotForMonth(month);
        return;
      }
      // 영문 키 → 한글 컨트롤러에 반영
      _budgetControllers.forEach((categoryKorean, items) {
        final categoryKey =
            _getExpenseCategoryKey(categoryKorean) ?? categoryKorean;
        final categoryData = data[categoryKey];
        items.forEach((labelKorean, controller) {
          if (categoryData is Map) {
            final itemKey = _getSubcategoryKey(categoryKey, labelKorean);
            final value = categoryData[itemKey];
            controller.text = (value ?? 0).toString();
          } else {
            controller.text = '0';
          }
        });
      });
      setState(() {});
    } catch (_) {
      // 에러 시 메모리 스냅샷으로 폴백
      _loadSnapshotForMonth(month);
    }
  }

  /// Firestore에 현재 월 예산 데이터 저장
  Future<void> _saveBudgetToFirestore() async {
    try {
      final Map<String, dynamic> budgetData = {};
      // 한글 키 → 영문 키로 변환하여 저장
      _budgetControllers.forEach((categoryKorean, items) {
        final categoryKey =
            _getExpenseCategoryKey(categoryKorean) ?? categoryKorean;
        final Map<String, dynamic> categoryData = {};
        items.forEach((labelKorean, controller) {
          final itemKey = _getSubcategoryKey(categoryKey, labelKorean);
          categoryData[itemKey] = double.tryParse(controller.text) ?? 0;
        });
        budgetData[categoryKey] = categoryData;
      });

      await _firestoreService.saveBudget(
        budgetData,
        targetDate: _selectedMonth,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('예산이 저장되었습니다.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    }
  }

  Future<void> _loadSalaryResult() async {
    setState(() {
      _isSalaryLoading = true;
    });
    try {
      // 선택 월의 예산 기준 수입 = 이전 달 salary_data
      final previousMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
      final data = await _firestoreService.loadSalaryData(
        targetDate: previousMonth,
      );
      setState(() {
        _salaryResult = data?.result;
        _isSalaryLoading = false;
      });
    } catch (_) {
      setState(() {
        _salaryResult = null;
        _isSalaryLoading = false;
      });
    }
  }

  String _formatCurrency(double value) {
    return '₩${NumberFormat('#,###').format(value.round())}';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '고정비':
        return Icons.home;
      case '생활비':
        return Icons.shopping_cart;
      case '투자':
        return Icons.trending_up;
      case '저축':
        return Icons.savings;
      case '이자':
        return Icons.percent;
      default:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '고정비':
        return const Color(0xFF5B7EFF);
      case '생활비':
        return const Color(0xFF4CAF50);
      case '투자':
        return const Color(0xFFFFA726);
      case '저축':
        return const Color(0xFFEC407A);
      case '이자':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  String? _getExpenseCategoryKey(String categoryLabel) {
    switch (categoryLabel) {
      case '생활비':
        return ExpenseCategory.livingExpenses;
      case '고정비':
        return ExpenseCategory.fixedExpenses;
      case '투자':
        return ExpenseCategory.investmentExpenses;
      case '저축':
        return ExpenseCategory.savingExpenses;
      case '이자':
        return ExpenseCategory.interestExpenses;
      default:
        return null;
    }
  }

  String _normalizeCategoryLabel(String label) {
    return label.replaceAll(RegExp(r'\s+'), '');
  }

  IconData _getExpenseItemIcon(String categoryLabel, String itemLabel) {
    final categoryKey = _getExpenseCategoryKey(categoryLabel);
    if (categoryKey == null) {
      return Icons.receipt;
    }

    final subcategories = ExpenseCategory.getSubcategories(categoryKey);
    final normalizedItemLabel = _normalizeCategoryLabel(itemLabel);
    String? subcategoryKey;

    for (final entry in subcategories.entries) {
      if (_normalizeCategoryLabel(entry.value) == normalizedItemLabel) {
        subcategoryKey = entry.key;
        break;
      }
    }

    return ExpenseCategory.getCategoryIcon(subcategoryKey ?? itemLabel);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => _changeMonth(-1),
        ),
        title: Text(
          '${_selectedMonth.year}년 ${_selectedMonth.month}월',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w500,
            fontSize: Sizes.size16 + Sizes.size2,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.black),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildBudgetDistributionSection(),
                const SizedBox(height: 16),
                _buildCategorySelectorRow(),
                const SizedBox(height: 12),
                _buildCategoryComparisonGauge(),
                const SizedBox(height: 12),
                _buildSelectedCategoryItems(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCategorySelectorRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _categoryOrder.map((category) {
          final isSelected = category == _selectedCategory;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE9435A)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: Sizes.size12,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedCategoryItems() {
    final items = _budgetControllers[_selectedCategory];
    if (items == null || items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: items.entries.map((entry) {
        return _buildBudgetItem(_selectedCategory, entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCategoryComparisonGauge() {
    final currentTotal = _getCategoryTotal(_selectedCategory);
    final categoryKey =
        _getExpenseCategoryKey(_selectedCategory) ?? _selectedCategory;
    final previousTotal = _previousCategoryExpenses[categoryKey] ?? 0;
    final categoryColor = _getCategoryColor(_selectedCategory);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번달 $_selectedCategory 예산',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(currentTotal),
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '지난달 $_selectedCategory 지출',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(previousTotal),
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size14,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isOverBudget =
                  previousTotal > 0 && currentTotal > previousTotal;
              final progress = previousTotal > 0
                  ? (currentTotal / previousTotal).clamp(0.0, 1.0)
                  : 0.0;
              final barColor = isOverBudget ? Colors.red : categoryColor;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 10,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (currentTotal > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      isOverBudget
                          ? '예산 초과'
                          : '${(progress * 100).toStringAsFixed(0)}% 사용',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size11,
                        color: isOverBudget ? Colors.red : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeRow({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    final progress = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w500,
                fontSize: Sizes.size12,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w500,
                fontSize: Sizes.size12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBudgetItem(
    String category,
    String label,
    TextEditingController controller,
  ) {
    final previousValue = _getPreviousValue(category, label);
    final categoryColor = _getCategoryColor(category);
    final iconData = _getExpenseItemIcon(category, label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: categoryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      fontSize: Sizes.size14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '지난달 ${_formatCurrency(previousValue ?? 0)}',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w400,
                          fontSize: Sizes.size12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 110,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w400,
                  fontSize: Sizes.size14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade600,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFFE9435A)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetDistributionSection() {
    final totalBudget = _getTotalBudget();
    final previousTotalBudget = _getPreviousTotalBudget();
    // 이전 달 salary_data의 totalIncome 사용 (없으면 0)
    final monthlyIncome = _salaryResult?.totalIncome ?? 0;
    final sortedCategories =
        _categoryOrder
            .map((category) => MapEntry(category, _getCategoryTotal(category)))
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final values = sortedCategories.map((entry) => entry.value).toList();
    final colors = sortedCategories
        .map((entry) => _getCategoryColor(entry.key))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월 예산 분포',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
              fontSize: Sizes.size16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(90, 90),
                      painter: _BudgetPieChartPainter(
                        values: values,
                        colors: colors,
                      ),
                    ),
                    Text(
                      monthlyIncome > 0
                          ? '${((totalBudget / monthlyIncome) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16,
                        color: totalBudget > monthlyIncome
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDistributionValueRow(
                      label: '월 총 수입',
                      value: monthlyIncome,
                      showInfo: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDistributionValueRow(
                      label: '지난달 지출',
                      value: _totalExpense,
                    ),
                    const SizedBox(height: 8),
                    _buildDistributionValueRow(
                      label: '총 예산',
                      value: totalBudget,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionValueRow({
    required String label,
    required double value,
    bool showInfo = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w400,
                fontSize: Sizes.size14,
                color: Colors.grey.shade700,
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 4),
              const _InfoTooltipIcon(
                message: '지난달 월급최적화 기능에서 \n입력한 월 총 수입입니다.',
              ),
            ],
          ],
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w600,
            fontSize: Sizes.size12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              fontSize: Sizes.size14,
              color: isBold ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            '\$${NumberFormat('#,###').format(amount.toInt())}',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: Sizes.size14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _saveBudgetToFirestore,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE9435A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save Budget',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w600,
                fontSize: Sizes.size16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetPieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _BudgetPieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    if (total <= 0) {
      canvas.drawOval(rect, backgroundPaint);
      return;
    }

    // 배경 도넛 그리기
    canvas.drawOval(rect, backgroundPaint);

    double startAngle = -math.pi / 2;
    for (int index = 0; index < values.length; index++) {
      final value = values[index];
      if (value <= 0) {
        continue;
      }
      final sweepAngle = (value / total) * math.pi * 2;
      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _BudgetPieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}

class _BudgetGaugeSegment {
  final Color color;
  final int flex;

  _BudgetGaugeSegment({required this.color, required this.flex});
}

class _InfoTooltipIcon extends StatefulWidget {
  final String message;

  const _InfoTooltipIcon({required this.message});

  @override
  State<_InfoTooltipIcon> createState() => _InfoTooltipIconState();
}

class _InfoTooltipIconState extends State<_InfoTooltipIcon> {
  OverlayEntry? _overlayEntry;

  void _toggle(BuildContext context) {
    if (_overlayEntry != null) {
      _hide();
    } else {
      _show(context);
    }
  }

  void _show(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final iconPos = box.localToGlobal(Offset.zero);
    final iconSize = box.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // 투명 배리어 - 외부 탭 시 닫힘
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
            ),
          ),
          // 말풍선
          Positioned(
            left: iconPos.dx - 120,
            top: iconPos.dy - 44,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
    );
  }
}
