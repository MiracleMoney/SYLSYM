import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

/// 카테고리별 예산과 지출을 비교하는 게이지 위젯
class CategoryComparisonGauge extends StatelessWidget {
  const CategoryComparisonGauge({
    super.key,
    required this.selectedCategory,
    required this.currentTotal,
    required this.previousTotal,
    required this.categoryColor,
    required this.formatCurrency,
    this.showShadow = true,
  });

  final String selectedCategory;
  final double currentTotal;
  final double previousTotal;
  final Color categoryColor;
  final String Function(double) formatCurrency;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이번달 $selectedCategory 예산',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(currentTotal),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '지난달 $selectedCategory 지출',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(previousTotal),
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
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBar(
            currentTotal: currentTotal,
            previousTotal: previousTotal,
            categoryColor: categoryColor,
          ),
        ],
      ),
    );
  }
}

/// 진행률 바 위젯
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.currentTotal,
    required this.previousTotal,
    required this.categoryColor,
  });

  final double currentTotal;
  final double previousTotal;
  final Color categoryColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isOverBudget = previousTotal > 0 && currentTotal > previousTotal;
        final progress = previousTotal > 0
            ? (currentTotal / previousTotal).clamp(0.0, 1.0)
            : 0.0;
        final barColor = isOverBudget ? Colors.red : categoryColor;

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 10,
            width: double.infinity,
            color: Colors.grey.shade200,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
