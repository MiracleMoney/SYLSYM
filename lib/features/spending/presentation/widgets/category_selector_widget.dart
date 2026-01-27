import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
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
        widget.selectedCategory ?? ExpenseCategory.livingExpenses;
    _selectedSubcategory = widget.selectedSubcategory;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size16 + Sizes.size2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: ExpenseCategory.allCategories.map((category) {
              final isSelected = category == _selectedCategory;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFFE9435A)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ExpenseCategory.getCategoryLabel(category),
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 12,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.07; // 화면 너비의 7%
    final crossAxisCount = screenWidth > 400 ? 3 : 2; // 화면 크기에 따라 2~3개

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
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
                color: isSelected ? Colors.white : Colors.white,
                border: Border.all(
                  color: isSelected ? Color(0xFFE9435A) : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: iconSize,
                    color: isSelected
                        ? Color(0xFFE9435A)
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
                      fontSize: Sizes.size12,
                      color: isSelected ? Color(0xFFE9435A) : Colors.black,
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
