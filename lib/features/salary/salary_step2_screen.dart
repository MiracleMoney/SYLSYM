import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'package:miraclemoney/features/salary/widgets/bottom_action_button.dart';
import 'widgets/form_widgets.dart';
import 'widgets/number_input_field.dart';
import 'dart:math';
import 'salary_result_screen.dart';
import 'widgets/month_selector.dart';
import '../../widgets/common/section_header.dart';

class SalaryStep2Screen extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onNavigateToResult; // ✅ 타입 변경

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
  final ValueNotifier<DateTime>? currentMonthNotifier; // 추가

  const SalaryStep2Screen({
    super.key,
    this.onNavigateToResult,
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
    this.currentMonthNotifier, // 추가
  });

  @override
  State<SalaryStep2Screen> createState() => _SalaryStep2ScreenState();
}

class _SalaryStep2ScreenState extends State<SalaryStep2Screen> {
  // controllers
  final TextEditingController _baseSalaryController = TextEditingController();
  final TextEditingController _overtimeController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _incentiveController = TextEditingController();
  final TextEditingController _side1Controller = TextEditingController();
  final TextEditingController _side2Controller = TextEditingController();
  final TextEditingController _side3Controller = TextEditingController();
  final TextEditingController _retirementController = TextEditingController();

  // Step1에서 전달된 컨트롤러들을 내부 참조로 보관
  late final TextEditingController? _s1CurrentAge;
  late final TextEditingController? _s1RetireAge;
  late final TextEditingController? _s1LivingExpense;
  late final TextEditingController? _s1SnpValue;
  late final TextEditingController? _s1ExpectedReturn;
  late final TextEditingController? _s1Inflation;
  late final bool _s1HasShortTermGoal;
  late final String? _s1SelectedShortTerm;
  late final TextEditingController? _s1ShortAmount;
  late final TextEditingController? _s1ShortDuration;
  late final TextEditingController? _s1ShortSaved;

  // focus nodes
  final FocusNode _baseSalaryFocus = FocusNode();
  final FocusNode _overtimeFocus = FocusNode();
  final FocusNode _bonusFocus = FocusNode();
  final FocusNode _incentiveFocus = FocusNode();
  final FocusNode _side1Focus = FocusNode();
  final FocusNode _side2Focus = FocusNode();
  final FocusNode _side3Focus = FocusNode();
  final FocusNode _retirementFocus = FocusNode();
  late final FocusNode _actionButtonFocus; // 이것만 남기고

  // month

  // month (Step1에서 전달된 ValueNotifier 또는 로컬 생성)
  late final ValueNotifier<DateTime> _currentMonth;
  // calculated display
  String _calculatedMonthlyExpense = '\$0';
  String _calculatedFreedomTarget = '\$0';

  late final List<TextEditingController> _allStep2Controllers;

