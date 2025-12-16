import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/salary_calculation_logic.dart';
import '../widgets/month_selector.dart';
import '../../../../shared/widgets/loading/section_header.dart';

class DemoSalaryResultScreen extends StatefulWidget {
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

  final TextEditingController? baseSalaryController;
  final TextEditingController? overtimeController;
  final TextEditingController? bonusController;
  final TextEditingController? incentiveController;
  final TextEditingController? side1Controller;
  final TextEditingController? side2Controller;
  final TextEditingController? side3Controller;
  final TextEditingController? retirementController;

  final ValueNotifier<DateTime>? currentMonthNotifier;
  final VoidCallback? onNavigateToStep1;

  const DemoSalaryResultScreen({
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
    this.onNavigateToStep1,
  });

  @override
  State<DemoSalaryResultScreen> createState() => _DemoSalaryResultScreenState();
}

class _DemoSalaryResultScreenState extends State<DemoSalaryResultScreen> {
  late final ValueNotifier<DateTime> _currentMonth;
  bool _isDetailsExpanded = false;
  bool _isInvestmentExpanded = false;

  double _investmentPeriod = 0.0;
  double _retirementMonthlyExpense = 0.0;
  double _economicFreedomAmount = 0.0;
  double _totalRequiredInvestment = 0.0;
  double _compoundReturnSum = 0.0;
  double _annualInvestment = 0.0;
  double _pensionInvestment = 0.0;
  double _weeklyInvestment = 0.0;
  double _dailyInvestment = 0.0;
  double _livingExpenseAllocation = 0.0;
  double _retirementInvestment = 0.0;

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
    final results = SalaryCalculationLogic.calculate(
      currentAgeController: widget.currentAgeController,
      retireAgeController: widget.retireAgeController,
      livingExpenseController: widget.livingExpenseController,
      snpValueController: widget.snpValueController,
      expectedReturnController: widget.expectedReturnController,
      inflationController: widget.inflationController,
    );

    _investmentPeriod = results['investmentPeriod']!;
    _retirementMonthlyExpense = results['retirementMonthlyExpense']!;
    _economicFreedomAmount = results['economicFreedomAmount']!;
    _totalRequiredInvestment = results['totalRequiredInvestment']!;
    _compoundReturnSum = results['compoundReturnSum']!;
    _annualInvestment = results['annualInvestment']!;
    _pensionInvestment = results['pensionInvestment']!;
    _weeklyInvestment = results['weeklyInvestment']!;
    _dailyInvestment = results['dailyInvestment']!;

    _retirementInvestment = _parseController(widget.retirementController);
    _pensionInvestment = _pensionInvestment - (_retirementInvestment * 0.7);

    final baseSalary = _parseController(widget.baseSalaryController);
    final overtime = _parseController(widget.overtimeController);
    final bonus = _parseController(widget.bonusController);
    final incentive = _parseController(widget.incentiveController);
    final side1 = _parseController(widget.side1Controller);
    final side2 = _parseController(widget.side2Controller);
    final side3 = _parseController(widget.side3Controller);

    final totalIncome =
        baseSalary + overtime + bonus + incentive + side1 + side2 + side3;

    double shortTermGoalMonthly = 0.0;
    if (widget.hasShortTermGoal == true) {
      final shortTermTargetAmount = _parseController(
        widget.shortTermAmountController,
      );
      final shortTermDurationMonths = _parseController(
        widget.shortTermDurationController,
      );
      final shortTermCurrentSavings = _parseController(
        widget.shortTermSavedController,
      );
      final remainingAmount = shortTermTargetAmount - shortTermCurrentSavings;
      if (shortTermDurationMonths > 0 && remainingAmount > 0) {
        shortTermGoalMonthly = remainingAmount / shortTermDurationMonths;
      }
    }
    _shortTermGoalSaving = shortTermGoalMonthly;

