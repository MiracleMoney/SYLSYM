import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';
import 'package:intl/intl.dart';

class CategoryBudgetWidget extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const CategoryBudgetWidget({super.key, required this.expenses});

  Map<String, double> _getCategoryTotals() {
    final Map<String, double> totals = {};
    for (final expense in expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  // 임시 예산 데이터 (나중에 예산 기능에서 가져올 예정)
  Map<String, double> _getCategoryBudgets() {
    return {
      ExpenseCategory.fixedExpenses: 0,
      ExpenseCategory.livingExpenses: 0,
      ExpenseCategory.investmentExpenses: 0,
      ExpenseCategory.savingExpenses: 0,
      ExpenseCategory.interestExpenses: 0,
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
    final iconSize = screenWidth * 0.12; // 화면 너비의 12%
    final progressBarHeight = screenWidth * 0.02; // 화면 너비의 2%

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

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ExpenseCategory.getCategoryLabel(category),
                          style: const TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontWeight: FontWeight.w700,
                            fontSize: Sizes.size16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₩${NumberFormat('#,###').format(actual.toInt())}',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontWeight: FontWeight.w500,
                            fontSize: Sizes.size14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₩${NumberFormat('#,###').format(budget.toInt())}',
                        style: const TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '예산 기능은 곧 제공될 예정입니다',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        minHeight: progressBarHeight,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOverBudget
                              ? Colors.red
                              : percentage > 80
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${percentage.toInt()}%',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isOverBudget
                          ? Colors.red
                          : percentage > 80
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
