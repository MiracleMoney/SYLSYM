import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import '../painters/budget_pie_chart_painter.dart';
import 'info_tooltip_icon.dart';

/// 예산 분포를 시각화하는 카드 위젯
class BudgetDistributionCard extends StatelessWidget {
  const BudgetDistributionCard({
    super.key,
    required this.categoryOrder,
    required this.getCategoryTotalForChart,
    required this.getCategoryColor,
    required this.formatCurrency,
    required this.monthlyIncome,
    required this.totalExpense,
    required this.totalBudget,
    required this.totalBudgetForChart,
  });

  final List<String> categoryOrder;
  final double Function(String category) getCategoryTotalForChart;
  final Color Function(String category) getCategoryColor;
  final String Function(double value) formatCurrency;
  final double monthlyIncome;
  final double totalExpense;
  final double totalBudget;
  final double totalBudgetForChart;

  @override
  Widget build(BuildContext context) {
    final sortedCategories =
        categoryOrder
            .map(
              (category) =>
                  MapEntry(category, getCategoryTotalForChart(category)),
            )
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final values = sortedCategories.map((entry) => entry.value).toList();
    final colors = sortedCategories
        .map((entry) => getCategoryColor(entry.key))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월 예산 분포',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
              fontSize: Sizes.size16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: BudgetPieChartPainter(
                        values: values,
                        colors: colors,
                      ),
                    ),
                    Text(
                      monthlyIncome > 0
                          ? '${((totalBudgetForChart / monthlyIncome) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16,
                        color: totalBudgetForChart > monthlyIncome
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DistributionValueRow(
                      label: '월 총 수입',
                      value: formatCurrency(monthlyIncome),
                      showInfo: true,
                    ),
                    const SizedBox(height: 8),
                    _DistributionValueRow(
                      label: '지난달 지출',
                      value: formatCurrency(totalExpense),
                    ),
                    const SizedBox(height: 8),
                    _DistributionValueRow(
                      label: '총 예산',
                      value: formatCurrency(totalBudget),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 분포 값 행 위젯
class _DistributionValueRow extends StatelessWidget {
  const _DistributionValueRow({
    required this.label,
    required this.value,
    this.showInfo = false,
  });

  final String label;
  final String value;
  final bool showInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w400,
                fontSize: Sizes.size14,
                color: Colors.grey.shade700,
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 4),
              const InfoTooltipIcon(
                message: '지난달 월급최적화 기능에서 \\n입력한 월 총 수입입니다.',
              ),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w600,
            fontSize: Sizes.size12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
