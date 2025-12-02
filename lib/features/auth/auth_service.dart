import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // 👈 1. 추가

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 현재 로그인된 사용자
  User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. 구글 계정 선택 팝업
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) {
          print('❌ 로그인 취소됨');
        }
        return null;
      }

      // 2. 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Firebase 인증 자격증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);

      if (kDebugMode) {
        print('✅ 로그인 성공: ${userCredential.user?.email}');
      }
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 로그인 실패: $e');
      }
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      if (kDebugMode) {
        print('✅ 로그아웃 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 로그아웃 실패: $e');
      }
      rethrow;
    }
  }

  // 계정 삭제
  Future<void> deleteAccount() async {
    try {
      await currentUser?.delete();
      await _googleSignIn.signOut();
      if (kDebugMode) {
        print('✅ 계정 삭제 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 계정 삭제 실패: $e');
      }
      rethrow;
    }
  }
}
