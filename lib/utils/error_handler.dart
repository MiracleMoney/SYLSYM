// lib/utils/error_handler.dart (새 파일 생성)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_error.dart';

class ErrorHandler {
  /// Firebase 에러를 AppError로 변환
  static AppError handleFirebaseError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        // 권한 문제
        case 'permission-denied':
          return AppError(
            userMessage: '데이터 접근 권한이 없습니다.\n로그인 상태를 확인해주세요.',
            technicalMessage: error.toString(),
            type: ErrorType.permission,
          );

        // 네트워크 문제
        case 'unavailable':
          return AppError(
            userMessage: '인터넷 연결을 확인해주세요.\n잠시 후 다시 시도해주세요.',
            technicalMessage: error.toString(),
            type: ErrorType.network,
          );

        // 데이터를 찾을 수 없음
        case 'not-found':
          return AppError(
            userMessage: '요청하신 데이터를 찾을 수 없습니다.',
            technicalMessage: error.toString(),
            type: ErrorType.notFound,
          );

        default:
          return AppError(
            userMessage: '오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
            technicalMessage: error.toString(),
            type: ErrorType.unknown,
          );
      }
    }

    // FirebaseAuthException
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'network-request-failed':
          return AppError(
            userMessage: '인터넷 연결을 확인해주세요.',
            technicalMessage: error.toString(),
            type: ErrorType.network,
          );

        case 'user-not-found':
        case 'wrong-password':
          return AppError(
            userMessage: '로그인 정보가 올바르지 않습니다.',
            technicalMessage: error.toString(),
            type: ErrorType.permission,
          );

        default:
          return AppError(
            userMessage: '인증 오류가 발생했습니다.',
            technicalMessage: error.toString(),
            type: ErrorType.unknown,
          );
      }
    }

    // 알 수 없는 에러
    return AppError(
      userMessage: '예상치 못한 오류가 발생했습니다.\n앱을 다시 시작해주세요.',
      technicalMessage: error.toString(),
      type: ErrorType.unknown,
    );
  }

  /// 에러에 맞는 액션 버튼 제공
  static String? getActionLabel(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return '다시 시도';
      case ErrorType.permission:
        return '로그인';
      case ErrorType.notFound:
        return '확인';
      default:
        return null;
    }
  }
}
