//2️⃣ 코드 생성 서비스 - 무작위 + 중복 방지

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/invite_code.dart';

/// 초대 코드 생성 및 관리 서비스
class InviteCodeGenerator {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Random _random = Random();

  /// 🔐 혼동 방지 문자셋 (I, O, 0, 1 제외)
  /// - I와 1 헷갈림 방지
  /// - O와 0 헷갈림 방지
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// 📝 8자리 무작위 코드 생성
  /// 예시: A3K9M7H2, ZP4R8N3Q
  String _generateRandomCode() {
    return List.generate(
      8,
      (index) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }

  /// ✅ 중복 확인 (Firestore에 이미 존재하는지)
  Future<bool> _codeExists(String code) async {
    try {
      final doc = await _db.collection('invite_codes').doc(code).get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('코드 중복 확인 실패: $e');
      }
      return true; // 에러 발생 시 중복으로 간주 (안전)
    }
  }

  /// 🔄 중복되지 않는 고유 코드 생성 (최대 20회 시도)
  Future<String> _generateUniqueCode() async {
    for (int attempt = 0; attempt < 20; attempt++) {
      final code = _generateRandomCode();

      // 중복 확인
      if (!await _codeExists(code)) {
        if (kDebugMode) {
          print('✅ 고유 코드 생성 성공: $code (시도 ${attempt + 1}회)');
        }
        return code;
      }

      if (kDebugMode) {
        print('⚠️ 코드 중복: $code (재시도 ${attempt + 1}/20)');
      }
    }

    // 20회 시도 후에도 실패하면 타임스탬프 추가
    final fallbackCode =
        _generateRandomCode().substring(0, 6) +
        DateTime.now().millisecondsSinceEpoch.toString().substring(11);

    if (kDebugMode) {
      print('⚠️ 20회 시도 실패, 타임스탬프 코드 생성: $fallbackCode');
    }

    return fallbackCode;
  }

  /// 🎫 단일 코드 생성
  Future<InviteCode> generateSingleCode({
    required int maxUsage,
    String? description,
    DateTime? expiresAt,
  }) async {
    final code = await _generateUniqueCode();
    final inviteCode = InviteCode(
      code: code,
      isActive: true,
      maxUsage: maxUsage,
      usageCount: 0,
      createdAt: DateTime.now(),
      description: description,
      expiresAt: expiresAt,
    );

    // Firestore에 저장
    await _db
        .collection('invite_codes')
        .doc(code)
        .set(inviteCode.toFirestore());

    if (kDebugMode) {
      print('✅ 단일 코드 생성 완료: $code');
    }

    return inviteCode;
  }

  /// 🎫🎫🎫 대량 코드 생성
  Future<List<InviteCode>> generateBulkCodes({
    required int count,
    required int maxUsage,
    String? description,
    DateTime? expiresAt,
    Function(int current, int total)? onProgress,
  }) async {
    final List<InviteCode> generatedCodes = [];

    for (int i = 1; i <= count; i++) {
      try {
        final code = await _generateUniqueCode();
        final inviteCode = InviteCode(
          code: code,
          isActive: true,
          maxUsage: maxUsage,
          usageCount: 0,
          createdAt: DateTime.now(),
          description: description ?? '대량 생성 $i/$count',
          expiresAt: expiresAt,
        );

        // Firestore에 저장
        await _db
            .collection('invite_codes')
            .doc(code)
            .set(inviteCode.toFirestore());

        generatedCodes.add(inviteCode);

        // 진행 상황 콜백
        if (onProgress != null) {
          onProgress(i, count);
        }

        if (kDebugMode) {
          print('[$i/$count] 생성: $code');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [$i/$count] 생성 실패: $e');
        }
      }
    }

    if (kDebugMode) {
      print('✅ 총 ${generatedCodes.length}개 코드 생성 완료');
    }

    return generatedCodes;
  }

  /// 📊 전체 코드 조회
  Future<List<InviteCode>> getAllCodes() async {
    try {
      final querySnapshot = await _db
          .collection('invite_codes')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => InviteCode.fromFirestore(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('코드 조회 실패: $e');
      }
      return [];
    }
  }

  /// 🗑️ 코드 비활성화
  Future<void> deactivateCode(String code) async {
    await _db.collection('invite_codes').doc(code).update({'isActive': false});
  }
}
