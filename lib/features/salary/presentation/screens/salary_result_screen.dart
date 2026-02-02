// lib/features/salary/salary_result_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import '../../data/salary_calculation_logic.dart';
// 파일 상단에 import 추가
import '../../../../data/services/firestore_service.dart';
import '../../../../data/models/salary/salary_complete_data.dart';
import '../../../../data/models/salary/salary_step1_data.dart';
import '../../../../data/models/salary/salary_step2_data.dart';
import '../../../../data/models/salary/salary_result_data.dart';
import '../widgets/month_selector.dart';
import '../../../../shared/widgets/loading/section_header.dart';
import '../../../../core/utils/app_error.dart';
import '../../../../core/utils/error_handler.dart';

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
  final VoidCallback? onNavigateToStep1; // ✅ 추가

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
    this.onNavigateToStep1, // ✅ 추가
  });

  @override
  State<SalaryResultScreen> createState() => _SalaryResultScreenState();
}

class _SalaryResultScreenState extends State<SalaryResultScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late final ValueNotifier<DateTime> _currentMonth;
  bool _isDetailsExpanded = false;
  bool _isInvestmentExpanded = false; // 투자 세부 내역 확장 상태

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
  double _retirementInvestment = 0.0; // 퇴직금 투자액 추가

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

    // 모든 컨트롤러에 리스너 추가
    _addControllersListener();

    _calculateAll();
  }

  /// 모든 컨트롤러에 리스너 추가
  void _addControllersListener() {
    // Step2 컨트롤러
    widget.baseSalaryController?.addListener(_onControllerChanged);
    widget.overtimeController?.addListener(_onControllerChanged);
    widget.bonusController?.addListener(_onControllerChanged);
    widget.incentiveController?.addListener(_onControllerChanged);
    widget.side1Controller?.addListener(_onControllerChanged);
    widget.side2Controller?.addListener(_onControllerChanged);
    widget.side3Controller?.addListener(_onControllerChanged);
    widget.retirementController?.addListener(_onControllerChanged);

    // Step1 컨트롤러
    widget.livingExpenseController?.addListener(_onControllerChanged);
    widget.currentAgeController?.addListener(_onControllerChanged);
    widget.retireAgeController?.addListener(_onControllerChanged);
    widget.snpValueController?.addListener(_onControllerChanged);
    widget.expectedReturnController?.addListener(_onControllerChanged);
    widget.inflationController?.addListener(_onControllerChanged);
    widget.shortTermAmountController?.addListener(_onControllerChanged);
    widget.shortTermDurationController?.addListener(_onControllerChanged);
    widget.shortTermSavedController?.addListener(_onControllerChanged);
  }

  /// 컨트롤러 값 변경 시 호출
  void _onControllerChanged() {
    if (kDebugMode) {
      print('🔄 컨트롤러 값 변경 감지 - 재계산 시작');
    }
    setState(() {
      _calculateAll();
    });
  }

  @override
  void didUpdateWidget(SalaryResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ 컨트롤러가 변경되었으면 (수정 후 재진입) 재계산
    if (_hasControllersChanged(oldWidget)) {
      if (kDebugMode) {
        print('🔄 컨트롤러 값 변경 감지 - 재계산 시작');
      }
      _calculateAll();
    }
  }

  /// 컨트롤러 값이 변경되었는지 확인
  bool _hasControllersChanged(SalaryResultScreen oldWidget) {
    // Step2 컨트롤러 비교 (수입 관련)
    if (widget.baseSalaryController?.text !=
        oldWidget.baseSalaryController?.text)
      return true;
    if (widget.overtimeController?.text != oldWidget.overtimeController?.text)
      return true;
    if (widget.bonusController?.text != oldWidget.bonusController?.text)
      return true;
    if (widget.incentiveController?.text != oldWidget.incentiveController?.text)
      return true;
    if (widget.side1Controller?.text != oldWidget.side1Controller?.text)
      return true;
    if (widget.side2Controller?.text != oldWidget.side2Controller?.text)
      return true;
    if (widget.side3Controller?.text != oldWidget.side3Controller?.text)
      return true;
    if (widget.retirementController?.text !=
        oldWidget.retirementController?.text)
      return true;

    // Step1 컨트롤러 비교
    if (widget.livingExpenseController?.text !=
        oldWidget.livingExpenseController?.text)
      return true;
    if (widget.currentAgeController?.text !=
        oldWidget.currentAgeController?.text)
      return true;
    if (widget.retireAgeController?.text != oldWidget.retireAgeController?.text)
      return true;
    if (widget.snpValueController?.text != oldWidget.snpValueController?.text)
      return true;
    if (widget.expectedReturnController?.text !=
        oldWidget.expectedReturnController?.text)
      return true;
    if (widget.inflationController?.text != oldWidget.inflationController?.text)
      return true;
    if (widget.shortTermAmountController?.text !=
        oldWidget.shortTermAmountController?.text)
      return true;
    if (widget.shortTermDurationController?.text !=
        oldWidget.shortTermDurationController?.text)
      return true;
    if (widget.shortTermSavedController?.text !=
        oldWidget.shortTermSavedController?.text)
      return true;

    return false;
  }

  void _onMonthChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  @override
  void dispose() {
    _currentMonth.removeListener(_onMonthChanged);
    if (widget.currentMonthNotifier == null) {
      _currentMonth.dispose();
    }

    // 모든 컨트롤러 리스너 제거
    _removeControllersListener();

    super.dispose();
  }

  /// 모든 컨트롤러 리스너 제거
  void _removeControllersListener() {
    // Step2 컨트롤러
    widget.baseSalaryController?.removeListener(_onControllerChanged);
    widget.overtimeController?.removeListener(_onControllerChanged);
    widget.bonusController?.removeListener(_onControllerChanged);
    widget.incentiveController?.removeListener(_onControllerChanged);
    widget.side1Controller?.removeListener(_onControllerChanged);
    widget.side2Controller?.removeListener(_onControllerChanged);
    widget.side3Controller?.removeListener(_onControllerChanged);
    widget.retirementController?.removeListener(_onControllerChanged);

    // Step1 컨트롤러
    widget.livingExpenseController?.removeListener(_onControllerChanged);
    widget.currentAgeController?.removeListener(_onControllerChanged);
    widget.retireAgeController?.removeListener(_onControllerChanged);
    widget.snpValueController?.removeListener(_onControllerChanged);
    widget.expectedReturnController?.removeListener(_onControllerChanged);
    widget.inflationController?.removeListener(_onControllerChanged);
    widget.shortTermAmountController?.removeListener(_onControllerChanged);
    widget.shortTermDurationController?.removeListener(_onControllerChanged);
    widget.shortTermSavedController?.removeListener(_onControllerChanged);
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

    // === 2. 퇴직금 투자액 계산 ===
    _retirementInvestment = _parseController(widget.retirementController);

    // _pensionInvestment에서 퇴직금의 70%를 뺌
    _pensionInvestment = _pensionInvestment - (_retirementInvestment * 0.7);

    // === 3. Step2 수입 계산 ===
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
    return '$formatted ₩';
  }

  String _monthLabel(DateTime d) {
    return '${d.year}년 ${d.month}월';
  }

  void _showApplyModal() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
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

  /// ✅ 개선된 저장 메서드
  Future<void> _saveResult() async {
    // 1. 저장 중 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 16),
            Text('저장 중...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      // 2. Step1 데이터 생성
      final step1Data = SalaryStep1Data(
        currentAge: int.tryParse(widget.currentAgeController?.text ?? ''),
        retireAge: int.tryParse(widget.retireAgeController?.text ?? ''),
        livingExpense: _parseController(widget.livingExpenseController),
        snpValue: _parseController(widget.snpValueController),
        expectedReturn: _parseController(widget.expectedReturnController),
        inflation: _parseController(widget.inflationController),
        hasShortTermGoal: widget.hasShortTermGoal ?? false,
        shortTermGoal: widget.selectedShortTermGoal,
        shortTermAmount: _parseController(widget.shortTermAmountController),
        shortTermDuration: int.tryParse(
          widget.shortTermDurationController?.text ?? '',
        ),
        shortTermSaved: _parseController(widget.shortTermSavedController),
      );

      // 3. Step2 데이터 생성
      final step2Data = SalaryStep2Data(
        baseSalary: _parseController(widget.baseSalaryController),
        overtime: _parseController(widget.overtimeController),
        bonus: _parseController(widget.bonusController),
        incentive: _parseController(widget.incentiveController),
        sideIncome1: _parseController(widget.side1Controller),
        sideIncome2: _parseController(widget.side2Controller),
        sideIncome3: _parseController(widget.side3Controller),
        retirement: _parseController(widget.retirementController),
      );

      // 4. Result 데이터 생성
      final resultData = SalaryResultData(
        emergencyFund: _emergencyFund,
        pensionInvestment: _pensionInvestment,
        retirementInvestment: _retirementInvestment * 0.7,
        shortTermGoalSaving: _shortTermGoalSaving,
        livingExpense: _livingExpenseAllocation,
        totalIncome: _totalMonthlyAllocation,
        retirementMonthlyExpense: _retirementMonthlyExpense,
        economicFreedomAmount: _economicFreedomAmount,
      );

      // 5. 전체 데이터 통합
      final completeData = SalaryCompleteData(
        step1: step1Data,
        step2: step2Data,
        result: resultData,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 6. Firebase에 저장
      await _firestoreService.saveSalaryData(
        completeData,
        targetDate: _currentMonth.value,
      );

      // 7. 성공 메시지
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${_currentMonth.value.year}년 ${_currentMonth.value.month}월 데이터가 저장되었습니다!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
    } on AppError catch (appError) {
      // ✅ AppError 처리 (사용자 친화적)
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(appError.userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: _getErrorAction(appError.type),
          ),
        );

      // 개발 모드에서만 기술적 메시지 출력
      if (kDebugMode && appError.technicalMessage != null) {
        print('기술적 오류: ${appError.technicalMessage}');
      }
    } catch (e) {
      // ✅ 예상치 못한 에러
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('예상치 못한 오류가 발생했습니다.\n앱을 다시 시작해주세요.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );

      if (kDebugMode) {
        print('예상치 못한 오류: $e');
      }
    }
  }

  /// ✅ 에러 타입에 맞는 액션 버튼 생성
  SnackBarAction? _getErrorAction(ErrorType type) {
    final label = ErrorHandler.getActionLabel(type);
    if (label == null) return null;

    return SnackBarAction(
      label: label,
      textColor: Colors.white,
      onPressed: () {
        switch (type) {
          case ErrorType.network:
            _saveResult(); // 다시 시도
            break;
          case ErrorType.permission:
            // TODO: 로그인 화면으로 이동
            if (kDebugMode) {
              print('로그인 화면으로 이동 필요');
            }
            break;
          default:
            break;
        }
      },
    );
  }

  void _showEditConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        color: Colors.white,
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
                  Navigator.pop(context); // ✅ 모달만 닫기
                  if (widget.onNavigateToStep1 != null) {
                    widget.onNavigateToStep1!(); // ✅ Step1으로 이동 콜백 호출
                  }
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: Sizes.size20,
          right: Sizes.size20,
          top: Sizes.size1,
          bottom: Sizes.size16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            MonthSelector(
              currentMonth: _currentMonth.value,
              onPreviousMonth: () {
                final prev = DateTime(
                  _currentMonth.value.year,
                  _currentMonth.value.month - 1,
                );
                _currentMonth.value = prev;
              },
              onNextMonth: () {
                final next = DateTime(
                  _currentMonth.value.year,
                  _currentMonth.value.month + 1,
                );
                _currentMonth.value = next;
              },
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
                      SectionHeader(
                        icon: Icons.calculate_outlined,
                        title: '목표 금액',
                        fontSize: Sizes.size16 + Sizes.size2,
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
                      border: Border.all(color: Colors.grey.shade300),
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
                                  fontSize: Sizes.size16,
                                ),
                          ),
                        ),
                        Text(
                          _formatCurrency(_retirementMonthlyExpense),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w700,
                                fontSize: Sizes.size16,
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
                      border: Border.all(color: Colors.grey.shade300),
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
                                  fontSize: Sizes.size16,
                                ),
                          ),
                        ),
                        Text(
                          _formatCurrency(_economicFreedomAmount),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w700,
                                fontSize: Sizes.size16,
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
                  fontSize: Sizes.size16 + Sizes.size2,
                ),
              ],
            ),
            Gaps.v12,
            // Total Monthly Allocation Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '총 수입액',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Gmarket_sans',
                      fontSize: Sizes.size16,
                    ),
                  ),
                  Gaps.v8,
                  Text(
                    _formatCurrency(_totalMonthlyAllocation),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                      fontSize: Sizes.size24,
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
            _buildExpandableInvestmentItem(),

            Gaps.v12,

            // Short-term Goal Saving
            _buildAllocationItem(context, '단기 목표', _shortTermGoalSaving),

            Gaps.v12,

            // Living Expense
            _buildAllocationItem(context, '생활비', _livingExpenseAllocation),

            Gaps.v20,

            // Input Details (Expandable)
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
                                fontSize: Sizes.size16,
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

            // Apply to Budget Button
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: Colors.black,
            //       foregroundColor: Colors.white,
            //       minimumSize: const Size.fromHeight(56),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //     onPressed: _showApplyModal,
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: const [
            //         Icon(Icons.arrow_forward, size: 20),
            //         SizedBox(width: 8),
            //         Text(
            //           '예산에 적용하기',
            //           style: TextStyle(
            //             fontFamily: 'Gmarket_sans',
            //             fontSize: 18,
            //             fontWeight: FontWeight.w700,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // Gaps.v16,

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
                        fontSize: Sizes.size16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
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
                        fontSize: Sizes.size16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Gaps.v12,
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
        border: Border.all(color: Colors.grey.shade300),
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
                fontSize: Sizes.size16,
              ),
            ),
          ),
          Text(
            _formatCurrency(amount),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
              fontSize: Sizes.size16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    // 숫자 포맷팅 헬퍼 함수
    String formatNumber(String? text) {
      if (text == null || text.isEmpty) return 'N/A';
      // 이미 콤마가 있으면 그대로 반환
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
      // 이미 %가 있으면 그대로 반환
      if (text.contains('%')) return text;
      return '$text%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // 이 줄 추가
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
                      fontSize: Sizes.size16,
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
                        fontSize: Sizes.size16,
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
