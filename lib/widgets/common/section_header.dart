// lib/widgets/common/section_header.dart
import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final double? fontSize;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: fontSize ?? Sizes.size20,
          ),
        ),
      ],
    );
  }
}