  @override
  void initState() {
    super.initState();
    _actionButtonFocus = FocusNode()..canRequestFocus = false;
    // Step1에서 전달된 ValueNotifier를 사용하거나, 없으면 새로 생성
    _currentMonth =
        widget.currentMonthNotifier ?? ValueNotifier<DateTime>(DateTime.now());

    // ValueNotifier 변경시 Step2 화면도 갱신되도록 리스너 등록
    _currentMonth.addListener(_onMonthChanged);

    // 전달된 Step1 컨트롤러들을 할당
    _s1CurrentAge = widget.currentAgeController;
    _s1RetireAge = widget.retireAgeController;
    _s1LivingExpense = widget.livingExpenseController;
    _s1SnpValue = widget.snpValueController;
    _s1ExpectedReturn = widget.expectedReturnController;
    _s1Inflation = widget.inflationController;
    _s1HasShortTermGoal = widget.hasShortTermGoal ?? false;
    _s1SelectedShortTerm = widget.selectedShortTermGoal;
    _s1ShortAmount = widget.shortTermAmountController;
    _s1ShortDuration = widget.shortTermDurationController;
    _s1ShortSaved = widget.shortTermSavedController;

    void attachIfNotNull(TextEditingController? c) {
      if (c != null) c.addListener(_recomputeFromStep1);
    }

    attachIfNotNull(_s1CurrentAge);
    attachIfNotNull(_s1RetireAge);
    attachIfNotNull(_s1LivingExpense);
    attachIfNotNull(_s1SnpValue);
    attachIfNotNull(_s1ExpectedReturn);
    attachIfNotNull(_s1Inflation);
    attachIfNotNull(_s1ShortAmount);
    attachIfNotNull(_s1ShortDuration);
    attachIfNotNull(_s1ShortSaved);

    // Step2 필드 리스너 추가
    _allStep2Controllers = [
      _baseSalaryController,
      _overtimeController,
      _bonusController,
      _incentiveController,
      _side1Controller,
      _side2Controller,
      _side3Controller,
      _retirementController,
    ];

    for (final c in _allStep2Controllers) {
      c.addListener(_onFieldChanged);
    }

    // 초기 계산 (한 번)
    _recomputeFromStep1();
  }

  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  // 월 변경 리스너 (Step2 화면 갱신)
  void _onMonthChanged() {
    if (!mounted) return;
    setState(() {}); // 화면 rebuild
  }

  @override
  void dispose() {
    _baseSalaryController.dispose();
    _overtimeController.dispose();
    _bonusController.dispose();
    _incentiveController.dispose();
    _side1Controller.dispose();
    _side2Controller.dispose();
    _side3Controller.dispose();
    _retirementController.dispose();

    _baseSalaryFocus.dispose();
    _overtimeFocus.dispose();
    _bonusFocus.dispose();
    _incentiveFocus.dispose();
    _side1Focus.dispose();
    _side2Focus.dispose();
    _side3Focus.dispose();
    _retirementFocus.dispose();
    _actionButtonFocus.dispose(); // 변수명 변경

    // remove listeners from passed controllers (do not dispose them; they belong to Step1)
    void detachIfNotNull(TextEditingController? c) {
      if (c != null) c.removeListener(_recomputeFromStep1);
    }

    detachIfNotNull(_s1CurrentAge);
    detachIfNotNull(_s1RetireAge);
    detachIfNotNull(_s1LivingExpense);
    detachIfNotNull(_s1SnpValue);
    detachIfNotNull(_s1ExpectedReturn);
    detachIfNotNull(_s1Inflation);
    detachIfNotNull(_s1ShortAmount);
    detachIfNotNull(_s1ShortDuration);
    detachIfNotNull(_s1ShortSaved);

    for (final c in _allStep2Controllers) {
      c.removeListener(_onFieldChanged);
    }

    // ValueNotifier 리스너 제거 (Step1에서 전달받은 경우 dispose 안함)
    _currentMonth.removeListener(_onMonthChanged);
    if (widget.currentMonthNotifier == null) {
      // Step1에서 전달받지 않았고 로컬에서 생성한 경우만 dispose
      _currentMonth.dispose();
    }

    super.dispose();
  }

  bool _controllersFilled(List<TextEditingController> ctrls) {
    return ctrls.every((c) => c.text.trim().isNotEmpty);
  }

  bool get _allFieldsFilled {
    return _controllersFilled(_allStep2Controllers);
  }

