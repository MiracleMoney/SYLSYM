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

  List<Color> _getCategoryColors() {
    return [
      const Color(0xFF5B7EFF), // 고정비
      const Color(0xFF4CAF50), // 생활비
      const Color(0xFFFFA726), // 투자
      const Color(0xFFEC407A), // 저축
      const Color(0xFFAB47BC), // 이자
    ];
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _SemiCircleGaugePainter(
                categoryAmounts: categoryAmounts,
                total: total,
                colors: _getCategoryColors(),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: Sizes.size60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getPercentageText(),
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w600,
                          fontSize: budget == null ? 13 : 16,
                          color: _getPercentageColor(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₩${NumberFormat('#,###').format(total.toInt())}',
                        style: const TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
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
  final List<Color> colors;

  _SemiCircleGaugePainter({
    required this.categoryAmounts,
    required this.total,
    required this.colors,
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
    int colorIndex = 0;

    for (final entry in categoryAmounts.entries) {
      final sweepAngle = (entry.value / total) * math.pi;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
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
      colorIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
