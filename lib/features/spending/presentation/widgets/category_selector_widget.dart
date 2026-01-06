import 'package:flutter/material.dart';
import 'package:miraclemoney/features/spending/data/constants/expense_category.dart';

class CategorySelectorWidget extends StatefulWidget {
  final Function(String, String) onCategorySelected;
  final String? selectedCategory;
  final String? selectedSubcategory;

  const CategorySelectorWidget({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
    this.selectedSubcategory,
  });

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  late String _selectedCategory;
  late String? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.selectedCategory ?? ExpenseCategory.fixedExpenses;
    _selectedSubcategory = widget.selectedSubcategory;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ExpenseCategory.allCategories.map((category) {
              final isSelected = category == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                        _selectedSubcategory = null;
                      });
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
                        ExpenseCategory.getCategoryLabel(category),
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
        ),
        const SizedBox(height: 16),
        _buildSubcategoryGrid(),
      ],
    );
  }

  Widget _buildSubcategoryGrid() {
    final subcategories = ExpenseCategory.getSubcategories(_selectedCategory);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategoryKey = subcategories.keys.toList()[index];
        final subcategoryLabel = subcategories[subcategoryKey] ?? '';
        final isSelected = _selectedSubcategory == subcategoryKey;
        final icon = ExpenseCategory.getCategoryIcon(subcategoryKey);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedSubcategory = subcategoryKey;
              });
              widget.onCategorySelected(_selectedCategory, subcategoryKey);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5B7EFF)
                      : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected
                        ? const Color(0xFF5B7EFF)
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subcategoryLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF5B7EFF)
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
