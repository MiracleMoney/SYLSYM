class SalaryStep2Data {
  final double? baseSalary;
  final double? overtime;
  final double? bonus;
  final double? incentive;
  final double? sideIncome1;
  final double? sideIncome2;
  final double? sideIncome3;
  final double? retirement;

  SalaryStep2Data({
    this.baseSalary,
    this.overtime,
    this.bonus,
    this.incentive,
    this.sideIncome1,
    this.sideIncome2,
    this.sideIncome3,
    this.retirement,
  });

  Map<String, dynamic> toJson() {
    return {
      'baseSalary': baseSalary,
      'overtime': overtime,
      'bonus': bonus,
      'incentive': incentive,
      'sideIncome1': sideIncome1,
      'sideIncome2': sideIncome2,
      'sideIncome3': sideIncome3,
      'retirement': retirement,
    };
  }

  factory SalaryStep2Data.fromJson(Map<String, dynamic> json) {
    return SalaryStep2Data(
      baseSalary: (json['baseSalary'] as num?)?.toDouble(),
      overtime: (json['overtime'] as num?)?.toDouble(),
      bonus: (json['bonus'] as num?)?.toDouble(),
      incentive: (json['incentive'] as num?)?.toDouble(),
      sideIncome1: (json['sideIncome1'] as num?)?.toDouble(),
      sideIncome2: (json['sideIncome2'] as num?)?.toDouble(),
      sideIncome3: (json['sideIncome3'] as num?)?.toDouble(),
      retirement: (json['retirement'] as num?)?.toDouble(),
    );
  }

  SalaryStep2Data copyWith({
    double? baseSalary,
    double? overtime,
    double? bonus,
    double? incentive,
    double? sideIncome1,
    double? sideIncome2,
    double? sideIncome3,
    double? retirement,
  }) {
    return SalaryStep2Data(
      baseSalary: baseSalary ?? this.baseSalary,
      overtime: overtime ?? this.overtime,
      bonus: bonus ?? this.bonus,
      incentive: incentive ?? this.incentive,
      sideIncome1: sideIncome1 ?? this.sideIncome1,
      sideIncome2: sideIncome2 ?? this.sideIncome2,
      sideIncome3: sideIncome3 ?? this.sideIncome3,
      retirement: retirement ?? this.retirement,
    );
  }

  bool get isEmpty {
    return baseSalary == null &&
        overtime == null &&
        bonus == null &&
        incentive == null &&
        sideIncome1 == null &&
        sideIncome2 == null &&
        sideIncome3 == null &&
        retirement == null;
  }

  double get totalIncome {
    return (baseSalary ?? 0) +
        (overtime ?? 0) +
        (bonus ?? 0) +
        (incentive ?? 0) +
        (sideIncome1 ?? 0) +
        (sideIncome2 ?? 0) +
        (sideIncome3 ?? 0);
  }
}
