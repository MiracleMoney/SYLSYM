import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// 숫자 입력 포매터 유틸리티 클래스
class NumberInputFormatter {
  /// 실시간 콤마 포매터를 반환하는 정적 메소드
  static TextInputFormatter getCommaFormatter() {
    return FilteringTextInputFormatter.allow(RegExp(r'[0-9,]'));
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
