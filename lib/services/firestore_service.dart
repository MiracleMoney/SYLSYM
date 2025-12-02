import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // 👈 1. 이 줄 추가

import '../models/salary_complete_data.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인된 사용자 ID (임시: 테스트용 하드코딩)
  String? get currentUserId {
    // ✅ test_user_id 제거 - 로그인한 사용자만 사용 가능
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('로그인이 필요합니다.');
    }
    return uid;
  }
  // ==================== 월급 최적화 데이터 ====================

  /// 월급 데이터 저장 (자동으로 year-month 형식 생성)
  Future<void> saveSalaryData(
    SalaryCompleteData data, {
    required DateTime targetDate,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자 ID를 가져올 수 없습니다. 로그인이 필요합니다.');
    }

    // ✅ targetDate가 있으면 그것 사용, 없으면 현재 날짜 사용
    final date = targetDate ?? DateTime.now();
    // 현재 연월을 문서 ID로 사용 (예: "2025-01")
    final yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('salary_data')
          .doc(yearMonth)
          .set(
            data.toJson(),
            SetOptions(merge: true),
          ); // merge: 기존 데이터 유지하면서 업데이트
      // 👇 2. if (kDebugMode) { } 로 감싸기
      if (kDebugMode) {
        print('✅ 월급 데이터 저장 성공: $yearMonth');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 월급 데이터 저장 실패: $e');
      }
      rethrow;
    }
  }

  /// 특정 월의 월급 데이터 불러오기
  Future<SalaryCompleteData?> loadSalaryData({DateTime? targetDate}) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자 ID를 가져올 수 없습니다. 로그인이 필요합니다.');
    }

    final date = targetDate ?? DateTime.now();
    final yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('salary_data')
          .doc(yearMonth)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          print('ℹ️ 데이터 없음: $yearMonth');
        }
        return null;
      }

      if (kDebugMode) {
        print('✅ 월급 데이터 불러오기 성공: $yearMonth');
      }
      return SalaryCompleteData.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 월급 데이터 불러오기 실패: $e');
      }
      rethrow;
    }
  }

  /// 모든 월급 데이터 목록 가져오기 (최근 12개월)
  Future<List<SalaryCompleteData>> loadAllSalaryData({int limit = 12}) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자 ID를 가져올 수 없습니다. 로그인이 필요합니다.');
    }

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('salary_data')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => SalaryCompleteData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 전체 월급 데이터 불러오기 실패: $e');
      }
      return [];
    }
  }

  /// 특정 월 데이터 삭제
  Future<void> deleteSalaryData(DateTime targetDate) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('사용자 ID를 가져올 수 없습니다. 로그인이 필요합니다.');
    }

    final yearMonth =
        '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('salary_data')
          .doc(yearMonth)
          .delete();

      if (kDebugMode) {
        print('✅ 월급 데이터 삭제 성공: $yearMonth');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 월급 데이터 삭제 실패: $e');
      }
      rethrow;
    }
  }

  // loadSalaryDataByMonth 메서드를 제거하고, 기존 loadSalaryData 사용
  Future<SalaryCompleteData?> loadSalaryDataByMonth(DateTime month) async {
    return await loadSalaryData(targetDate: month);
  }

  // ==================== 예산 데이터 (나중에 구현) ====================

  Future<void> saveBudget(Map<String, dynamic> budgetData) async {
    // TODO: 구현
  }

  Future<Map<String, dynamic>?> loadBudget(DateTime targetDate) async {
    // TODO: 구현
    return null;
  }

  // ==================== 지출 데이터 (나중에 구현) ====================

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    // TODO: 구현
  }

  Future<List<Map<String, dynamic>>> loadExpenses(DateTime targetDate) async {
    // TODO: 구현
    return [];
  }

  // ==================== 자산 데이터 (나중에 구현) ====================

  Future<void> saveAssets(Map<String, dynamic> assetsData) async {
    // TODO: 구현
  }

  Future<Map<String, dynamic>?> loadAssets(DateTime targetDate) async {
    // TODO: 구현
    return null;
  }

  // ==================== 리포트 생성 (나중에 구현) ====================

  Future<void> generateMonthlyReport(DateTime targetDate) async {
    // TODO: 월급, 예산, 지출, 자산 데이터 종합하여 리포트 생성
  }
}
