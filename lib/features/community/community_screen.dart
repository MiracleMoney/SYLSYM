import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          '커뮤니티 화면\n(추후 구현)',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 18),
        ),
      ),
    );
  }
}
