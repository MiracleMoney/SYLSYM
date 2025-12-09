import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '대시보드',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '대시보드 화면\n(추후 구현)',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 18),
        ),
      ),
    );
  }
}
