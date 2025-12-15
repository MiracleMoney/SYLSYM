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
          child: allFieldsFilled
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    focusNode: buttonFocus,
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: Sizes.size16 + Sizes.size2,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                    ),
                    onPressed: onNavigate, // ✅ 중복 onTapDown 제거
                    child: Text(navigateButtonText),
                  ),
                )
              : ElevatedButton(
                  focusNode: buttonFocus,
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: Sizes.size16 + Sizes.size2,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: onNext, // ✅ 중복 onTapDown 제거
                  child: Text(nextButtonText),
                ),
        ),
      ),
    );
  }
}
