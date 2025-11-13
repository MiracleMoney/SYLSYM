import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_widgets.dart'; // LabeledTextFormField, ThousandsSeparatorInputFormatter 경로 맞춰서 조정

class NumberInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String? suffixText;
  final bool allowDecimal;
  final TextInputAction? action;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const NumberInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    this.suffixText,
    this.allowDecimal = false,
    this.action,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFormatters = allowDecimal
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ]
        : <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ];

    return LabeledTextFormField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.number,
      inputFormatters: inputFormatters ?? defaultFormatters,
      suffixText: suffixText,
      focusNode: focusNode,
      textInputAction: action ?? TextInputAction.next,
      onFieldSubmitted: (_) {
        Future.microtask(() {
          if (!context.mounted) return;
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        });
      },
      validator: validator,
    );
  }
}
