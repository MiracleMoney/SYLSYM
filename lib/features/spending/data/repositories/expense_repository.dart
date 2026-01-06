import 'package:miraclemoney/features/spending/data/models/expense_model.dart';

/// 지출 데이터 관리를 위한 추상 인터페이스
/// Firebase, Local DB, API 등 다양한 구현이 가능하도록 설계
abstract class ExpenseRepository {
  /// 지출 추가
  Future<void> addExpense(ExpenseModel expense);

  /// 지출 삭제
  Future<void> deleteExpense(String expenseId);

  /// 지출 수정
  Future<void> updateExpense(ExpenseModel expense);

  /// 특정 날짜의 지출 조회
  Future<List<ExpenseModel>> getExpensesByDate(DateTime date);

  /// 특정 기간의 지출 조회
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// 모든 지출 조회
  Future<List<ExpenseModel>> getAllExpenses();

  /// 카테고리별 지출 조회
  Future<List<ExpenseModel>> getExpensesByCategory(String category);

  /// 실시간 지출 스트림 (Firebase Realtime에 유용)
  Stream<List<ExpenseModel>> getExpensesStream();
}
