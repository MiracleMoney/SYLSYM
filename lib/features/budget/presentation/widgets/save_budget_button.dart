import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

/// 예산 저장 버튼 위젯
class SaveBudgetButton extends StatelessWidget {
  const SaveBudgetButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.06,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              '저장',
              style: const TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
                fontSize: Sizes.size16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
