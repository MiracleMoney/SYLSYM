import 'package:flutter/material.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';

class CategoryFilterWidget extends StatefulWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const CategoryFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    final allCategories = ['All'];
    allCategories.addAll(ExpenseCategory.allCategories);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allCategories.map((category) {
          final isSelected = category == _selectedFilter;
          final label = category == 'All'
              ? 'All'
              : ExpenseCategory.getCategoryLabel(category);

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedFilter = category;
                  });
                  widget.onFilterChanged(category);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE9435A)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.black,
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
}
