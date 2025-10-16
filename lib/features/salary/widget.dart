import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';

class LabeledTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final FormFieldSetter<String>? onSaved;
  final TextInputType keyboardType;

  const LabeledTextFormField({
    super.key,
    required this.label,
    required this.hint,
    this.onSaved,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
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
          onSaved: onSaved,
        ),
      ],
    );
  }
}
