// lib/features/salary/salary_result_screen.dart
import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'salary_calculation_logic.dart';

class SalaryResultScreen extends StatefulWidget {
  // Step1 data
  final TextEditingController? currentAgeController;
  final TextEditingController? retireAgeController;
  final TextEditingController? livingExpenseController;
  final TextEditingController? snpValueController;
  final TextEditingController? expectedReturnController;
  final TextEditingController? inflationController;
  final bool? hasShortTermGoal;
  final String? selectedShortTermGoal;
  final TextEditingController? shortTermAmountController;
  final TextEditingController? shortTermDurationController;
  final TextEditingController? shortTermSavedController;

  // Step2 data
  final TextEditingController? baseSalaryController;
  final TextEditingController? overtimeController;
  final TextEditingController? bonusController;
  final TextEditingController? incentiveController;
  final TextEditingController? side1Controller;
  final TextEditingController? side2Controller;
  final TextEditingController? side3Controller;
  final TextEditingController? retirementController;

  final ValueNotifier<DateTime>? currentMonthNotifier;

  const SalaryResultScreen({
    super.key,
    this.currentAgeController,
    this.retireAgeController,
    this.livingExpenseController,
    this.snpValueController,
    this.expectedReturnController,
    this.inflationController,
    this.hasShortTermGoal,
    this.selectedShortTermGoal,
    this.shortTermAmountController,
    this.shortTermDurationController,
    this.shortTermSavedController,
    this.baseSalaryController,
    this.overtimeController,
    this.bonusController,
    this.incentiveController,
    this.side1Controller,
    this.side2Controller,
    this.side3Controller,
    this.retirementController,
    this.currentMonthNotifier,
  });

  @override
  State<SalaryResultScreen> createState() => _SalaryResultScreenState();
}

class _SalaryResultScreenState extends State<SalaryResultScreen> {
  late final ValueNotifier<DateTime> _currentMonth;
  bool _isDetailsExpanded = false;

  // Calculated values from SalaryCalculationLogic
  double _investmentPeriod = 0.0;
  double _retirementMonthlyExpense = 0.0;
  double _economicFreedomAmount = 0.0;
  double _totalRequiredInvestment = 0.0;
  double _compoundReturnSum = 0.0;
  double _annualInvestment = 0.0;
  double _pensionInvestment = 0.0;
  double _weeklyInvestment = 0.0;
  double _dailyInvestment = 0.0;
  double _livingExpenseAllocation = 0.0; // 추가: 생활비

  // Step2 income values
  double _totalMonthlyAllocation = 0.0;
  double _emergencyFund = 0.0;
  final double _pensionSaving = 0.0;
  double _shortTermGoalSaving = 0.0;

  @override
  void initState() {
    super.initState();
    _currentMonth =
        widget.currentMonthNotifier ?? ValueNotifier<DateTime>(DateTime.now());
    _currentMonth.addListener(_onMonthChanged);
    _calculateAll();
  }

