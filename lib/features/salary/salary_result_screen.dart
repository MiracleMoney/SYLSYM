// lib/features/salary/salary_result_screen.dart
import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'dart:math';

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

  // Calculated values
  double _totalMonthlyAllocation = 0.0;
  double _emergencyFund = 0.0;
  double _pensionSaving = 0.0;
  double _shortTermGoalSaving = 0.0;
  double _livingExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _currentMonth =
        widget.currentMonthNotifier ?? ValueNotifier<DateTime>(DateTime.now());
    _currentMonth.addListener(_onMonthChanged);
    _calculateAllocations();
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

  void _calculateAllocations() {
    // Step2 income
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

    // Step1 data for calculations
    final living = _parseController(widget.livingExpenseController);
    final currentAge = _parseController(widget.currentAgeController);
    final retireAge = _parseController(widget.retireAgeController);
    final inflationPercent =
        _parseController(widget.inflationController) / 100.0;

    final yearsRaw = retireAge - currentAge;
    final years = yearsRaw > 0 ? yearsRaw : 0.0;

    // Calculate future living expense
    double monthlyExpense;
    if (living <= 0) {
      monthlyExpense = 0.0;
    } else {
      final inflation = 1 + inflationPercent;
      if (inflation <= 0) {
        monthlyExpense = living;
      } else {
        monthlyExpense = (pow(inflation, years) * living).toDouble();
      }
    }

    // Allocation logic (simplified example)
    _emergencyFund = totalIncome * 0.15; // 15% emergency
    _pensionSaving = retirement; // retirement contribution
    _shortTermGoalSaving = totalIncome * 0.10; // 10% short term goal
    _livingExpense = monthlyExpense;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  'Apply Allocation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Where should this allocation be applied?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'Gmarket_sans',
                color: Colors.grey.shade600,
              ),
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
                  Navigator.pop(context);
                  _applyToBudget('this');
                },
                child: const Text(
                  'This Month',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
                  _applyToBudget('next');
                },
                child: const Text(
                  'Next Month',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  '수정하시겠습니까?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.size20,
          vertical: Sizes.size16,
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

            // Automatic Allocation subtitle
            Center(
              child: Text(
                'Automatic Allocation',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Gmarket_sans',
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            Gaps.v16,

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
                    'Total Monthly Allocation',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Gmarket_sans',
                      color: Colors.grey.shade600,
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

            Gaps.v32,

            // Allocation Breakdown
            Text(
              '월급 분리 내역',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
              ),
            ),

            Gaps.v12,

            // Emergency Fund
            _buildAllocationItem(
              context,
              '비상금',
              'Monthly savings for emergencies',
              _emergencyFund,
            ),

            Gaps.v12,

            // Pension Saving
            _buildAllocationItem(
              context,
              '연금 저축',
              'Retirement investment allocation',
              _pensionSaving,
            ),

            Gaps.v12,

            // Short-term Goal Saving
            _buildAllocationItem(
              context,
              '단기 목표',
              'Monthly savings for your goal',
              _shortTermGoalSaving,
            ),

            Gaps.v12,

            // Living Expense
            _buildAllocationItem(
              context,
              '생활비',
              'Monthly living expenses budget',
              _livingExpense,
            ),

            Gaps.v32,

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
                        fontWeight: FontWeight.w700,
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

            Gaps.v32,

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
    String subtitle,
    double amount,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'Gmarket_sans',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
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
            'Step 1 - Financial Goals',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          Gaps.v12,
          _buildDetailRow('Current Age', widget.currentAgeController?.text),
          _buildDetailRow(
            'Monthly Expenses',
            widget.livingExpenseController?.text,
          ),
          _buildDetailRow('Retirement Age', widget.retireAgeController?.text),
          _buildDetailRow('Return Rate', widget.expectedReturnController?.text),
          _buildDetailRow('Inflation Rate', widget.inflationController?.text),

          Gaps.v20,

          Text(
            'Step 2 - Income Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          Gaps.v12,
          _buildDetailRow('Base Salary', widget.baseSalaryController?.text),
          _buildDetailRow('Bonus', widget.bonusController?.text),
          _buildDetailRow('Side Income', widget.side1Controller?.text),
          _buildDetailRow(
            'Retirement Investment',
            widget.retirementController?.text,
          ),
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
