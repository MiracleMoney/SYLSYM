import 'package:flutter/material.dart';

class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.15; // 화면 너비의 15%

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: iconSize,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 기록된 지출이 없어요',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+ 버튼을 눌러 첫 지출을 추가해보세요!',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
