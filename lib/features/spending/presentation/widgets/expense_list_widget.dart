import 'package:flutter/material.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';
import 'package:intl/intl.dart';

class ExpenseListWidget extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final Function(ExpenseModel)? onExpenseTap;

  const ExpenseListWidget({
    super.key,
    required this.expenses,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜순으로 정렬
    final sortedExpenses = [...expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    // 날짜별로 그룹화
    final Map<String, List<ExpenseModel>> groupedByDate = {};
    for (final expense in sortedExpenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.date);
      groupedByDate.putIfAbsent(dateKey, () => []).add(expense);
    }

    return Column(
      children: groupedByDate.entries.map((entry) {
        final dateKey = entry.key;
        final dateExpenses = entry.value;
        final date = DateTime.parse(dateKey);
        final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        final weekday = weekdays[date.weekday - 1];
        final dateLabel =
            '${date.year}년 ${date.month}월 ${date.day}일 ($weekday)';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateLabel,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...dateExpenses.map((expense) => _buildExpenseItem(expense)),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense) {
    final icon = ExpenseCategory.getCategoryIcon(expense.subcategory);
    final categoryLabel = ExpenseCategory.getCategoryLabel(expense.category);
    final subcategoryLabel = ExpenseCategory.getSubcategoryLabel(
      expense.category,
      expense.subcategory,
    );

    return GestureDetector(
      onTap: () => onExpenseTap?.call(expense),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF5B7EFF), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryLabel • $subcategoryLabel',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '- ₩${NumberFormat('#,###').format(expense.amount.toInt())}',
              style: const TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFFE9435A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
