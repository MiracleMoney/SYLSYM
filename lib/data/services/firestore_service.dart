import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; //
import '../models/salary/salary_complete_data.dart';
import '../../core/utils/error_handler.dart'; // 👈 추가
import '../../core/utils/app_error.dart'; // 👈 추가

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

  // ==================== 예산 데이터 ====================

  /// 월별 예산 데이터 저장
  /// structure: users/{userId}/budget/{yearMonth}
  Future<void> saveBudget(
    Map<String, dynamic> budgetData, {
    required DateTime targetDate,
  }) async {
    try {
      final userId = currentUserId;
      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budget')
          .doc(yearMonth)
          .set(budgetData, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ 예산 데이터 저장 성공: $yearMonth');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 예산 데이터 저장 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 월별 예산 데이터 불러오기
  Future<Map<String, dynamic>?> loadBudget(DateTime targetDate) async {
    try {
      final userId = currentUserId;
      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('budget')
          .doc(yearMonth)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          print('ℹ️ 예산 데이터 없음: $yearMonth');
        }
        return null;
      }

      if (kDebugMode) {
        print('✅ 예산 데이터 불러오기 성공: $yearMonth');
      }

      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 예산 데이터 불러오기 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  // ==================== 지출 데이터 ====================

  /// 지출 추가
  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    try {
      final userId = currentUserId;

      // ID가 없으면 자동 생성
      if (!expenseData.containsKey('id') || expenseData['id'] == null) {
        expenseData['id'] = _firestore.collection('temp').doc().id;
      }

      // createdAt이 없으면 현재 시간으로 설정
      if (!expenseData.containsKey('createdAt')) {
        expenseData['createdAt'] = DateTime.now().toIso8601String();
      }

      // date에서 연-월 추출
      final dateStr = expenseData['date'] as String;
      final date = DateTime.parse(dateStr);
      final yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(yearMonth)
          .collection('items')
          .doc(expenseData['id'])
          .set(expenseData);

      if (kDebugMode) {
        print('✅ 지출 추가 성공: $yearMonth/${expenseData['id']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 지출 추가 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 특정 월의 지출 목록 불러오기
  Future<List<Map<String, dynamic>>> loadExpenses(DateTime targetDate) async {
    try {
      final userId = currentUserId;

      // 연-월 형식
      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(yearMonth)
          .collection('items')
          .orderBy('date', descending: true)
          .get();

      if (kDebugMode) {
        print('✅ 지출 목록 불러오기 성공 ($yearMonth): ${querySnapshot.docs.length}개');
      }

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 지출 목록 불러오기 실패: $e');
      }
      // 목록 불러오기 실패는 빈 리스트 반환
      return [];
    }
  }

  /// 지출 삭제
  Future<void> deleteExpense(String expenseId, DateTime expenseDate) async {
    try {
      final userId = currentUserId;
      final yearMonth =
          '${expenseDate.year}-${expenseDate.month.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(yearMonth)
          .collection('items')
          .doc(expenseId)
          .delete();

      if (kDebugMode) {
        print('✅ 지출 삭제 성공: $yearMonth/$expenseId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 지출 삭제 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 지출 수정
  /// [originalDate]: 수정 전 원본 날짜 (경로 결정에 사용)
  /// 날짜가 다른 월로 변경된 경우 원본 문서 삭제 후 새 월에 재생성
  Future<void> updateExpense(
    String expenseId,
    Map<String, dynamic> expenseData,
    DateTime originalDate,
  ) async {
    try {
      final userId = currentUserId;
      final originalYearMonth =
          '${originalDate.year}-${originalDate.month.toString().padLeft(2, '0')}';

      final newDateStr = expenseData['date'] as String;
      final newDate = DateTime.parse(newDateStr);
      final newYearMonth =
          '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}';

      final userDoc = _firestore.collection('users').doc(userId);

      if (originalYearMonth == newYearMonth) {
        // 같은 월: 기존 문서 업데이트
        await userDoc
            .collection('expenses')
            .doc(originalYearMonth)
            .collection('items')
            .doc(expenseId)
            .update(expenseData);

        if (kDebugMode) {
          print('✅ 지출 수정 성공 (같은 월): $originalYearMonth/$expenseId');
        }
      } else {
        // 다른 월: WriteBatch로 삭제+생성을 원자적으로 처리
        final oldRef = userDoc
            .collection('expenses')
            .doc(originalYearMonth)
            .collection('items')
            .doc(expenseId);

        final newRef = userDoc
            .collection('expenses')
            .doc(newYearMonth)
            .collection('items')
            .doc(expenseId);

        final batch = _firestore.batch();
        batch.delete(oldRef);
        batch.set(newRef, expenseData);
        await batch.commit();

        if (kDebugMode) {
          print('✅ 지출 수정 성공 (월 이동): $originalYearMonth → $newYearMonth/$expenseId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 지출 수정 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 모든 지출 불러오기 (최근 N개월)
  Future<List<Map<String, dynamic>>> loadAllExpenses({
    int monthsLimit = 6,
  }) async {
    try {
      final userId = currentUserId;
      final now = DateTime.now();
      final allExpenses = <Map<String, dynamic>>[];

      // 최근 N개월의 데이터 가져오기
      for (int i = 0; i < monthsLimit; i++) {
        final targetDate = DateTime(now.year, now.month - i, 1);
        final yearMonth =
            '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

        final querySnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(yearMonth)
            .collection('items')
            .get();

        allExpenses.addAll(querySnapshot.docs.map((doc) => doc.data()));
      }

      // 날짜순 정렬
      allExpenses.sort((a, b) => b['date'].compareTo(a['date']));

      if (kDebugMode) {
        print('✅ 전체 지출 불러오기 성공: ${allExpenses.length}개');
      }

      return allExpenses;
    } catch (e) {
      if (kDebugMode) {
        print('❌ 전체 지출 불러오기 실패: $e');
      }
      return [];
    }
  }

  // ==================== 월별 지출 summary ====================

  static String _toYearMonth(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// 해당 월 items 전체를 읽어 monthly_summaries를 재계산 후 저장
  Future<void> recalculateAndSaveSummary(DateTime targetDate) async {
    try {
      final userId = currentUserId;
      final yearMonth = _toYearMonth(targetDate);

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(yearMonth)
          .collection('items')
          .get();

      final items = snapshot.docs.map((d) => d.data()).toList();
      final summary = _computeSummary(yearMonth, items);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_summaries')
          .doc(yearMonth)
          .set(summary);

      if (kDebugMode) {
        print('✅ summary 갱신 완료: $yearMonth (${items.length}건)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ summary 갱신 실패: $e');
      }
      // summary 실패는 지출 CRUD에 영향을 주지 않도록 예외를 전파하지 않음
    }
  }

  /// 월별 summary 불러오기
  Future<Map<String, dynamic>?> loadMonthlySummary(DateTime targetDate) async {
    try {
      final userId = currentUserId;
      final yearMonth = _toYearMonth(targetDate);

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('monthly_summaries')
          .doc(yearMonth)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ summary 불러오기 실패: $e');
      }
      return null;
    }
  }

  /// items 목록으로 summary 문서 계산
  Map<String, dynamic> _computeSummary(
    String yearMonth,
    List<Map<String, dynamic>> items,
  ) {
    double totalExpense = 0;

    final byCategory = <String, double>{
      'LivingExpenses': 0,
      'FixedExpenses': 0,
      'InvestmentExpenses': 0,
      'SavingExpenses': 0,
      'InterestExpenses': 0,
    };

    final bySubcategory = <String, Map<String, double>>{
      'LivingExpenses': {
        'Groceries': 0, 'EatingOut': 0, 'Delivery': 0,
        'Coffee': 0, 'Drinks': 0, 'Alcohol': 0,
        'DailyGoods': 0, 'Cigarettes': 0, 'Beauty': 0,
        'Clothes': 0, 'Shoes': 0, 'Accessories': 0,
        'Culture': 0, 'Gathering': 0, 'Hobby': 0,
        'OTT': 0, 'Subscription': 0, 'Other': 0,
      },
      'FixedExpenses': {
        'HealthInsurance': 0, 'MobileBill': 0, 'Transportation': 0,
        'CarLoan': 0, 'CarInsurance': 0, 'GasOil': 0,
        'RentLease': 0, 'Utilities': 0, 'ManagementFee': 0,
        'Other': 0,
      },
      'InvestmentExpenses': {
        'PensionSaving': 0, 'IRP': 0, 'ISA': 0, 'General': 0,
      },
      'SavingExpenses': {
        'EmergencyFund': 0, 'ShortTermGoal': 0,
        'HousingSubscription': 0, 'HomeOwnership': 0, 'Other': 0,
      },
      'InterestExpenses': {
        'CreditLoan': 0, 'JeonseLoan': 0, 'Mortgage': 0, 'Other': 0,
      },
    };

    for (final item in items) {
      final amount = (item['amount'] as num?)?.toDouble() ?? 0;
      final category = item['category'] as String? ?? '';
      final subcategory = item['subcategory'] as String? ?? '';

      totalExpense += amount;

      if (byCategory.containsKey(category)) {
        byCategory[category] = (byCategory[category] ?? 0) + amount;
      }

      if (bySubcategory.containsKey(category)) {
        final sub = bySubcategory[category]!;
        if (sub.containsKey(subcategory)) {
          sub[subcategory] = (sub[subcategory] ?? 0) + amount;
        }
      }
    }

    return {
      'yearMonth': yearMonth,
      'updatedAt': DateTime.now().toIso8601String(),
      'totalExpense': totalExpense,
      'byCategory': byCategory,
      'bySubcategory': bySubcategory,
    };
  }

  // ==================== 자산현황 데이터 ====================

  /// 월별 자산현황 데이터 저장
  /// structure: users/{userId}/asset_status/{yearMonth}
  Future<void> saveAssetStatus(
    Map<String, dynamic> assetData,
    DateTime targetDate,
  ) async {
    try {
      final userId = currentUserId;
      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('asset_status')
          .doc(yearMonth)
          .set(assetData, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ 자산현황 데이터 저장 성공: $yearMonth');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 자산현황 데이터 저장 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  /// 월별 자산현황 데이터 불러오기
  Future<Map<String, dynamic>?> loadAssetStatus(DateTime targetDate) async {
    try {
      final userId = currentUserId;
      final yearMonth =
          '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('asset_status')
          .doc(yearMonth)
          .get();

      if (!doc.exists || doc.data() == null) {
        if (kDebugMode) {
          print('ℹ️ 자산현황 데이터 없음: $yearMonth');
        }
        return null;
      }

      if (kDebugMode) {
        print('✅ 자산현황 데이터 불러오기 성공: $yearMonth');
      }

      return doc.data();
    } catch (e) {
      if (kDebugMode) {
        print('❌ 자산현황 데이터 불러오기 실패: $e');
      }
      throw ErrorHandler.handleFirebaseError(e);
    }
  }

  // ==================== 레거시 자산 데이터 (호환용) ====================

  Future<void> saveAssets(Map<String, dynamic> assetsData) async {
    // 레거시: saveAssetStatus 사용 권장
  }

  Future<Map<String, dynamic>?> loadAssets(DateTime targetDate) async {
    // 레거시: loadAssetStatus 사용 권장
    return null;
  }

  // ==================== 리포트 생성 (나중에 구현) ====================

  Future<void> generateMonthlyReport(DateTime targetDate) async {
    // TODO: 월급, 예산, 지출, 자산 데이터 종합하여 리포트 생성
  }
}
