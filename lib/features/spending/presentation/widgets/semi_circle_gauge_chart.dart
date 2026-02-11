import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';
import 'package:intl/intl.dart';

class SemiCircleGaugeChart extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final DateTime selectedMonth;
  final double? budget; // 예산 (나중에 Firebase에서 가져올 예정)

  const SemiCircleGaugeChart({
    super.key,
    required this.expenses,
    required this.selectedMonth,
    this.budget,
  });

  double _getTotalAmount() {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> _getCategoryAmounts() {
    final Map<String, double> categoryAmounts = {};
    for (final expense in expenses) {
      categoryAmounts[expense.category] =
          (categoryAmounts[expense.category] ?? 0) + expense.amount;
    }
    return categoryAmounts;
  }

  Map<String, Color> _getCategoryColorMap() {
    return {
      ExpenseCategory.fixedExpenses: const Color(0xFF5B7EFF), // 고정비 - 파랑
      ExpenseCategory.livingExpenses: const Color(0xFF4CAF50), // 생활비 - 초록
      ExpenseCategory.investmentExpenses: const Color(0xFFFFA726), // 투자 - 노랑
      ExpenseCategory.savingExpenses: const Color(0xFFEC407A), // 저축 - 빨강
      ExpenseCategory.interestExpenses: const Color(0xFFAB47BC), // 이자 - 보라
    };
  }

  String _formatCurrency(num amount) {
    return '₩${NumberFormat('#,###').format(amount.toInt())}';
  }

  @override
  Widget build(BuildContext context) {
    final total = _getTotalAmount();
    final categoryAmounts = _getCategoryAmounts();
    final screenHeight = MediaQuery.of(context).size.height;
    // final chartHeight = screenHeight * 0.18; // 화면 높이의 18%
    final sortedEntries = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final incomeAmount = budget ?? 0;
    final remainingAmount = incomeAmount - total;

    return Column(
      children: [
        Text(
          _formatCurrency(total),
          style: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size28,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 20,
          ),
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '남은 금액',
                            style: TextStyle(
                              fontFamily: 'Gmarket_sans',
                              fontWeight: FontWeight.w500,
                              fontSize: Sizes.size12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(remainingAmount),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '내 수입',
                            style: TextStyle(
                              fontFamily: 'Gmarket_sans',
                              fontWeight: FontWeight.w500,
                              fontSize: Sizes.size12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(incomeAmount),
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
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 10,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (total == 0 || incomeAmount <= 0) {
                      return Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }

                    var segments = sortedEntries
                        .where((entry) => entry.value > 0)
                        .map(
                          (entry) => _BarSegment(
                            color:
                                _getCategoryColorMap()[entry.key] ??
                                Colors.grey,
                            flex: ((entry.value / incomeAmount) * 1000).round(),
                          ),
                        )
                        .where((segment) => segment.flex > 0)
                        .toList();

                    var totalFlex = segments.fold<int>(
                      0,
                      (sum, item) => sum + item.flex,
                    );

                    if (totalFlex == 0) {
                      return Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      );
                    }

                    if (totalFlex > 1000) {
                      final scale = 1000 / totalFlex;
                      segments = segments
                          .map(
                            (segment) => _BarSegment(
                              color: segment.color,
                              flex: (segment.flex * scale).round(),
                            ),
                          )
                          .where((segment) => segment.flex > 0)
                          .toList();
                      totalFlex = segments.fold<int>(
                        0,
                        (sum, item) => sum + item.flex,
                      );
                    }

                    final remainingFlex = (1000 - totalFlex).clamp(0, 1000);

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 16,
                        color: Colors.grey.shade200,
                        child: Row(
                          children: [
                            ...segments.map(
                              (segment) => Expanded(
                                flex: segment.flex > 0 ? segment.flex : 1,
                                child: Container(color: segment.color),
                              ),
                            ),
                            if (remainingFlex > 0)
                              Expanded(
                                flex: remainingFlex,
                                child: const SizedBox.shrink(),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BarSegment {
  final Color color;
  final int flex;

  _BarSegment({required this.color, required this.flex});
}
