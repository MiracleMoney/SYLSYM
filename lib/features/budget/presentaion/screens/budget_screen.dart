import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '예산 화면\n(추후 구현)',
        textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 18),
      ),
    );
  }
}
