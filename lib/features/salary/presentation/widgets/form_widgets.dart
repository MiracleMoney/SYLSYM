// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

/// 천 단위 콤마 자동 포맷터
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  String _format(String s) {
    if (s.isEmpty) return '';
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    int count = 0;
    for (int i = digits.length - 1; i >= 0; i--) {
      buffer.write(digits[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write(',');
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = _format(newValue.text);
    int selectionIndex =
        formatted.length - (newValue.text.length - newValue.selection.end);
    if (selectionIndex < 0) selectionIndex = 0;
    if (selectionIndex > formatted.length) selectionIndex = formatted.length;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class LabeledTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffixText;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const LabeledTextFormField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
    this.suffixText,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFormatters =
        (keyboardType == TextInputType.number ||
            keyboardType == TextInputType.numberWithOptions())
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ]
        : <TextInputFormatter>[];

    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: Sizes.size16 + Sizes.size2,
      fontFamily: 'Gmarket_sans',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, textAlign: TextAlign.left, style: labelStyle),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ?? defaultFormatters,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Sizes.size8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Sizes.size8),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
            suffixText: suffixText,
            border: OutlineInputBorder(
              gapPadding: 5,
              borderRadius: BorderRadius.circular(Sizes.size8),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
// ...existing code...