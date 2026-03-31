import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_widgets.dart'; // LabeledTextFormField, ThousandsSeparatorInputFormatter 경로 맞춰서 조정

class NumberInputField extends StatefulWidget {
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
  final bool defaultZero;

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
    this.defaultZero = false,
  });

  @override
  State<NumberInputField> createState() => _NumberInputFieldState();
}

class _NumberInputFieldState extends State<NumberInputField> {
  @override
  void initState() {
    super.initState();
    if (widget.defaultZero) {
      widget.focusNode.addListener(_handleFocusChange);
      // 초기값이 비어있으면 '0' 설정
      if (widget.controller.text.isEmpty) {
        widget.controller.text = '0';
      }
    }
  }

  @override
  void dispose() {
    if (widget.defaultZero) {
      widget.focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (widget.focusNode.hasFocus) {
      // 포커스 진입: "0"이면 비움 → hintText '0'이 흐릿하게 표시됨
      final raw = widget.controller.text.replaceAll(',', '');
      if (raw == '0' || raw.isEmpty) {
        widget.controller.clear();
      }
    } else {
      // 포커스 해제: 비어있으면 "0" 복원
      final raw = widget.controller.text.replaceAll(',', '');
      if (raw.isEmpty || (int.tryParse(raw) ?? 0) == 0) {
        widget.controller.text = '0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultFormatters = widget.allowDecimal
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ]
        : <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ];

    return LabeledTextFormField(
      label: widget.label,
      hint: widget.defaultZero ? '' : widget.hint,
      hintZero: widget.defaultZero,
      controller: widget.controller,
      keyboardType: widget.keyboardType ?? TextInputType.number,
      inputFormatters: widget.inputFormatters ?? defaultFormatters,
      suffixText: widget.suffixText,
      focusNode: widget.focusNode,
      textInputAction: widget.action ?? TextInputAction.next,
      onFieldSubmitted: (_) {
        Future.microtask(() {
          if (!context.mounted) return;
          if (widget.nextFocus != null) {
            FocusScope.of(context).requestFocus(widget.nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        });
      },
      validator: widget.validator,
    );
  }
}
