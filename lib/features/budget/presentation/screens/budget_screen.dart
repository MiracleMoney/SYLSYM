import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:intl/intl.dart';
import 'package:miraclemoney/data/services/firestore_service.dart';
import 'package:miraclemoney/data/models/salary/salary_result_data.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';

// 분리된 위젯들 import
import '../widgets/budget_distribution_card.dart';
import '../widgets/category_selector.dart';
import '../widgets/category_comparison_gauge.dart';
import '../widgets/budget_items_list.dart';
import '../widgets/save_budget_button.dart';
import '../widgets/sticky_header_delegate.dart';
import '../helpers/number_input_formatter.dart';

class BudgetScreen extends StatefulWidget {
  final bool isFocused;
  const BudgetScreen({super.key, this.isFocused = false});

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
  Map<String, Map<String, double>> _previousItemExpenses = {};

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

  @override
  void didUpdateWidget(covariant BudgetScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 현재 탭으로 돌아왔을 때 데이터를 다시 불러옵니다.
    if (widget.isFocused && !oldWidget.isFocused) {
      _loadBudgetFromFirestore(_selectedMonth);
      _loadSalaryResult();
      _loadExpenses();
    }
  }

  double _getCategoryTotal(String category) {
    double total = 0;
    final controllers = _budgetControllers[category];
    if (controllers == null) return 0.0;

    for (var controller in controllers.values) {
      try {
        final rawText = controller.text.replaceAll(',', '');
        final value = double.tryParse(rawText) ?? 0;
        if (value.isFinite) {
          total += value;
        }
      } catch (e) {
        // TextEditingController 접근 오류 시 0으로 처리
        continue;
      }
    }
    return total;
  }

  // 도넛차트 전용: 500원 미만은 제외
  double _getCategoryTotalForChart(String category) {
    double total = 0;
    final controllers = _budgetControllers[category];
    if (controllers == null) return 0.0;

    for (var controller in controllers.values) {
      try {
        final rawText = controller.text.replaceAll(',', '');
        final value = double.tryParse(rawText) ?? 0;
        // 개별 항목이 500원 이상일때만 합계에 포함
        if (value >= 500 && value.isFinite) {
          total += value;
        }
      } catch (e) {
        // TextEditingController 접근 오류 시 0으로 처리
        continue;
      }
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
      final categoryTotal = _getCategoryTotal(category);
      if (categoryTotal.isFinite) {
        total += categoryTotal;
      }
    }
    return total;
  }

  // 도넛차트 전용: 500원 미만은 제외
  double _getTotalBudgetForChart() {
    double total = 0;
    for (var category in _budgetControllers.keys) {
      final categoryTotal = _getCategoryTotalForChart(category);
      if (categoryTotal.isFinite) {
        total += categoryTotal;
      }
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
      final Map<String, Map<String, double>> itemTotals = {};

      for (final data in expensesData) {
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final category = data['category'] as String? ?? '';
        final subcategory = data['subcategory'] as String? ?? '';

        total += amount;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;

        // 항목별 지출 집계
        if (category.isNotEmpty && subcategory.isNotEmpty) {
          if (itemTotals[category] == null) {
            itemTotals[category] = {};
          }
          final categoryMap = itemTotals[category];
          if (categoryMap != null) {
            categoryMap[subcategory] = (categoryMap[subcategory] ?? 0) + amount;
          }
        }
      }

      if (mounted)
        setState(() {
          _totalExpense = total;
          _previousCategoryExpenses = categoryTotals;
          _previousItemExpenses = itemTotals;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _totalExpense = 0;
          _previousCategoryExpenses = {};
          _previousItemExpenses = {};
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
        try {
          final rawText = controller.text.replaceAll(',', '');
          final value = double.tryParse(rawText) ?? 0;
          final categoryMap = snapshot[category];
          if (categoryMap != null && value.isFinite) {
            categoryMap[label] = value;
          }
        } catch (e) {
          // TextEditingController 접근 오류 시 0으로 처리
          final categoryMap = snapshot[category];
          if (categoryMap != null) {
            categoryMap[label] = 0.0;
          }
        }
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
        try {
          final value = snapshot?[category]?[label] ?? 0;
          final roundedValue = value.round();
          if (roundedValue == 0) {
            controller.text = '0';
          } else {
            controller.text = NumberFormat('#,###').format(roundedValue);
          }
        } catch (e) {
          // TextEditingController 접근 오류 시 기본값 설정
          controller.text = '0';
        }
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

  double _getPreviousExpenseValue(String category, String label) {
    final categoryKey = _getExpenseCategoryKey(category) ?? category;
    final itemKey = _getSubcategoryKey(categoryKey, label);
    return _previousItemExpenses[categoryKey]?[itemKey] ?? 0;
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
            final roundedValue = ((value ?? 0) as num).round();
            if (roundedValue == 0) {
              controller.text = '0';
            } else {
              controller.text = NumberFormat('#,###').format(roundedValue);
            }
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
          final rawText = controller.text.replaceAll(',', '');
          categoryData[itemKey] = double.tryParse(rawText) ?? 0;
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
    if (!value.isFinite) {
      return '₩0';
    }
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                              ),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Text(
                              '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                              style: TextStyle(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w500,
                                fontSize: Sizes.size16 + Sizes.size2,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right,
                                color: Colors.black,
                              ),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          BudgetDistributionCard(
                            categoryOrder: _categoryOrder,
                            getCategoryTotalForChart: _getCategoryTotalForChart,
                            getCategoryColor: _getCategoryColor,
                            formatCurrency: _formatCurrency,
                            monthlyIncome: _salaryResult?.totalIncome ?? 0,
                            totalExpense: _totalExpense,
                            totalBudget: _getTotalBudget(),
                            totalBudgetForChart: _getTotalBudgetForChart(),
                          ),
                          const SizedBox(height: 24),
                          CategorySelector(
                            categories: _categoryOrder,
                            selectedCategory: _selectedCategory,
                            onCategorySelected: (category) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyHeaderDelegate(
                      height: 100, // 넉넉한 높이 할당
                      childBuilder: (showShadow) {
                        final currentTotal = _getCategoryTotal(
                          _selectedCategory,
                        );
                        final categoryKey =
                            _getExpenseCategoryKey(_selectedCategory) ??
                            _selectedCategory;
                        final previousTotal =
                            _previousCategoryExpenses[categoryKey] ?? 0.0;
                        final categoryColor = _getCategoryColor(
                          _selectedCategory,
                        );

                        // null 안전성 확보
                        final safeCurrentTotal = currentTotal.isFinite
                            ? currentTotal
                            : 0.0;
                        final safePreviousTotal = previousTotal.isFinite
                            ? previousTotal
                            : 0.0;

                        return Container(
                          height: 100, // 고정 높이
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: CategoryComparisonGauge(
                              selectedCategory: _selectedCategory,
                              currentTotal: safeCurrentTotal,
                              previousTotal: safePreviousTotal,
                              categoryColor: categoryColor,
                              formatCurrency: _formatCurrency,
                              showShadow: showShadow,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          BudgetItemsList(
                            items: _budgetControllers[_selectedCategory] ?? {},
                            selectedCategory: _selectedCategory,
                            getCategoryColor: _getCategoryColor,
                            getExpenseItemIcon: _getExpenseItemIcon,
                            getPreviousExpenseValue: _getPreviousExpenseValue,
                            formatCurrency: _formatCurrency,
                            numberFormatter:
                                NumberInputFormatter.getCommaFormatter(),
                            onItemChanged: () => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SaveBudgetButton(onPressed: _saveBudgetToFirestore),
          ],
        ),
      ),
    );
  }
}
