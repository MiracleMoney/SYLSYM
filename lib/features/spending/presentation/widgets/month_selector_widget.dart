import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthSelectorWidget extends StatelessWidget {
  final DateTime selectedMonth;
  final Function(DateTime) onMonthChanged;

  const MonthSelectorWidget({
    super.key,
    required this.selectedMonth,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            onPressed: () {
              final previousMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
              );
              onMonthChanged(previousMonth);
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 28),
            onPressed: () {
              final nextMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
              );
              onMonthChanged(nextMonth);
            },
          ),
        ],
      ),
    );
  }
}
