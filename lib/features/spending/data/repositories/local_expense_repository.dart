import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/repositories/expense_repository.dart';

/// 로컬 메모리 구현 (개발/테스트 용)
/// 나중에 Firebase, Hive 등으로 교체 가능
class LocalExpenseRepository implements ExpenseRepository {
  // 단일 인스턴스 패턴
  static final LocalExpenseRepository _instance =
      LocalExpenseRepository._internal();

  factory LocalExpenseRepository() {
    return _instance;
  }

  LocalExpenseRepository._internal();

  final List<ExpenseModel> _expenses = [];

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    _expenses.add(expense);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((e) => e.id == expenseId);
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDate(DateTime date) async {
    return _expenses.where((e) {
      return e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day;
    }).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _expenses.where((e) {
      return e.date.isAfter(startDate) && e.date.isBefore(endDate);
    }).toList();
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    return List.from(_expenses);
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    return _expenses.where((e) => e.category == category).toList();
  }

  @override
  Stream<List<ExpenseModel>> getExpensesStream() {
    // 실제로는 StreamController 사용 가능
    return Stream.value(_expenses);
  }
}
