class ExpenseModel {
  final String id;
  final DateTime date;
  final double amount;
  final String description;
  final String category;
  final String subcategory;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.description,
    required this.category,
    required this.subcategory,
    required this.createdAt,
  });

  // JSON 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'amount': amount,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // copyWith
  ExpenseModel copyWith({
    String? id,
    DateTime? date,
    double? amount,
    String? description,
    String? category,
    String? subcategory,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