    _emergencyFund = totalIncome * 0.05;
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
    return '$formatted ₩';
  }

  String _monthLabel(DateTime d) => '${d.year}년 ${d.month}월';

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(12.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('월급 최적화'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
            left: Sizes.size20,
            right: Sizes.size20,
            top: Sizes.size12,
            bottom: Sizes.size16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(borderRadius: cardRadius),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SectionHeader(
                          icon: Icons.calculate_outlined,
                          title: '목표 금액',
                          fontSize: Sizes.size16 + Sizes.size4,
                        ),
                      ],
                    ),
                    Gaps.v12,
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
                  SectionHeader(
                    icon: Icons.pie_chart_outline,
                    title: '월급 분리',
                    fontSize: Sizes.size16 + Sizes.size4,
                  ),
                ],
              ),
              Gaps.v12,
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
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            fontFamily: 'Gmarket_sans',
                            fontWeight: FontWeight.w700,
                            fontSize: Sizes.size32,
                          ),
                    ),
                  ],
                ),
              ),
              Gaps.v12,
              _buildAllocationItem(context, '비상금', _emergencyFund),
              Gaps.v12,
              _buildExpandableInvestmentItem(),
              Gaps.v12,
              _buildAllocationItem(context, '단기 목표', _shortTermGoalSaving),
              Gaps.v12,
              _buildAllocationItem(context, '생활비', _livingExpenseAllocation),
              Gaps.v20,
              Column(
                children: [
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
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
                  ClipRect(
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      heightFactor: _isDetailsExpanded ? 1.0 : 0.0,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: _buildDetailsSection(),
                      ),
                    ),
                  ),
                ],
              ),
              Gaps.v20,
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
                    Navigator.pushNamed(context, '/invite_code');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.arrow_forward, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '코드 입력하기',
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
                      onPressed: () async {
                        final Uri googleFormUrl = Uri.parse(
                          'https://docs.google.com/forms/d/e/1FAIpQLScuZW_JS9c7oIxRqtwqC1VOi11XBdgEw11n3AdzF80Fsjgevw/viewform?usp=sharing',
                        );
                        // 외부 브라우저로 열기
                        try {
                          final opened = await launchUrl(
                            googleFormUrl,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!opened && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('구글폼을 열 수 없습니다')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('브라우저를 열 수 없습니다: $e')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.send_outlined),
                      label: const Text(
                        '코드 신청하기',
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
    String formatNumber(String? text) {
      if (text == null || text.isEmpty) return 'N/A';
      if (text.contains(',')) return text;
      final number = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (number == null) return text;
      final intPart = number.toInt();
      return intPart.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }

    String formatAge(String? text) {
      if (text == null || text.isEmpty) return 'N/A';
      return '$text세';
    }

    String formatMonths(String? text) {
      if (text == null || text.isEmpty) return 'N/A';
      return '$text개월';
    }

    String formatPercent(String? text) {
      if (text == null || text.isEmpty) return 'N/A';
      if (text.contains('%')) return text;
      return '$text%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '경제적자유 목표 설정',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        Gaps.v12,
        _buildDetailRow('현재 나이', formatAge(widget.currentAgeController?.text)),
        _buildDetailRow(
          '은퇴 희망 나이',
          formatAge(widget.retireAgeController?.text),
        ),
        _buildDetailRow(
          '현재 희망 생활비',
          formatNumber(widget.livingExpenseController?.text),
        ),
        _buildDetailRow(
          'S&P500 평가금액',
          formatNumber(widget.snpValueController?.text),
        ),
        _buildDetailRow(
          '기대수익률',
          formatPercent(widget.expectedReturnController?.text),
        ),
        _buildDetailRow(
          '예상 물가 상승률',
          formatPercent(widget.inflationController?.text),
        ),
        Gaps.v12,
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
          _buildDetailRow(
            '목표 금액',
            formatNumber(widget.shortTermAmountController?.text),
          ),
          _buildDetailRow(
            '목표 기간',
            formatMonths(widget.shortTermDurationController?.text),
          ),
          _buildDetailRow(
            '현재 저축액',
            formatNumber(widget.shortTermSavedController?.text),
          ),
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
        _buildDetailRow('월급', formatNumber(widget.baseSalaryController?.text)),
        _buildDetailRow('추가 근무', formatNumber(widget.overtimeController?.text)),
        _buildDetailRow('상여금', formatNumber(widget.bonusController?.text)),
        _buildDetailRow('성과급', formatNumber(widget.incentiveController?.text)),
        _buildDetailRow('추가 수입 1', formatNumber(widget.side1Controller?.text)),
        _buildDetailRow('추가 수입 2', formatNumber(widget.side2Controller?.text)),
        _buildDetailRow('추가 수입 3', formatNumber(widget.side3Controller?.text)),
        _buildDetailRow(
          '퇴직금 투자 금액',
          formatNumber(widget.retirementController?.text),
        ),
      ],
    );
  }

  Widget _buildExpandableInvestmentItem() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isInvestmentExpanded = !_isInvestmentExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '투자',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      height: 1.15,
                      fontSize: Sizes.size16 + Sizes.size2,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      _formatCurrency(
                        _pensionInvestment + (_retirementInvestment * 0.7),
                      ),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16 + Sizes.size2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isInvestmentExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            heightFactor: _isInvestmentExpanded ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInvestmentDetailRow('연금저축', _pensionInvestment),
                  const SizedBox(height: 12),
                  _buildInvestmentDetailRow(
                    '퇴직금 투자 (70%)',
                    _retirementInvestment * 0.7,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentDetailRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            color: Colors.grey.shade700,
            fontSize: Sizes.size14,
          ),
        ),
        Text(
          _formatCurrency(amount),
          style: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w600,
            fontSize: Sizes.size14,
          ),
        ),
      ],
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
