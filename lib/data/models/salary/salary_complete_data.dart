import 'package:cloud_firestore/cloud_firestore.dart';
import 'salary_step1_data.dart';
import 'salary_step2_data.dart';
import 'salary_result_data.dart';

class SalaryCompleteData {
  final SalaryStep1Data step1;
  final SalaryStep2Data step2;
  final SalaryResultData result;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalaryCompleteData({
    required this.step1,
    required this.step2,
    required this.result,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'step1': step1.toJson(),
      'step2': step2.toJson(),
      'result': result.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory SalaryCompleteData.fromJson(Map<String, dynamic> json) {
    final step1Raw   = json['step1'];
    final step2Raw   = json['step2'];
    final resultRaw  = json['result'];
    final createdRaw = json['createdAt'];
    final updatedRaw = json['updatedAt'];

    return SalaryCompleteData(
      step1: step1Raw is Map<String, dynamic>
          ? SalaryStep1Data.fromJson(step1Raw)
          : SalaryStep1Data(),

      step2: step2Raw is Map<String, dynamic>
          ? SalaryStep2Data.fromJson(step2Raw)
          : SalaryStep2Data(),

      result: resultRaw is Map<String, dynamic>
          ? SalaryResultData.fromJson(resultRaw)
          : SalaryResultData(
              emergencyFund: 0,
              pensionInvestment: 0,
              retirementInvestment: 0,
              shortTermGoalSaving: 0,
              livingExpense: 0,
              totalIncome: 0,
              retirementMonthlyExpense: 0,
              economicFreedomAmount: 0,
            ),

      createdAt: createdRaw is Timestamp
          ? createdRaw.toDate()
          : DateTime.now(),

      updatedAt: updatedRaw is Timestamp
          ? updatedRaw.toDate()
          : DateTime.now(),
    );
  }
}
