import 'package:cloud_firestore/cloud_firestore.dart';

class SalaryStep1Data {
  final int? currentAge;
  final int? retireAge;
  final double? livingExpense;
  final double? snpValue;
  final double? expectedReturn;
  final double? inflation;
  final bool hasShortTermGoal;
  final String? shortTermGoal;
  final double? shortTermAmount;
  final int? shortTermDuration;
  final double? shortTermSaved;

  SalaryStep1Data({
    this.currentAge,
    this.retireAge,
    this.livingExpense,
    this.snpValue,
    this.expectedReturn,
    this.inflation,
    this.hasShortTermGoal = false,
    this.shortTermGoal,
    this.shortTermAmount,
    this.shortTermDuration,
    this.shortTermSaved,
  });

  // Firebase에 저장할 때
  Map<String, dynamic> toJson() {
    return {
      'currentAge': currentAge,
      'retireAge': retireAge,
      'livingExpense': livingExpense,
      'snpValue': snpValue,
      'expectedReturn': expectedReturn,
      'inflation': inflation,
      'hasShortTermGoal': hasShortTermGoal,
      'shortTermGoal': shortTermGoal,
      'shortTermAmount': shortTermAmount,
      'shortTermDuration': shortTermDuration,
      'shortTermSaved': shortTermSaved,
    };
  }

  // Firebase에서 불러올 때
  factory SalaryStep1Data.fromJson(Map<String, dynamic> json) {
    return SalaryStep1Data(
      currentAge: json['currentAge'] as int?,
      retireAge: json['retireAge'] as int?,
      livingExpense: (json['livingExpense'] as num?)?.toDouble(),
      snpValue: (json['snpValue'] as num?)?.toDouble(),
      expectedReturn: (json['expectedReturn'] as num?)?.toDouble(),
      inflation: (json['inflation'] as num?)?.toDouble(),
      hasShortTermGoal: json['hasShortTermGoal'] as bool? ?? false,
      shortTermGoal: json['shortTermGoal'] as String?,
      shortTermAmount: (json['shortTermAmount'] as num?)?.toDouble(),
      shortTermDuration: json['shortTermDuration'] as int?,
      shortTermSaved: (json['shortTermSaved'] as num?)?.toDouble(),
    );
  }

  // 데이터 복사 (불변성 유지)
  SalaryStep1Data copyWith({
    int? currentAge,
    int? retireAge,
    double? livingExpense,
    double? snpValue,
    double? expectedReturn,
    double? inflation,
    bool? hasShortTermGoal,
    String? shortTermGoal,
    double? shortTermAmount,
    int? shortTermDuration,
    double? shortTermSaved,
  }) {
    return SalaryStep1Data(
      currentAge: currentAge ?? this.currentAge,
      retireAge: retireAge ?? this.retireAge,
      livingExpense: livingExpense ?? this.livingExpense,
      snpValue: snpValue ?? this.snpValue,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      inflation: inflation ?? this.inflation,
      hasShortTermGoal: hasShortTermGoal ?? this.hasShortTermGoal,
      shortTermGoal: shortTermGoal ?? this.shortTermGoal,
      shortTermAmount: shortTermAmount ?? this.shortTermAmount,
      shortTermDuration: shortTermDuration ?? this.shortTermDuration,
      shortTermSaved: shortTermSaved ?? this.shortTermSaved,
    );
  }

  // 빈 데이터인지 확인
  bool get isEmpty {
    return currentAge == null &&
        retireAge == null &&
        livingExpense == null &&
        snpValue == null &&
        expectedReturn == null &&
        inflation == null;
  }
}
