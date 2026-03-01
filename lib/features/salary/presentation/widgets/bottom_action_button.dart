import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

class BottomActionButton extends StatelessWidget {
  final bool allFieldsFilled;
  final VoidCallback onNext;
  final VoidCallback onNavigate;
  final FocusNode buttonFocus;
  final String nextButtonText; // 추가
  final String navigateButtonText; // 추가

  const BottomActionButton({
    super.key,
    required this.allFieldsFilled,
    required this.onNext,
    required this.onNavigate,
    required this.buttonFocus,
    this.nextButtonText = 'Next', // 기본값
    this.navigateButtonText = 'Next Step', // 기본값
  });

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.only(
      left: 20,
      right: 20,
      bottom: MediaQuery.of(context).viewInsets.bottom + 12,
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeOut,
      padding: padding,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.06,
          child: allFieldsFilled
              ? ElevatedButton(
                  focusNode: buttonFocus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNavigate, // ✅ 중복 onTapDown 제거
                  child: Text(
                    navigateButtonText,
                    style: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size16,
                    ),
                  ),
                )
              : ElevatedButton(
                  focusNode: buttonFocus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNext, // ✅ 중복 onTapDown 제거
                  child: Text(
                    nextButtonText,
                    style: const TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size16,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
