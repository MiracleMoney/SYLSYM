import 'package:flutter/material.dart';

class SalaryStep2Screen extends StatefulWidget {
  const SalaryStep2Screen({super.key});

  @override
  State<SalaryStep2Screen> createState() => _SalaryStep2ScreenState();
}

class _SalaryStep2ScreenState extends State<SalaryStep2Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('월급최적화 2단계')),
      body: const Center(child: Text('Salary Step 2 Screen')),
    );
  }
}
