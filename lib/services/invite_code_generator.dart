import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invite_code.dart';

class InviteCodeGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final Random _random = Random();

  /// 🎫 대량 코드 생성
  Future<List<InviteCode>> generateBulkCodes({
    required int count,
    int maxUsage = 1,
    String? description,
    bool markAsUnconfirmed = false,
    Function(int current, int total)? onProgress,
  }) async {
    final codes = <InviteCode>[];
    final batch = _firestore.batch();

    for (int i = 0; i < count; i++) {
      final code = await generateCode(
        maxUsage: maxUsage,
        description: description,
        saveToDB: false,
      );

      codes.add(code);

      final docRef = _firestore.collection('invite_codes').doc(code.code);
      final data = {
        'code': code.code,
        'isActive': code.isActive,
        'usageCount': code.usageCount,
        'maxUsage': code.maxUsage,
        'createdAt': code.createdAt,
        'expiresAt': code.expiresAt,
        'description': code.description,
      };

      if (markAsUnconfirmed) {
        data['isConfirmed'] = false;
        data['batchId'] = DateTime.now().millisecondsSinceEpoch.toString();
      }

      batch.set(docRef, data);

      if (onProgress != null) {
        onProgress(i + 1, count);
      }
    }

    await batch.commit();
    return codes;
  }

  /// 📋 모든 코드 가져오기
  Future<List<InviteCode>> getAllCodes() async {
    final snapshot = await _firestore
        .collection('invite_codes')
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return InviteCode(
        code: data['code'] as String,
        isActive: data['isActive'] as bool? ?? true,
        usageCount: data['usageCount'] as int? ?? 0,
        maxUsage: data['maxUsage'] as int? ?? 1,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        expiresAt: data['expiresAt'] != null
            ? (data['expiresAt'] as Timestamp).toDate()
            : null,
        description: data['description'] as String?,
        isConfirmed: data['isConfirmed'] as bool?, // ✨ 추가
      );
    }).toList();
  }

  /// 💾 미확인 코드 불러오기
  Future<List<InviteCode>> getUnconfirmedCodes() async {
    final snapshot = await _firestore
        .collection('invite_codes')
        .where('isConfirmed', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(1000)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return InviteCode(
        code: data['code'] as String,
        isActive: data['isActive'] as bool? ?? true,
        usageCount: data['usageCount'] as int? ?? 0,
        maxUsage: data['maxUsage'] as int? ?? 1,
        createdAt: (data['createdAt'] as Timestamp).toDate(),
        expiresAt: data['expiresAt'] != null
            ? (data['expiresAt'] as Timestamp).toDate()
            : null,
        description: data['description'] as String?,
        isConfirmed: false, // ✨ 미확인
      );
    }).toList();
  }

  /// ✅ 코드를 확인됨으로 표시
  Future<void> markCodesAsConfirmed(List<InviteCode> codes) async {
    final batch = _firestore.batch();

    for (final code in codes) {
      final docRef = _firestore.collection('invite_codes').doc(code.code);
      batch.update(docRef, {'isConfirmed': true});
    }

    await batch.commit();
  }

  /// 🎟️ 단일 코드 생성
  Future<InviteCode> generateCode({
    int maxUsage = 1,
    DateTime? expiresAt,
    String? description,
    bool saveToDB = true,
  }) async {
    String code;

    do {
      code = _generateRandomCode();
    } while (await _isCodeExists(code));

    final inviteCode = InviteCode(
      code: code,
      isActive: true,
      usageCount: 0,
      maxUsage: maxUsage,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      description: description,
    );

    if (saveToDB) {
      await _firestore.collection('invite_codes').doc(code).set({
        'code': inviteCode.code,
        'isActive': inviteCode.isActive,
        'usageCount': inviteCode.usageCount,
        'maxUsage': inviteCode.maxUsage,
        'createdAt': inviteCode.createdAt,
        'expiresAt': inviteCode.expiresAt,
        'description': inviteCode.description,
        'isConfirmed': true,
      });
    }

    return inviteCode;
  }

  /// 🎲 8자리 무작위 코드 생성
  String _generateRandomCode() {
    return List.generate(
      8,
      (index) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }

  /// ✅ 코드 존재 여부 확인
  Future<bool> _isCodeExists(String code) async {
    final doc = await _firestore.collection('invite_codes').doc(code).get();
    return doc.exists;
  }

  /// 🔄 코드 활성/비활성 토글
  Future<void> toggleCodeActive(String code) async {
    final docRef = _firestore.collection('invite_codes').doc(code);
    final doc = await docRef.get();

    if (doc.exists) {
      final isActive = doc.data()?['isActive'] as bool? ?? true;
      await docRef.update({'isActive': !isActive});
    }
  }

  /// 🗑️ 코드 삭제
  Future<void> deleteCode(String code) async {
    await _firestore.collection('invite_codes').doc(code).delete();
  }

  /// 📊 코드 통계 가져오기
  Future<Map<String, dynamic>> getCodeStats() async {
    final snapshot = await _firestore.collection('invite_codes').get();

    int totalCodes = snapshot.docs.length;
    int activeCodes = 0;
    int usedCodes = 0;
    int availableCodes = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final isActive = data['isActive'] as bool? ?? false;
      final usageCount = data['usageCount'] as int? ?? 0;
      final maxUsage = data['maxUsage'] as int? ?? 1;

      if (isActive) {
        activeCodes++;
        if (usageCount < maxUsage) {
          availableCodes++;
        } else {
          usedCodes++;
        }
      }
    }

    return {
      'total': totalCodes,
      'active': activeCodes,
      'used': usedCodes,
      'available': availableCodes,
    };
  }
}
