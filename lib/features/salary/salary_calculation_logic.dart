import 'package:flutter/material.dart';
import 'dart:math';

class SalaryCalculationLogic {
  // 입력값 파싱 헬퍼
  static double _parseController(TextEditingController? c) {
    if (c == null) return 0.0;
    final t = c.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(t) ?? 0.0;
  }

  // 전체 계산 실행
  static Map<String, double> calculate({
    required TextEditingController? currentAgeController,
    required TextEditingController? retireAgeController,
    required TextEditingController? livingExpenseController,
    required TextEditingController? snpValueController,
    required TextEditingController? expectedReturnController,
    required TextEditingController? inflationController,
  }) {
    // 입력값 파싱
    final currentAge = _parseController(currentAgeController);
    final retireAge = _parseController(retireAgeController);
    final livingExpense = _parseController(livingExpenseController);
    final snpCurrentValue = _parseController(snpValueController);
    final expectedReturnPercent = _parseController(expectedReturnController);
    final inflationRatePercent = _parseController(inflationController);

    // 퍼센트를 소수로 변환 (예: 7% -> 0.07)
    final expectedReturn = expectedReturnPercent / 100.0;
    final inflationRate = inflationRatePercent / 100.0;

    // === 1. 투자 기간 ===
    double investmentPeriod = retireAge - currentAge;
    if (investmentPeriod < 0) investmentPeriod = 0;

    // === 2. 은퇴 후 필요 월 생활비 ===
    double retirementMonthlyExpense;
    if (livingExpense <= 0 || investmentPeriod == 0) {
      retirementMonthlyExpense = livingExpense;
    } else {
      retirementMonthlyExpense =
          livingExpense * pow(1 + inflationRate, investmentPeriod);
    }

    // === 3. 경제적 자유 금액 ===
    final economicFreedomAmount = retirementMonthlyExpense * 12 * 25;

    // === 4. 총 필요 투자금 ===
    double futureSnpValue;
    if (investmentPeriod == 0) {
      futureSnpValue = snpCurrentValue;
    } else {
      futureSnpValue =
          snpCurrentValue * pow(1 + expectedReturn, investmentPeriod);
    }
    double totalRequiredInvestment = economicFreedomAmount - futureSnpValue;
    if (totalRequiredInvestment < 0) totalRequiredInvestment = 0;

    // === 5. 복리 누적합 ===
    double compoundReturnSum;
    if (investmentPeriod <= 0) {
      compoundReturnSum = 0;
    } else if (expectedReturn == 0) {
      // 기대수익률이 0%일 때
      compoundReturnSum = investmentPeriod;
    } else {
      // 등비수열의 합 공식 사용
      // Sum = [(1+r)^(n+1) - (1+r)] / r
      final r = 1 + expectedReturn;
      compoundReturnSum = (pow(r, investmentPeriod + 1) - r) / expectedReturn;
    }

    // === 6. 연 투자금 ===
    double annualInvestment;
    if (compoundReturnSum == 0) {
      annualInvestment = 0;
    } else {
      annualInvestment = totalRequiredInvestment / compoundReturnSum;
    }

    // === 7. 월/주/일 투자금 ===
    final pensionInvestment = annualInvestment / 12;
    final weeklyInvestment = annualInvestment / 52;
    final dailyInvestment = annualInvestment / 365;

    // 결과 반환
    return {
      'investmentPeriod': investmentPeriod,
      'retirementMonthlyExpense': retirementMonthlyExpense,
      'economicFreedomAmount': economicFreedomAmount,
      'totalRequiredInvestment': totalRequiredInvestment,
      'compoundReturnSum': compoundReturnSum,
      'annualInvestment': annualInvestment,
      'pensionInvestment': pensionInvestment,
      'weeklyInvestment': weeklyInvestment,
      'dailyInvestment': dailyInvestment,
    };
  }
}
