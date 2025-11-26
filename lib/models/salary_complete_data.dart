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
    return SalaryCompleteData(
      step1: SalaryStep1Data.fromJson(json['step1'] as Map<String, dynamic>),
      step2: SalaryStep2Data.fromJson(json['step2'] as Map<String, dynamic>),
      result: SalaryResultData.fromJson(json['result'] as Map<String, dynamic>),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}
