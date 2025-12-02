//1️⃣ 모델 생성 - 초대 코드 데이터 구조

import 'package:cloud_firestore/cloud_firestore.dart';

/// 초대 코드 모델
class InviteCode {
  final String code; // 8자리 무작위 코드
  final bool isActive; // 활성화 여부
  final int maxUsage; // 최대 사용 횟수
  final int usageCount; // 현재 사용 횟수
  final DateTime createdAt; // 생성일
  final String? description; // 설명 (예: "1월 프로모션")
  final DateTime? expiresAt; // 만료일 (선택)

  InviteCode({
    required this.code,
    required this.isActive,
    required this.maxUsage,
    required this.usageCount,
    required this.createdAt,
    this.description,
    this.expiresAt,
  });

  /// Firestore에서 읽기
  factory InviteCode.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InviteCode(
      code: data['code'] ?? doc.id,
      isActive: data['isActive'] ?? true,
      maxUsage: data['maxUsage'] ?? 1,
      usageCount: data['usageCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Firestore에 저장
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'isActive': isActive,
      'maxUsage': maxUsage,
      'usageCount': usageCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'description': description,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }

  /// 사용 가능 여부 확인
  bool get canUse {
    // 비활성화된 코드
    if (!isActive) return false;

    // 사용 횟수 초과
    if (usageCount >= maxUsage) return false;

    // 만료된 코드
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      return false;
    }

    return true;
  }

  /// 남은 사용 횟수
  int get remainingUsage => maxUsage - usageCount;
}
