import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';

class BottomActionButton extends StatelessWidget {
  final bool allFieldsFilled;
  final VoidCallback onNext;
  final VoidCallback onNavigate;
  final FocusNode buttonFocus;

  const BottomActionButton({
    super.key,
    required this.allFieldsFilled,
    required this.onNext,
    required this.onNavigate,
    required this.buttonFocus,
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
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (_) => onNavigate(),
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
                          onPressed: onNavigate,
                          child: const Text('Next Step'),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (_) => onNext(),
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
                    onPressed: onNext,
                    child: const Text('Next'),
                  ),
                ),
        ),
      ),
    );
  }
}
