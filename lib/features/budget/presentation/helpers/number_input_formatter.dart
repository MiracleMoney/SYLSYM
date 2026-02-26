import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 숫자 입력 포매터 유틸리티
class NumberInputFormatter {
  /// 콤마가 포함된 숫자 포매터를 반환합니다
  static TextInputFormatter getCommaFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) {
        return newValue;
      }

      // 숫자만 추출
      String digits = newValue.text.replaceAll(RegExp(r'[^\\d]'), '');

      if (digits.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      // 숫자에 콤마 추가
      final formatter = NumberFormat('#,###');
      final formatted = formatter.format(int.parse(digits));

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
  }
}
