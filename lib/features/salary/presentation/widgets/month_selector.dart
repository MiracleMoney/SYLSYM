// lib/widgets/common/month_selector.dart
import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: onPreviousMonth,
        ),
        Text(
          '${currentMonth.year}년 ${currentMonth.month}월',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'Gmarket_sans',
            fontSize: Sizes.size16 + Sizes.size2,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: onNextMonth,
        ),
      ],
    );
  }
}