  // Recompute display values from Step1 controllers (실시간 업데이트)
  void _recomputeFromStep1() {
    // 안전하게 mounted 체크 후 setState
    if (!mounted) return;

    // parse helper for step1 controllers
    double parseS1(TextEditingController? c) {
      if (c == null) return 0.0;
      final t = c.text.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(t) ?? 0.0;
    }

    // living: 현재 희망 생활비 (Step1 입력)
    final living = parseS1(_s1LivingExpense);

    // years: 은퇴 시점까지 남은 연수 (음수면 0으로 처리)
    final yearsRaw = parseS1(_s1RetireAge) - parseS1(_s1CurrentAge);
    final years = yearsRaw > 0 ? yearsRaw : 0.0;

    // inflation: 퍼센트(예: 2.5 입력 -> 0.025)
    final inflationPercent = parseS1(_s1Inflation) / 100.0;

    // 방어 코드: living이 0이면 0, inflationPercent가 NaN이면 0 처리
    double monthlyExpense;
    if (living <= 0) {
      monthlyExpense = 0.0;
    } else {
      final inflation = 1 + inflationPercent;
      // base가 음수이면 pow는 예측 불가능하니 방어
      if (inflation <= 0) {
        monthlyExpense = living;
      } else {
        monthlyExpense = (pow(inflation, years) * living).toDouble();
      }
    }

    final freedomTarget = monthlyExpense * 12 * 25;

    setState(() {
      _calculatedMonthlyExpense = _formatCurrency(monthlyExpense);
      _calculatedFreedomTarget = _formatCurrency(freedomTarget);
    });
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

  Future<void> _onNext() async {
    // 입력 필드 순서
    final orderedFocuses = <FocusNode>[
      _baseSalaryFocus,
      _overtimeFocus,
      _bonusFocus,
      _incentiveFocus,
      _side1Focus,
      _side2Focus,
      _side3Focus,
      _retirementFocus,
    ];

    // 현재 포커스된 노드
    final FocusNode? currentFocus =
        FocusScope.of(context).focusedChild ??
        FocusManager.instance.primaryFocus;

    // 현재 포커스가 목록에 있으면 다음 유효한 필드로 이동
    if (currentFocus != null) {
      final idx = orderedFocuses.indexWhere((f) => f == currentFocus);
      if (idx != -1 && idx < orderedFocuses.length - 1) {
        Future.microtask(() {
          if (!mounted) return;
          FocusScope.of(context).requestFocus(orderedFocuses[idx + 1]);
        });
        return;
      }
    }

    // 위에서부터 첫 번째 빈 칸으로 포커스 이동
    final entries = <MapEntry<TextEditingController, FocusNode>>[
      MapEntry(_baseSalaryController, _baseSalaryFocus),
      MapEntry(_overtimeController, _overtimeFocus),
      MapEntry(_bonusController, _bonusFocus),
      MapEntry(_incentiveController, _incentiveFocus),
      MapEntry(_side1Controller, _side1Focus),
      MapEntry(_side2Controller, _side2Focus),
      MapEntry(_side3Controller, _side3Focus),
      MapEntry(_retirementController, _retirementFocus),
    ];

    for (final e in entries) {
      if (e.key.text.trim().isEmpty) {
        Future.microtask(() {
          if (!mounted) return;
          FocusScope.of(context).requestFocus(e.value);
        });
        return;
      }
    }
  }

  // Calculate 버튼 동작: 데모용 간단 계산
  void _onCalculate() async {
    if (widget.onNavigateToResult != null) {
      // TabBar 모드: Step2 컨트롤러들을 Map으로 전달
      final step2Controllers = {
        'baseSalaryController': _baseSalaryController,
        'overtimeController': _overtimeController,
        'bonusController': _bonusController,
        'incentiveController': _incentiveController,
        'side1Controller': _side1Controller,
        'side2Controller': _side2Controller,
        'side3Controller': _side3Controller,
        'retirementController': _retirementController,
      };
      widget.onNavigateToResult!(step2Controllers);
    } else {
      // 독립 실행 모드: Navigator 사용
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalaryResultScreen(
            currentAgeController: widget.currentAgeController,
            retireAgeController: widget.retireAgeController,
            livingExpenseController: widget.livingExpenseController,
            snpValueController: widget.snpValueController,
            expectedReturnController: widget.expectedReturnController,
            inflationController: widget.inflationController,
            hasShortTermGoal: widget.hasShortTermGoal,
            selectedShortTermGoal: widget.selectedShortTermGoal,
            shortTermAmountController: widget.shortTermAmountController,
            shortTermDurationController: widget.shortTermDurationController,
            shortTermSavedController: widget.shortTermSavedController,
            baseSalaryController: _baseSalaryController,
            overtimeController: _overtimeController,
            bonusController: _bonusController,
            incentiveController: _incentiveController,
            side1Controller: _side1Controller,
            side2Controller: _side2Controller,
            side3Controller: _side3Controller,
            retirementController: _retirementController,
            currentMonthNotifier: widget.currentMonthNotifier,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(12.0);

    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
          left: Sizes.size20,
          right: Sizes.size20,
          top: Sizes.size12,
          bottom: Sizes.size24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Row(
              children: [
                SectionHeader(icon: Icons.payments_outlined, title: '본업 수입'),
              ],
            ),
            Gaps.v12,

            NumberInputField(
              label: '월급',
              hint: '예: 1,800,000',
              controller: _baseSalaryController,
              focusNode: _baseSalaryFocus,
              nextFocus: _overtimeFocus,
              suffixText: '₩',
            ),
            Gaps.v16,
            NumberInputField(
              label: '추가 근무',
              hint: '예: 300,000',
              controller: _overtimeController,
              focusNode: _overtimeFocus,
              nextFocus: _bonusFocus,
              suffixText: '₩',
            ),
            Gaps.v16,
            NumberInputField(
              label: '상여금',
              hint: '예: 500,000',
              controller: _bonusController,
              focusNode: _bonusFocus,
              nextFocus: _incentiveFocus,
              suffixText: '₩',
            ),
            Gaps.v16,
            NumberInputField(
              label: '성과급',
              hint: '예: 500,000',
              controller: _incentiveController,
              focusNode: _incentiveFocus,
              nextFocus: _side1Focus,
              suffixText: '₩',
            ),

            Gaps.v32,
            Row(
              children: [SectionHeader(icon: Icons.money, title: '추가 수입')],
            ),
            Gaps.v12,
            NumberInputField(
              label: '추가 수입 1',
              hint: '예: 300,000',
              controller: _side1Controller,
              focusNode: _side1Focus,
              nextFocus: _side2Focus,
              suffixText: '₩',
            ),
            Gaps.v16,
            NumberInputField(
              label: '추가 수입 2',
              hint: '예: 200,000',
              controller: _side2Controller,
              focusNode: _side2Focus,
              nextFocus: _side3Focus,
              suffixText: '₩',
            ),
            Gaps.v16,
            NumberInputField(
              label: '추가 수입 3',
              hint: '예: 100,000',
              controller: _side3Controller,
              focusNode: _side3Focus,
              nextFocus: _retirementFocus,
              suffixText: '₩',
            ),

            Gaps.v32,
            // retirement card
            Row(
              children: [
                SectionHeader(
                  icon: Icons.monetization_on_outlined,
                  title: '퇴직금 투자 금액',
                  fontSize: Sizes.size16 + Sizes.size4,
                ),
              ],
            ),
            Gaps.v4,
            Text(
              '(연 퇴직금을 12개월로 나눈 금액을 입력해주세요)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'Gmarket_sans',
                color: Colors.grey.shade600,
                fontSize: Sizes.size16,
              ),
            ),
            Gaps.v12,
            NumberInputField(
              label: '퇴직금',
              hint: '예: 220,000',
              controller: _retirementController,
              focusNode: _retirementFocus,
              nextFocus: null,
              suffixText: '₩',
              action: TextInputAction.done,
            ),
          ],
        ),
      ),

      // BottomActionButton을 사용하여 동적 버튼 구현
      bottomNavigationBar: BottomActionButton(
        allFieldsFilled: _allFieldsFilled,
        onNext: _onNext,
        onNavigate: _onCalculate,
        buttonFocus: _actionButtonFocus,
      ),
    );
  }
}
