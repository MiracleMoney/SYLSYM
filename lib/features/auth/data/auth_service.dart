import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 현재 로그인된 사용자
  User? get currentUser => _auth.currentUser;

  /// 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// ✨ 초대코드 유효성 한 번 확인 (간단 버전)
  Future<bool> checkInviteCodeValidity() async {
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      final inviteCode = userDoc.data()?['inviteCode'] as String?;

      if (inviteCode == null || inviteCode.isEmpty) return false;

      final codeDoc = await _firestore
          .collection('invite_codes')
          .doc(inviteCode)
          .get();

      if (!codeDoc.exists) {
        if (kDebugMode) print('❌ 코드가 삭제됨: $inviteCode');
        return false;
      }

      final isActive = codeDoc.data()?['isActive'] as bool? ?? false;

      if (!isActive) {
        if (kDebugMode) print('❌ 코드가 비활성화됨: $inviteCode');
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ 코드 검증 실패: $e');
      return false;
    }
  }

  /// ✨ 약관 동의 여부 확인
  Future<bool> hasAgreedToTerms() async {
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      final termsAgreed = userDoc.data()?['termsAgreed'] as bool? ?? false;
      return termsAgreed;
    } catch (e) {
      if (kDebugMode) print('❌ 약관 동의 확인 실패: $e');
      return false;
    }
  }

  /// ✨ 사용자 정보 입력 완료 여부 확인
  Future<bool> hasUserInfo() async {
    if (currentUser == null) return false;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return false;

      final data = userDoc.data();
      final birthdate = data?['birthdate'];
      final gender = data?['gender'];
      final userInfoSkipped = data?['userInfoSkipped'] as bool? ?? false;

      // 건너뛰기 했거나, birthdate와 gender가 모두 있으면 true
      return userInfoSkipped || (birthdate != null && gender != null);
    } catch (e) {
      if (kDebugMode) print('❌ 사용자 정보 확인 실패: $e');
      return false;
    }
  }

  /// 🔐 구글 로그인
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        if (kDebugMode) print('❌ 로그인 취소됨');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // ✨ 신규/기존 사용자 모두 문서 확인 및 생성
      await _ensureUserDocument(userCredential.user!);

      if (kDebugMode) print('✅ 로그인 성공: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      if (kDebugMode) print('❌ 로그인 실패: $e');
      rethrow;
    }
  }

  /// 🍎 Apple 로그인 가능 여부 확인
  Future<bool> isAppleSignInAvailable() async {
    if (Platform.isIOS || Platform.isMacOS) {
      return await SignInWithApple.isAvailable();
    }
    return false;
  }

  /// 🍎 Apple 로그인
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // ✨ 신규/기존 사용자 모두 문서 확인 및 생성
      await _ensureUserDocument(userCredential.user!);

      if (kDebugMode) print('✅ Apple 로그인 성공: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      if (kDebugMode) print('❌ Apple 로그인 실패: $e');
      rethrow;
    }
  }

  /// ✨ 사용자 문서 확인 및 생성
  Future<void> _ensureUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      // 문서가 없으면 생성
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'isAdmin': false,
        'inviteCode': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) print('✅ 사용자 문서 생성 완료');
    } else {
      if (kDebugMode) print('✅ 기존 사용자 문서 확인');
    }
  }

  /// 🎫 초대코드 입력 여부 확인
  Future<bool> hasInviteCode() async {
    if (currentUser == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!doc.exists) {
        // ✨ 문서가 없으면 생성
        await _ensureUserDocument(currentUser!);
        return false;
      }

      final inviteCode = doc.data()?['inviteCode'];
      final hasCode = inviteCode != null && inviteCode.toString().isNotEmpty;

      if (kDebugMode) print('🎫 초대코드 확인: $hasCode');
      return hasCode;
    } catch (e) {
      if (kDebugMode) print('❌ 초대코드 확인 실패: $e');
      return false;
    }
  }

  /// ✅ 초대코드 검증 및 저장
  Future<void> verifyAndSaveInviteCode(String code) async {
    if (currentUser == null) {
      throw Exception('로그인 정보가 없습니다');
    }

    final upperCode = code.toUpperCase().trim();

    // 1. 입력 검증
    if (upperCode.isEmpty) {
      throw Exception('초대코드를 입력해주세요');
    }

    if (upperCode.length != 8) {
      throw Exception('초대코드는 8자리입니다');
    }

    try {
      // 2. 초대코드 존재 여부 확인
      final codeDoc = await _firestore
          .collection('invite_codes')
          .doc(upperCode)
          .get();

      if (!codeDoc.exists) {
        if (kDebugMode) print('❌ 존재하지 않는 코드: $upperCode');
        throw Exception('존재하지 않는 초대코드입니다');
      }

      // 3. 코드 유효성 검증
      final codeData = codeDoc.data()!;
      final isActive = codeData['isActive'] as bool? ?? false;
      final usageCount = codeData['usageCount'] as int? ?? 0;
      final maxUsage = codeData['maxUsage'] as int? ?? 1;

      if (kDebugMode) {
        print('📊 코드 정보:');
        print('  - isActive: $isActive');
        print('  - usageCount: $usageCount');
        print('  - maxUsage: $maxUsage');
      }

      if (!isActive) {
        throw Exception('비활성화된 초대코드입니다');
      }

      if (usageCount >= maxUsage) {
        throw Exception('사용 횟수가 초과된 초대코드입니다');
      }

      // ✨ 4. 사용자 문서 존재 확인 및 업데이트
      final userDoc = _firestore.collection('users').doc(currentUser!.uid);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        // 문서가 없으면 생성 후 업데이트
        if (kDebugMode) print('⚠️ 사용자 문서가 없어서 생성 중...');
        await _ensureUserDocument(currentUser!);
      }

      // 사용자 정보 업데이트
      await userDoc.update({
        'inviteCode': upperCode,
        'inviteCodeActivatedAt': FieldValue.serverTimestamp(),
      });

      // 5. 초대코드 사용 횟수 증가
      await _firestore.collection('invite_codes').doc(upperCode).update({
        'usageCount': FieldValue.increment(1),
        'lastUsedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) print('✅ 초대코드 저장 완료: $upperCode');
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('❌ Firebase 에러:');
        print('  - code: ${e.code}');
        print('  - message: ${e.message}');
      }

      // 에러 메시지 번역
      if (e.code == 'not-found') {
        throw Exception('초대코드를 찾을 수 없습니다. 코드를 다시 확인해주세요.');
      } else if (e.code == 'permission-denied') {
        throw Exception('권한이 없습니다. 관리자에게 문의하세요.');
      } else {
        throw Exception('오류가 발생했습니다: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ 초대코드 검증 실패: $e');
      rethrow;
    }
  }

  /// 🔧 관리자 권한 확인
  Future<bool> isAdmin() async {
    if (currentUser == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!doc.exists) {
        await _ensureUserDocument(currentUser!);
        return false;
      }

      return doc.data()?['isAdmin'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ 관리자 확인 실패: $e');
      return false;
    }
  }

  /// 🚪 로그아웃
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      if (kDebugMode) print('✅ 로그아웃 성공');
    } catch (e) {
      if (kDebugMode) print('❌ 로그아웃 실패: $e');
      rethrow;
    }
  }

  /// 🗑️ 계정 삭제
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser!.uid).delete();
        await currentUser!.delete();
      }
      await _googleSignIn.signOut();
      if (kDebugMode) print('✅ 계정 삭제 성공');
    } catch (e) {
      if (kDebugMode) print('❌ 계정 삭제 실패: $e');
      rethrow;
    }
  }
}
