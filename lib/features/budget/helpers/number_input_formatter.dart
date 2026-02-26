import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 숫자 입력 포매터 유틸리티 클래스
class NumberInputFormatter {
  /// 실시간 콤마 포매터를 반환하는 정적 메소드
  static TextInputFormatter getCommaFormatter() {
    return _CommaInputFormatter();
  }

  /// 숫자만 허용하는 포매터
  static TextInputFormatter numbersOnly() {
    return FilteringTextInputFormatter.digitsOnly;
  }

  /// 콤마가 포함된 숫자 문자열을 정수로 변환
  static int parseCommaNumber(String text) {
    final cleanText = text.replaceAll(',', '');
    return int.tryParse(cleanText) ?? 0;
  }

  /// 숫자를 콤마가 포함된 문자열로 변환
  static String formatWithComma(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}

/// 실시간 콤마 포매터 클래스
class _CommaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 빈 문자열이거나 숫자가 아닌 경우 원래 값 반환
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 숫자와 콤마만 허용
    final cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 숫자를 정수로 파싱하고 다시 콤마 포맷팅
    final parsedNumber = int.tryParse(cleanText);
    if (parsedNumber == null) {
      return oldValue;
    }

    final formattedText = NumberFormat('#,###').format(parsedNumber);

    // 커서 위치 계산
    final selectionIndex = formattedText.length;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
