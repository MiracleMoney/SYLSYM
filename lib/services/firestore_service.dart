import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; //
import '../models/salary_complete_data.dart';
import '../utils/error_handler.dart'; // 👈 추가
import '../utils/app_error.dart'; // 👈 추가

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 현재 로그인된 사용자 ID (임시: 테스트용 하드코딩)
  String? get currentUserId {
    //  test_user_id 제거 - 로그인한 사용자만 사용 가능
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AppError(
        // 👈 Exception 대신 AppError
        userMessage: '로그인이 필요합니다.\n다시 로그인해주세요.',
        type: ErrorType.permission,
      );
    }
    return uid;
  }
  // ==================== 월급 최적화 데이터 ====================

  /// 월급 데이터 저장 (자동으로 year-month 형식 생성)
  Future<void> saveSalaryData(
    SalaryCompleteData data, {
    required DateTime targetDate,
  }) async {
    try {
      final userId = currentUserId; // null이면 AppError 던짐

      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('salary_data')
          .doc(yearMonth)
          .set(data.toJson(), SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ 월급 데이터 저장 성공: $yearMonth');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 월급 데이터 저장 실패: $e');
      }

      // ✅ Firebase 에러를 AppError로 변환
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 특정 월의 월급 데이터 불러오기
  Future<SalaryCompleteData?> loadSalaryData({DateTime? targetDate}) async {
    try {
      final userId = currentUserId;
      final date = targetDate ?? DateTime.now();
      final yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

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
        return null; // 데이터 없음은 에러가 아님
      }

      if (kDebugMode) {
        print('✅ 월급 데이터 불러오기 성공: $yearMonth');
      }

      return SalaryCompleteData.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 월급 데이터 불러오기 실패: $e');
      }

      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 모든 월급 데이터 목록 가져오기 (최근 12개월)
  Future<List<SalaryCompleteData>> loadAllSalaryData({int limit = 12}) async {
    try {
      final userId = currentUserId;

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

      // ✅ 실패해도 빈 리스트 반환 (목록 불러오기는 치명적이지 않음)
      return [];
    }
  }

  /// 특정 월 데이터 삭제
  Future<void> deleteSalaryData(DateTime targetDate) async {
    try {
      final userId = currentUserId;
      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

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

      throw ErrorHandler.handleFirebaseError(e);
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
