class SalaryResultData {
  final double emergencyFund;
  final double pensionInvestment;
  final double retirementInvestment;
  final double shortTermGoalSaving;
  final double livingExpense;
  final double totalIncome;
  final double retirementMonthlyExpense;
  final double economicFreedomAmount;

  SalaryResultData({
    required this.emergencyFund,
    required this.pensionInvestment,
    required this.retirementInvestment,
    required this.shortTermGoalSaving,
    required this.livingExpense,
    required this.totalIncome,
    required this.retirementMonthlyExpense,
    required this.economicFreedomAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'emergencyFund': emergencyFund,
      'pensionInvestment': pensionInvestment,
      'retirementInvestment': retirementInvestment,
      'shortTermGoalSaving': shortTermGoalSaving,
      'livingExpense': livingExpense,
      'totalIncome': totalIncome,
      'retirementMonthlyExpense': retirementMonthlyExpense,
      'economicFreedomAmount': economicFreedomAmount,
    };
  }

  factory SalaryResultData.fromJson(Map<String, dynamic> json) {
    return SalaryResultData(
      emergencyFund: (json['emergencyFund'] as num?)?.toDouble() ?? 0,
      pensionInvestment: (json['pensionInvestment'] as num?)?.toDouble() ?? 0,
      retirementInvestment:
          (json['retirementInvestment'] as num?)?.toDouble() ?? 0,
      shortTermGoalSaving:
          (json['shortTermGoalSaving'] as num?)?.toDouble() ?? 0,
      livingExpense: (json['livingExpense'] as num?)?.toDouble() ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
      retirementMonthlyExpense:
          (json['retirementMonthlyExpense'] as num?)?.toDouble() ?? 0,
      economicFreedomAmount:
          (json['economicFreedomAmount'] as num?)?.toDouble() ?? 0,
    );
  }
}
