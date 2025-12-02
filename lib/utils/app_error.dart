class AppError implements Exception {
  final String userMessage;
  final String? technicalMessage;
  final ErrorType type;

  AppError({
    required this.userMessage,
    this.technicalMessage,
    required this.type,
  });

  @override
  String toString() => userMessage;
}

enum ErrorType {
  network, // 인터넷 연결 문제
  permission, // Firebase 권한 문제
  notFound, // 데이터 없음
  invalidData, // 잘못된 데이터
  unknown, // 알 수 없는 오류
}
