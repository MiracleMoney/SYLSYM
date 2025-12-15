import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/features/salary/presentation/widgets/bottom_action_button.dart';
import '../widgets/form_widgets.dart';
import '../widgets/number_input_field.dart';
import 'dart:math';
import 'demo_salary_result_screen.dart';
import '../widgets/month_selector.dart';
import '../../../../shared/widgets/loading/section_header.dart';

class DemoSalaryStep2Screen extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onNavigateToResult;

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
  final ValueNotifier<DateTime>? currentMonthNotifier;

  const DemoSalaryStep2Screen({
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
    this.currentMonthNotifier,
  });

  @override
  State<DemoSalaryStep2Screen> createState() => _DemoSalaryStep2ScreenState();
}

class _DemoSalaryStep2ScreenState extends State<DemoSalaryStep2Screen> {
  final TextEditingController _baseSalaryController = TextEditingController();
  final TextEditingController _overtimeController = TextEditingController();
  final TextEditingController _bonusController = TextEditingController();
  final TextEditingController _incentiveController = TextEditingController();
  final TextEditingController _side1Controller = TextEditingController();
  final TextEditingController _side2Controller = TextEditingController();
  final TextEditingController _side3Controller = TextEditingController();
  final TextEditingController _retirementController = TextEditingController();

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

  final FocusNode _baseSalaryFocus = FocusNode();
  final FocusNode _overtimeFocus = FocusNode();
  final FocusNode _bonusFocus = FocusNode();
  final FocusNode _incentiveFocus = FocusNode();
  final FocusNode _side1Focus = FocusNode();
  final FocusNode _side2Focus = FocusNode();
  final FocusNode _side3Focus = FocusNode();
  final FocusNode _retirementFocus = FocusNode();
  late final FocusNode _actionButtonFocus;

  late final ValueNotifier<DateTime> _currentMonth;
  String _calculatedMonthlyExpense = '\$0';
  String _calculatedFreedomTarget = '\$0';

  late final List<TextEditingController> _allStep2Controllers;
  final ValueNotifier<bool> _allFieldsFilledNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _actionButtonFocus = FocusNode()..canRequestFocus = false;
    _currentMonth =
        widget.currentMonthNotifier ?? ValueNotifier<DateTime>(DateTime.now());
    _currentMonth.addListener(_onMonthChanged);

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
    _allFieldsFilledNotifier.value = _allFieldsFilled;
    _recomputeFromStep1();
  }

  void _onFieldChanged() {
    if (!mounted) return;
    _allFieldsFilledNotifier.value = _allFieldsFilled;
  }

  void _onMonthChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _allFieldsFilledNotifier.dispose();

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
    _actionButtonFocus.dispose();

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

    _currentMonth.removeListener(_onMonthChanged);
    if (widget.currentMonthNotifier == null) {
      _currentMonth.dispose();
    }
    super.dispose();
  }

  bool _controllersFilled(List<TextEditingController> ctrls) =>
      ctrls.every((c) => c.text.trim().isNotEmpty);

  bool get _allFieldsFilled => _controllersFilled(_allStep2Controllers);

  void _recomputeFromStep1() {
    if (!mounted) return;

    double parseS1(TextEditingController? c) {
      if (c == null) return 0.0;
      final t = c.text.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(t) ?? 0.0;
    }

    final living = parseS1(_s1LivingExpense);
    final yearsRaw = parseS1(_s1RetireAge) - parseS1(_s1CurrentAge);
    final years = yearsRaw > 0 ? yearsRaw : 0.0;
    final inflationPercent = parseS1(_s1Inflation) / 100.0;

    double monthlyExpense;
    if (living <= 0) {
      monthlyExpense = 0.0;
    } else {
      final inflation = 1 + inflationPercent;
      monthlyExpense = inflation <= 0
          ? living
          : (pow(inflation, years) * living).toDouble();
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

    final FocusNode? currentFocus =
        FocusScope.of(context).focusedChild ??
        FocusManager.instance.primaryFocus;

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

  void _onCalculate() {
    if (widget.onNavigateToResult != null) {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DemoSalaryResultScreen(
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
      body: SafeArea(
        child: SingleChildScrollView(
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
              Gaps.v12,
              const Row(
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
                children: const [
                  SectionHeader(icon: Icons.money, title: '추가 수입'),
                ],
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
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _allFieldsFilledNotifier,
        builder: (context, allFilled, child) {
          return BottomActionButton(
            allFieldsFilled: allFilled,
            onNext: _onNext,
            onNavigate: _onCalculate,
            buttonFocus: _actionButtonFocus,
          );
        },
      ),
    );
  }
}
