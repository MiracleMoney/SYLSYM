import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/category_detail_dialog.dart';
import 'package:intl/intl.dart';

class CategoryBudgetWidget extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final Map<String, double> categoryBudgets;

  const CategoryBudgetWidget({
    super.key,
    required this.expenses,
    required this.categoryBudgets,
  });

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  // 예산 데이터를 가져오는 메서드 (이제 props에서 직접 가져옴)
  Map<String, double> _getCategoryBudgets() {
    return {
      ExpenseCategory.fixedExpenses: categoryBudgets['FixedExpenses'] ?? 0,
      ExpenseCategory.livingExpenses: categoryBudgets['LivingExpenses'] ?? 0,
      ExpenseCategory.investmentExpenses:
          categoryBudgets['InvestmentExpenses'] ?? 0,
      ExpenseCategory.savingExpenses: categoryBudgets['SavingExpenses'] ?? 0,
      ExpenseCategory.interestExpenses:
          categoryBudgets['InterestExpenses'] ?? 0,
    };
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'FixedExpenses':
        return Icons.home;
      case 'LivingExpenses':
        return Icons.shopping_cart;
      case 'InvestmentExpenses':
        return Icons.trending_up;
      case 'SavingExpenses':
        return Icons.savings;
      case 'InterestExpenses':
        return Icons.percent;
      default:
        return Icons.receipt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _getCategoryTotals();
    final categoryBudgets = _getCategoryBudgets();
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth > 600
        ? screenWidth * 0.06
        : screenWidth * 0.12;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: ExpenseCategory.allCategories.length,
      itemBuilder: (context, index) {
        final category = ExpenseCategory.allCategories[index];
        final actual = categoryTotals[category] ?? 0;
        final budget = categoryBudgets[category] ?? 0;
        final percentage = budget > 0
            ? (actual / budget * 100).clamp(0, 100)
            : 0;
        final isOverBudget = actual > budget;

        return GestureDetector(
          onTap: () => showCategoryDetailDialog(
            context,
            category,
            expenses,
            categoryBudgets,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 60, // 고정 너비로 백분율 표시 영역 고정
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        '${percentage.toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                          fontSize: Sizes.size14,
                          color: isOverBudget
                              ? Colors.red
                              : percentage > 80
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Text(
                    //   ExpenseCategory.getCategoryLabel(category),
                    //   style: const TextStyle(
                    //     fontFamily: 'Gmarket_sans',
                    //     fontWeight: FontWeight.w700,
                    //     fontSize: Sizes.size14,
                    //   ),
                    // ),
                    const SizedBox(width: 24),
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
                                  fontSize: Sizes.size12 + Sizes.size1,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₩${NumberFormat('#,###').format(budget.toInt())}',
                                style: const TextStyle(
                                  fontFamily: 'Gmarket_sans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: Sizes.size12,
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
                                  fontSize: Sizes.size12 + Sizes.size1,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₩${NumberFormat('#,###').format(actual.toInt())}',
                                style: const TextStyle(
                                  fontFamily: 'Gmarket_sans',
                                  fontWeight: FontWeight.w500,
                                  fontSize: Sizes.size12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
