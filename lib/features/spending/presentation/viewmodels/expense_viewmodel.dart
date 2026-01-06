import 'package:flutter/foundation.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/repositories/expense_repository.dart';

/// 지출 화면의 비즈니스 로직을 담당
/// Repository를 통해 데이터 CRUD 수행
class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _repository;

  ExpenseViewModel({required ExpenseRepository repository})
    : _repository = repository;

  List<ExpenseModel> _expenses = [];
  String _selectedFilter = 'All';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  String get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ExpenseModel> get filteredExpenses {
    if (_selectedFilter == 'All') {
      return _expenses;
    }
    return _expenses.where((e) => e.category == _selectedFilter).toList();
  }

  /// 초기화: 모든 지출 로드
  Future<void> initialize() async {
    await loadExpenses();
  }

  /// 모든 지출 로드
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _repository.getAllExpenses();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 지출 추가
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repository.addExpense(expense);
      _expenses.add(expense);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 지출 삭제
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _repository.deleteExpense(expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 지출 수정
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _repository.updateExpense(expense);
      final index = _expenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _expenses[index] = expense;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// 필터 변경
  void changeFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// 특정 기간의 지출 조회
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await _repository.getExpensesByDateRange(startDate, endDate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// 카테고리별 총액 계산
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryTotals = {};
    for (final expense in filteredExpenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals;
  }

  /// 총 지출액 계산
  double getTotalExpenses() {
    return filteredExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}
