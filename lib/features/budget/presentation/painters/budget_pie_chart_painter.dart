import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 예산 분포를 도넛 차트로 그리는 커스텀 페인터
class BudgetPieChartPainter extends CustomPainter {
  const BudgetPieChartPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (sum, value) => sum + value);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    if (total <= 0) {
      canvas.drawOval(rect, backgroundPaint);
      return;
    }

    // 배경 도넛 그리기
    canvas.drawOval(rect, backgroundPaint);

    const gapAngle = 0.06; // 세그먼트 사이 간격 (라디안)
    const minAngle = 0.01; // 최소 세그먼트 각도
    final nonZeroCount = values.where((v) => v > 0).length;

    double startAngle = -math.pi / 2;
    for (int index = 0; index < values.length; index++) {
      final value = values[index];
      if (value <= 0) {
        continue;
      }
      final totalSweep = (value / total) * math.pi * 2;

      // 세그먼트가 여러 개일 때만 gap 적용하고, 유효한 각도 범위로 제한
      double sweepAngle;
      if (nonZeroCount > 1) {
        sweepAngle = (totalSweep - gapAngle).clamp(
          minAngle,
          math.max(minAngle, totalSweep),
        );
      } else {
        sweepAngle = math.max(minAngle, totalSweep);
      }

      // 각도가 유효하지 않으면 skip
      if (sweepAngle <= 0 || sweepAngle.isNaN || sweepAngle.isInfinite) {
        continue;
      }

      final paint = Paint()
        ..color = colors[index % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle + gapAngle / 2, sweepAngle, false, paint);
      startAngle += totalSweep;
    }
  }

  @override
  bool shouldRepaint(covariant BudgetPieChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.colors != colors;
  }
}
