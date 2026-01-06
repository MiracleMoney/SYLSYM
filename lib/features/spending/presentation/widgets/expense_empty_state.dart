import 'package:flutter/material.dart';

class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first expense by tapping the + button',
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
