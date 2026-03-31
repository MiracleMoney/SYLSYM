import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

/// 개별 예산 항목 카드 위젯
class BudgetItemCard extends StatefulWidget {
  const BudgetItemCard({
    super.key,
    required this.label,
    required this.controller,
    required this.categoryColor,
    required this.iconData,
    required this.previousExpenseText,
    required this.numberFormatter,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final Color categoryColor;
  final IconData iconData;
  final String previousExpenseText;
  final TextInputFormatter numberFormatter;
  final VoidCallback onChanged;

  @override
  State<BudgetItemCard> createState() => _BudgetItemCardState();
}

class _BudgetItemCardState extends State<BudgetItemCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    // 초기값 설정 불필요 — 이미 '0'
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      // 포커스 진입: "0"이면 비움 (콤마는 유지 — 실시간 포맷)
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: widget.categoryColor, width: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.iconData,
                color: widget.categoryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      fontSize: Sizes.size14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.previousExpenseText,
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      fontSize: Sizes.size10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enableInteractiveSelection: false,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w400,
                  fontSize: Sizes.size14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  prefixText: '₩ ',
                  prefixStyle: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade600,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE9435A)),
                  ),
                  hintText: '0\u00A0',
                  hintStyle: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade400,
                  ),
                ),
                onChanged: (value) {
                  // 숫자만 추출
                  String digits = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (digits.isNotEmpty) {
                    int number = int.parse(digits);
                    String formatted = number.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (match) => '${match[1]},',
                    );

                    if (widget.controller.text != formatted) {
                      widget.controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  }
                  widget.onChanged();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