  void _onMonthChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _currentMonth.removeListener(_onMonthChanged);
    if (widget.currentMonthNotifier == null) {
      _currentMonth.dispose();
    }
    super.dispose();
  }

  double _parseController(TextEditingController? c) {
    if (c == null) return 0.0;
    final t = c.text.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(t) ?? 0.0;
  }

  void _calculateAll() {
    // === 1. SalaryCalculationLogic으로 경제적자유 관련 계산 ===
    final results = SalaryCalculationLogic.calculate(
      currentAgeController: widget.currentAgeController,
      retireAgeController: widget.retireAgeController,
      livingExpenseController: widget.livingExpenseController,
      snpValueController: widget.snpValueController,
      expectedReturnController: widget.expectedReturnController,
      inflationController: widget.inflationController,
    );

    // 계산 결과 저장
    _investmentPeriod = results['investmentPeriod']!;
    _retirementMonthlyExpense = results['retirementMonthlyExpense']!;
    _economicFreedomAmount = results['economicFreedomAmount']!;
    _totalRequiredInvestment = results['totalRequiredInvestment']!;
    _compoundReturnSum = results['compoundReturnSum']!;
    _annualInvestment = results['annualInvestment']!;
    _pensionInvestment = results['pensionInvestment']!;
    _weeklyInvestment = results['weeklyInvestment']!;
    _dailyInvestment = results['dailyInvestment']!;

    // === 2. Step2 수입 계산 ===
    final baseSalary = _parseController(widget.baseSalaryController);
    final overtime = _parseController(widget.overtimeController);
    final bonus = _parseController(widget.bonusController);
    final incentive = _parseController(widget.incentiveController);
    final side1 = _parseController(widget.side1Controller);
    final side2 = _parseController(widget.side2Controller);
    final side3 = _parseController(widget.side3Controller);
    final retirement = _parseController(widget.retirementController);

    final totalIncome =
        baseSalary + overtime + bonus + incentive + side1 + side2 + side3;

    double shortTermGoalMonthly = 0.0;

    if (widget.hasShortTermGoal == true) {
      // Step1에서 입력한 단기 목표 데이터
      final shortTermTargetAmount = _parseController(
        widget.shortTermAmountController,
      ); // 목표 금액
      final shortTermDurationMonths = _parseController(
        widget.shortTermDurationController,
      ); // 목표 기간 (월)
      final shortTermCurrentSavings = _parseController(
        widget.shortTermSavedController,
      ); // 현재 저축액

      // 남은 금액 계산
      final remainingAmount = shortTermTargetAmount - shortTermCurrentSavings;

      // 월 저축액 계산 = 남은 금액 / 남은 기간
      if (shortTermDurationMonths > 0 && remainingAmount > 0) {
        shortTermGoalMonthly = remainingAmount / shortTermDurationMonths;
      }
    }

    _shortTermGoalSaving = shortTermGoalMonthly;

    // === 4. 월급 분리 로직 ===
    _emergencyFund = totalIncome * 0.05; // 5% 비상금

    final livingExpense =
        totalIncome -
        (_emergencyFund + _pensionInvestment + _shortTermGoalSaving);
    _livingExpenseAllocation = livingExpense > 0 ? livingExpense : 0;

    _totalMonthlyAllocation = totalIncome;

    setState(() {});
  }

  String _formatCurrency(double value) {
    final intPart = value.round();
    final s = intPart.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write(',');
    }
    final formatted = buffer.toString().split('').reversed.join();
    return '\$$formatted';
  }

  String _monthLabel(DateTime d) {
    return '${d.year}년 ${d.month}월';
  }

  void _showApplyModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gaps.v24,
                Text(
                  '예산에 적용하기',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.size24,
                  ),
                ),
              ],
            ),
            Gaps.v8,
            Text(
              '월급 최적화 금액을 몇 월 예산에 적용하시겠습니까?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Gmarket_sans',
                color: Colors.grey.shade600,
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.v24,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _applyToBudget('next');
                },
                child: const Text(
                  '다음 달',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Gaps.v12,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: Colors.black, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _applyToBudget('this');
                },
                child: const Text(
                  '이번 달',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Gaps.v12,
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyToBudget(String period) {
    // TODO: Implement budget integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Applied to $period month budget (stub)')),
    );
  }

  Future<void> _saveResult() async {
    // TODO: Implement save logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Result saved (stub)')));
  }

  void _showEditConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 24),
                Text(
                  '수정하시겠습니까?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close modal
                  Navigator.pop(context); // Go back to edit
                },
                child: const Text(
                  '수정',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(12.0); // 이 줄 추가

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          '월급 최적화',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontFamily: "Gmarket_sans",
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: Sizes.size20,
          right: Sizes.size20,
          top: Sizes.size2,
          bottom: Sizes.size16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    final prev = DateTime(
                      _currentMonth.value.year,
                      _currentMonth.value.month - 1,
                    );
                    _currentMonth.value = prev;
                  },
                ),
                Text(
                  _monthLabel(_currentMonth.value),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontSize: Sizes.size16 + Sizes.size2,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final next = DateTime(
                      _currentMonth.value.year,
                      _currentMonth.value.month + 1,
                    );
                    _currentMonth.value = next;
                  },
                ),
              ],
            ),

            Gaps.v12,

            // // Automatic Allocation subtitle
            // Center(
            //   child: Text(
            //     '월급 자동 배분 결과',
            //     style: Theme.of(
            //       context,
            //     ).textTheme.bodyLarge?.copyWith(fontFamily: 'Gmarket_sans'),
            //   ),
            // ),

            // calculated targets card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(borderRadius: cardRadius),
              child: Column(
                children: [
                  // header
                  Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '목표 금액',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontFamily: 'Gmarket_sans',
                              fontWeight: FontWeight.w700,
                              fontSize: Sizes.size16 + Sizes.size4,
                            ),
                      ),
                    ],
                  ),
                  Gaps.v12, // first item
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '은퇴 후 필요 생활비',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontFamily: 'Gmarket_sans',
                                  height: 1.15,
                                  fontSize: Sizes.size16 + Sizes.size2,
                                ),
                          ),
                        ),
                        Text(
                          _formatCurrency(_retirementMonthlyExpense),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w700,
                                fontSize: Sizes.size16 + Sizes.size2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Gaps.v10,
                  // second item
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '경제적자유 금액',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontFamily: 'Gmarket_sans',
                                  height: 1.15,
                                  fontSize: Sizes.size16 + Sizes.size2,
                                ),
                          ),
                        ),
                        Text(
                          _formatCurrency(_economicFreedomAmount),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w700,
                                fontSize: Sizes.size16 + Sizes.size2,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Gaps.v32,
            Row(
              children: [
                const Icon(Icons.pie_chart_outline, size: 18),
                const SizedBox(width: 8),
                Text(
                  '월급 분리',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.size16 + Sizes.size4,
                  ),
                ),
              ],
            ),
            Gaps.v12,
            // Total Monthly Allocation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '총 수입액',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Gmarket_sans',
                      fontSize: Sizes.size16 + Sizes.size2,
                    ),
                  ),
                  Gaps.v8,
                  Text(
                    _formatCurrency(_totalMonthlyAllocation),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size32,
                    ),
                  ),
                ],
              ),
            ),

            // Gaps.v32,

            // Allocation Breakdown
            // Text(
            //   '월급 분리 내역',
            //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
            //     fontFamily: 'Gmarket_sans',
            //     fontWeight: FontWeight.w700,
            //   ),
            // ),
            Gaps.v12,

            // Emergency Fund
            _buildAllocationItem(context, '비상금', _emergencyFund),

            Gaps.v12,

            // Pension Saving
            _buildAllocationItem(context, '연금 저축', _pensionInvestment),

            Gaps.v12,

            // Short-term Goal Saving
            _buildAllocationItem(context, '단기 목표', _shortTermGoalSaving),

            Gaps.v12,

            // Living Expense
            _buildAllocationItem(context, '생활비', _livingExpenseAllocation),

            Gaps.v20,

            // Input Details (Expandable)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDetailsExpanded = !_isDetailsExpanded;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '입력한 세부 정보 보기',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Icon(
                      _isDetailsExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),

            if (_isDetailsExpanded) ...[Gaps.v16, _buildDetailsSection()],

            Gaps.v20,

            // Apply to Budget Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _showApplyModal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_forward, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '예산에 적용하기',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Gaps.v16,

            // Bottom buttons row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(56),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _showEditConfirmation,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(
                      '수정',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16 + Sizes.size2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(56),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveResult,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text(
                      '저장',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16 + Sizes.size2,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Gaps.v24,
          ],
        ),
      ),
    );
  }

  Widget _buildAllocationItem(
    BuildContext context,
    String title,
    double amount,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w400,
                height: 1.15,
                fontSize: Sizes.size16 + Sizes.size2,
              ),
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
              fontSize: Sizes.size16 + Sizes.size2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '경제적자유 목표 설정',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          Gaps.v12,
          _buildDetailRow('현재 나이', widget.currentAgeController?.text),
          _buildDetailRow('은퇴 희망 나이', widget.retireAgeController?.text),
          _buildDetailRow('현재 희망 생활비', widget.livingExpenseController?.text),
          _buildDetailRow('S&P500 평가금액', widget.snpValueController?.text),
          _buildDetailRow('기대수익률', widget.expectedReturnController?.text),
          _buildDetailRow('예상 물가 상승률', widget.inflationController?.text),

          Gaps.v12,

          // 단기 목표 섹션
          Text(
            '단기 목표',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          Gaps.v8,
          if (widget.hasShortTermGoal == true) ...[
            _buildDetailRow('목표', widget.selectedShortTermGoal),
            _buildDetailRow('목표 금액', widget.shortTermAmountController?.text),
            _buildDetailRow(
              '목표 기간 (월)',
              widget.shortTermDurationController?.text,
            ),
            _buildDetailRow('현재 저축액', widget.shortTermSavedController?.text),
          ] else
            Text(
              '없음',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                color: Colors.grey.shade600,
              ),
            ),

          Gaps.v20,

          Text(
            '월 수입 세부사항',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          Gaps.v12,
          _buildDetailRow('월급', widget.baseSalaryController?.text),
          _buildDetailRow('추가 근무', widget.overtimeController?.text),
          _buildDetailRow('상여금', widget.bonusController?.text),
          _buildDetailRow('성과급', widget.incentiveController?.text),
          _buildDetailRow('추가 수입 1', widget.side1Controller?.text),
          _buildDetailRow('추가 수입 2', widget.side2Controller?.text),
          _buildDetailRow('추가 수입 3', widget.side3Controller?.text),
          _buildDetailRow('퇴직금 투자 금액', widget.retirementController?.text),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
