import 'package:flutter/material.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';
import 'package:intl/intl.dart';

class TotalExpenseCard extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const TotalExpenseCard({super.key, required this.expenses});

  double _getTotalExpenses() {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> _getExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      final label = ExpenseCategory.getCategoryLabel(expense.category);
      categoryTotals[label] = (categoryTotals[label] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final total = _getTotalExpenses();
    final categoryTotals = _getExpensesByCategory();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B7EFF), Color(0xFF3D5CE8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B7EFF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Expenses',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$ ${NumberFormat('#,###.##').format(total)}',
            style: const TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (categoryTotals.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categoryTotals.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${entry.key}: \$${NumberFormat('#,###').format(entry.value.toInt())}',
                    style: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
