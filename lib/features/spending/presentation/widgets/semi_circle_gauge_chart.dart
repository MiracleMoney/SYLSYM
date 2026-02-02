import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'dart:math' as math;
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

  double _getBudgetPercentage() {
    final total = _getTotalAmount();
    if (budget == null) return 0; // 예산 데이터 없음
    if (budget == 0) return 0;
    return (total / budget!) * 100;
  }

  String _getPercentageText() {
    if (budget == null) {
      final monthName = '${selectedMonth.month}월';
      return '$monthName의 수입 데이터 없음';
    }
    return '${_getBudgetPercentage().toStringAsFixed(1)}%';
  }

  Color _getPercentageColor() {
    if (budget == null) {
      return Colors.grey.shade600;
    }
    return _getBudgetPercentage() > 100
        ? const Color(0xFFE9435A)
        : Colors.grey.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final total = _getTotalAmount();
    final categoryAmounts = _getCategoryAmounts();
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = screenHeight * 0.2; // 화면 높이의 20%

    return Container(
      padding: const EdgeInsets.all(24),
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
          Text(
            '내 지출 현황',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
              fontSize: Sizes.size16,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              painter: _SemiCircleGaugePainter(
                categoryAmounts: categoryAmounts,
                total: total,
                colorMap: _getCategoryColorMap(),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: chartHeight * 0.55),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getPercentageText(),
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w600,
                          fontSize: budget == null
                              ? Sizes.size12
                              : Sizes.size16,
                          color: _getPercentageColor(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₩${NumberFormat('#,###').format(total.toInt())}',
                        style: const TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                          fontSize: Sizes.size24,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemiCircleGaugePainter extends CustomPainter {
  final Map<String, double> categoryAmounts;
  final double total;
  final Map<String, Color> colorMap;

  _SemiCircleGaugePainter({
    required this.categoryAmounts,
    required this.total,
    required this.colorMap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2.5;
    final strokeWidth = 35.0;

    if (total == 0) {
      // 데이터가 없을 때 회색 반원
      final paint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        math.pi,
        math.pi,
        false,
        paint,
      );
      return;
    }

    double startAngle = math.pi;

    // 금액이 큰 순서대로 정렬
    final sortedEntries = categoryAmounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      final sweepAngle = (entry.value / total) * math.pi;
      final categoryColor =
          colorMap[entry.key] ?? Colors.grey; // 카테고리에 해당하는 색상 사용
      final paint = Paint()
        ..color = categoryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
