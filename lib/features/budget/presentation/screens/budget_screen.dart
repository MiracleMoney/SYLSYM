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

  // 카테고리별 확장 상태
  final Map<String, bool> _expandedCategories = {
    '생활비': false,
    '고정비': false,
    '투자': false,
    '저축': false,
    '이자': false,
  };

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
    _saveCurrentSnapshot();
    _loadSalaryResult();
  }

  double _getCategoryTotal(String category) {
    double total = 0;
    for (var controller in _budgetControllers[category]!.values) {
      final value = double.tryParse(controller.text) ?? 0;
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

  void _changeMonth(int months) {
    _saveCurrentSnapshot();
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
    });
    _loadSnapshotForMonth(_selectedMonth);
    _loadSalaryResult();
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

  Future<void> _loadSalaryResult() async {
    setState(() {
      _isSalaryLoading = true;
    });
    try {
      final data = await _firestoreService.loadSalaryData(
        targetDate: _selectedMonth,
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
      backgroundColor: Colors.grey.shade50,
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
                _buildSalaryAllocationSection(),
                const SizedBox(height: 16),
                ..._budgetControllers.keys.map((category) {
                  return _buildCategorySection(category);
                }),
                const SizedBox(height: 24),
                _buildSummarySection(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final isExpanded = _expandedCategories[category] ?? false;
    final categoryTotal = _getCategoryTotal(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: _getCategoryColor(category),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '\$${NumberFormat('#,###').format(categoryTotal.toInt())}',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: Sizes.size16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      children: _budgetControllers[category]!.entries.map((
                        entry,
                      ) {
                        return _buildBudgetItem(
                          category,
                          entry.key,
                          entry.value,
                        );
                      }).toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
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

  Widget _buildSummarySection() {
    final totalBudget = _getTotalBudget();
    final monthlyIncome = double.tryParse(_monthlyIncomeController.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
              fontSize: Sizes.size16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ..._budgetControllers.keys.map((category) {
            final total = _getCategoryTotal(category);
            return _buildSummaryRow(category, total);
          }),
          Divider(height: 24, color: Colors.grey.shade300),
          _buildSummaryRow('Total Budget', totalBudget, isBold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Income',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _monthlyIncomeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w500,
                    fontSize: Sizes.size14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
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
        ],
      ),
    );
  }

  Widget _buildSalaryAllocationSection() {
    final result = _salaryResult;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월급최적화 결과',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
              fontSize: Sizes.size16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (_isSalaryLoading)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  '불러오는 중...',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: Sizes.size12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            )
          else if (result == null)
            Text(
              '이번 달 월급최적화 결과가 없습니다.',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: Sizes.size12,
                color: Colors.grey.shade600,
              ),
            )
          else ...[
            _buildReferenceRow('비상금', result.emergencyFund),
            _buildReferenceRow(
              '투자금',
              result.pensionInvestment + result.retirementInvestment,
            ),
            _buildReferenceRow('단기목표금', result.shortTermGoalSaving),
            _buildReferenceRow('생활비', result.livingExpense),
          ],
        ],
      ),
    );
  }

  Widget _buildReferenceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Text(
            _formatCurrency(amount),
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
              fontSize: Sizes.size14,
              color: Colors.black,
            ),
          ),
        ],
      ),
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
            onPressed: () {
              // TODO: 예산 저장 로직
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Budget saved!')));
            },
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
