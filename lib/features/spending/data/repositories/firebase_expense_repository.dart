import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/data/repositories/expense_repository.dart';

/// Firebase 구현 (나중에 실제 연동할 때 사용)
class FirebaseExpenseRepository implements ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'expenses';
  final String _userId; // 사용자별로 분리하기 위함

  FirebaseExpenseRepository({required String userId}) : _userId = userId;

  /// 사용자별 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_userId).collection(_collectionPath);

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    await _expensesCollection.doc(expense.id).set(expense.toJson());
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _expensesCollection.doc(expenseId).delete();
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _expensesCollection.doc(expense.id).update(expense.toJson());
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = await _expensesCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .get();

    return query.docs.map((doc) => ExpenseModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = await _expensesCollection
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => ExpenseModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final query = await _expensesCollection
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => ExpenseModel.fromJson(doc.data())).toList();
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory(String category) async {
    final query = await _expensesCollection
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .get();

    return query.docs.map((doc) => ExpenseModel.fromJson(doc.data())).toList();
  }

  @override
  Stream<List<ExpenseModel>> getExpensesStream() {
    return _expensesCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExpenseModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
