import 'package:flutter/material.dart';

class SpendingScreen extends StatelessWidget {
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '지출',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '지출 화면\n(추후 구현)',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 18),
        ),
      ),
    );
  }
}
