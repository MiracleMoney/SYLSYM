import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'budget_item_card.dart';

/// 선택된 카테고리의 예산 항목 리스트 위젯
class BudgetItemsList extends StatelessWidget {
  const BudgetItemsList({
    super.key,
    required this.items,
    required this.selectedCategory,
    required this.getCategoryColor,
    required this.getExpenseItemIcon,
    required this.getPreviousExpenseValue,
    required this.formatCurrency,
    required this.numberFormatter,
    required this.onItemChanged,
  });

  final Map<String, TextEditingController> items;
  final String selectedCategory;
  final Color Function(String category) getCategoryColor;
  final IconData Function(String category, String label) getExpenseItemIcon;
  final double Function(String category, String label) getPreviousExpenseValue;
  final String Function(double value) formatCurrency;
  final TextInputFormatter numberFormatter;
  final VoidCallback onItemChanged;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: items.entries.map((entry) {
        final label = entry.key;
        final controller = entry.value;
        final categoryColor = getCategoryColor(selectedCategory);
        final iconData = getExpenseItemIcon(selectedCategory, label);
        final previousExpense = getPreviousExpenseValue(
          selectedCategory,
          label,
        );
        final previousExpenseText = '지난달 지출 ${formatCurrency(previousExpense)}';

        return BudgetItemCard(
          label: label,
          controller: controller,
          categoryColor: categoryColor,
          iconData: iconData,
          previousExpenseText: previousExpenseText,
          numberFormatter: numberFormatter,
          onChanged: onItemChanged,
        );
      }).toList(),
    );
  }
}
