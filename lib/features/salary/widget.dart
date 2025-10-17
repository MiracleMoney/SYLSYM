import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/constants/sizes.dart';

class LabeledTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const LabeledTextFormField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFormatters =
        (keyboardType == TextInputType.number ||
            keyboardType == TextInputType.numberWithOptions())
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[\d\.,]')),
          ]
        : <TextInputFormatter>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters ?? defaultFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Sizes.size8),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
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
