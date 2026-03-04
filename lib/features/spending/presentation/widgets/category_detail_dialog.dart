import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';
import 'package:intl/intl.dart';

class CategoryDetailDialog extends StatelessWidget {
  final String category;
  final List<ExpenseModel> expenses;
  final Map<String, double> categoryBudgets;

  const CategoryDetailDialog({
    super.key,
    required this.category,
    required this.expenses,
    required this.categoryBudgets,
  });

  // 세부 항목별 지출 계산
  Map<String, double> _getSubcategoryTotals() {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      if (expense.category == category) {
        totals[expense.subcategory] =
            (totals[expense.subcategory] ?? 0) + expense.amount;
      }
    }
    return totals;
  }

  // 메인 카테고리 예산을 서브카테고리에 지출 비율 기반으로 분배
  Map<String, double> _getSubcategoryBudgets() {
    final categoryKey = _getCategoryKey(category);
    if (categoryKey == null) return {};

    // 메인 카테고리의 총 예산 가져오기
    final mainBudget = categoryBudgets[category] ?? 0;
    if (mainBudget == 0) return {};

    final subcategories = ExpenseCategory.getSubcategories(categoryKey);
    final subcategoryTotals = _getSubcategoryTotals();
    final totalExpense = subcategoryTotals.values.fold(0.0, (a, b) => a + b);

    final Map<String, double> budgets = {};

    if (totalExpense == 0) {
      // 지출이 없으면 서브카테고리에 균등 분배
      final equalBudget = mainBudget / subcategories.length;
      subcategories.forEach((key, label) {
        budgets[key] = equalBudget;
      });
    } else {
      // 지출 비율에 따라 예산 분배 + 최소 예산 보장
      final minBudgetPerCategory = mainBudget * 0.05; // 최소 5%
      double remainingBudget =
          mainBudget - (minBudgetPerCategory * subcategories.length);

      subcategories.forEach((key, label) {
        final expenseAmount = subcategoryTotals[key] ?? 0;
        final proportionalBudget =
            remainingBudget * (expenseAmount / totalExpense);
        budgets[key] = minBudgetPerCategory + proportionalBudget;
      });
    }

    return budgets;
  }

  String? _getCategoryKey(String category) {
    switch (category) {
      case 'FixedExpenses':
        return ExpenseCategory.fixedExpenses;
      case 'LivingExpenses':
        return ExpenseCategory.livingExpenses;
      case 'InvestmentExpenses':
        return ExpenseCategory.investmentExpenses;
      case 'SavingExpenses':
        return ExpenseCategory.savingExpenses;
      case 'InterestExpenses':
        return ExpenseCategory.interestExpenses;
      default:
        return null;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'FixedExpenses':
        return const Color(0xFF5B7EFF);
      case 'LivingExpenses':
        return const Color(0xFF4CAF50);
      case 'InvestmentExpenses':
        return const Color(0xFFFFA726);
      case 'SavingExpenses':
        return const Color(0xFFEC407A);
      case 'InterestExpenses':
        return const Color(0xFFAB47BC);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryKey = _getCategoryKey(category);
    if (categoryKey == null) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    '오류',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size16,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 16),
              const Text('잘못된 카테고리입니다.'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    final subcategories = ExpenseCategory.getSubcategories(categoryKey);
    final subcategoryTotals = _getSubcategoryTotals();
    final subcategoryBudgets = _getSubcategoryBudgets();

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    ExpenseCategory.getCategoryLabel(category),
                    style: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size16,
                    ),
                  ),
                  const SizedBox(width: 48), // IconButton 크기만큼 공간 확보
                ],
              ),
            ),
            // 내용
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subcategoryKey = subcategories.keys.elementAt(index);
                    final subcategoryLabel = subcategories[subcategoryKey]!;
                    final actualAmount = subcategoryTotals[subcategoryKey] ?? 0;
                    final budgetAmount =
                        subcategoryBudgets[subcategoryKey] ?? 0;
                    final percentage = budgetAmount > 0
                        ? (actualAmount / budgetAmount * 100).clamp(0, 100)
                        : 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ExpenseCategory.getCategoryIcon(subcategoryKey),
                            size: 16,
                            color: _getCategoryColor(category),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 75,
                            child: Text(
                              subcategoryLabel,
                              style: const TextStyle(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w600,
                                fontSize: Sizes.size14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '예산',
                                      style: TextStyle(
                                        fontFamily: 'Gmarket_sans',
                                        fontWeight: FontWeight.w500,
                                        fontSize: Sizes.size11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₩${NumberFormat('#,###').format(budgetAmount.toInt())}',
                                      style: const TextStyle(
                                        fontFamily: 'Gmarket_sans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: Sizes.size11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      '지출',
                                      style: TextStyle(
                                        fontFamily: 'Gmarket_sans',
                                        fontWeight: FontWeight.w500,
                                        fontSize: Sizes.size11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '₩${NumberFormat('#,###').format(actualAmount.toInt())}',
                                      style: const TextStyle(
                                        fontFamily: 'Gmarket_sans',
                                        fontWeight: FontWeight.w600,
                                        fontSize: Sizes.size11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (budgetAmount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: percentage > 100
                                    ? Colors.red.withOpacity(0.1)
                                    : percentage > 80
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${percentage.toInt()}%',
                                style: TextStyle(
                                  fontFamily: 'Gmarket_sans',
                                  fontWeight: FontWeight.w600,
                                  fontSize: Sizes.size12,
                                  color: percentage > 100
                                      ? Colors.red
                                      : percentage > 80
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16), // 하단 여백
          ],
        ),
      ),
    );
  }
}

// 다이얼로그를 표시하는 헬퍼 함수
void showCategoryDetailDialog(
  BuildContext context,
  String category,
  List<ExpenseModel> expenses,
  Map<String, double> categoryBudgets,
) {
  showDialog(
    context: context,
    builder: (context) => CategoryDetailDialog(
      category: category,
      expenses: expenses,
      categoryBudgets: categoryBudgets,
    ),
  );
}
