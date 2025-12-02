// lib/features/admin/admin_password_dialog.dart
import 'package:firebase_auth/firebase_auth.dart';

/// 🔐 관리자 이메일 인증
class AdminAuth {
  /// ⚠️ TODO: 반드시 본인의 실제 이메일로 변경하세요!
  static const List<String> ADMIN_EMAILS = [
    'miraclemoney23kr@gmail.com', // ← 여기에 본인 이메일 입력
    // 'another-admin@gmail.com', // 추가 관리자 (필요시)
  ];

  /// 현재 로그인된 사용자가 관리자인지 확인
  static bool isAdmin() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final userEmail = user.email?.toLowerCase().trim();
    return ADMIN_EMAILS.any(
      (adminEmail) => adminEmail.toLowerCase().trim() == userEmail,
    );
  }

  /// 관리자 이메일 가져오기
  static String? getAdminEmail() {
    return FirebaseAuth.instance.currentUser?.email;
  }
}
