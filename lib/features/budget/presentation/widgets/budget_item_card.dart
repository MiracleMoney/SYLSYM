import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

/// 개별 예산 항목 카드 위젯
class BudgetItemCard extends StatelessWidget {
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
                border: Border.all(color: categoryColor, width: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(iconData, color: categoryColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      fontSize: Sizes.size14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    previousExpenseText,
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
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                onTap: () {
                  // 현재 값이 '0'이면 텍스트 지우기
                  if (controller.text == '0') {
                    controller.clear();
                  }
                },
                // inputFormatters: [numberFormatter], // 임시 제거
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
                ),
                onChanged: (value) {
                  // 숫자만 추출
                  String digits = value.replaceAll(RegExp(r'[^\d]'), '');
                  if (digits.isNotEmpty) {
                    // 콤마 포맷팅 적용
                    int number = int.parse(digits);
                    String formatted = number.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (match) => '${match[1]},',
                    );

                    // 무한 루프 방지: 이미 포맷된 값과 같으면 업데이트하지 않음
                    if (controller.text != formatted) {
                      controller.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  }
                  onChanged();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
