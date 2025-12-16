import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import '../widgets/form_widgets.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'demo_salary_step2_screen.dart';
import '../widgets/bottom_action_button.dart';
import '../widgets/number_input_field.dart';
import '../widgets/month_selector.dart';
import '../../../../shared/widgets/loading/section_header.dart';

class DemoSalaryStep1Screen extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onNavigateToStep2;
  final ValueNotifier<DateTime>? currentMonthNotifier;
  final Map<String, dynamic>? initialControllers;

  const DemoSalaryStep1Screen({
    super.key,
    this.onNavigateToStep2,
    this.currentMonthNotifier,
    this.initialControllers,
  });

  @override
  State<DemoSalaryStep1Screen> createState() => _DemoSalaryStep1ScreenState();
}

class _DemoSalaryStep1ScreenState extends State<DemoSalaryStep1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _currentAgeController = TextEditingController();
  final TextEditingController _retireAgeController = TextEditingController();
  final TextEditingController _livingExpenseController =
      TextEditingController();
  final TextEditingController _snpValueController = TextEditingController();
  final TextEditingController _expectedReturnController =
      TextEditingController();
  final TextEditingController _inflationController = TextEditingController();
  final TextEditingController _shortTermGoalController =
      TextEditingController();
  final TextEditingController _shortTermGoalAmountController =
      TextEditingController();
  final TextEditingController _shortTermGoalDurationController =
      TextEditingController();
  final TextEditingController _shortTermSavedController =
      TextEditingController();

  final FocusNode _currentAgeFocus = FocusNode();
  final FocusNode _retireAgeFocus = FocusNode();
  final FocusNode _livingExpenseFocus = FocusNode();
  final FocusNode _snpValueFocus = FocusNode();
  final FocusNode _expectedReturnFocus = FocusNode();
  final FocusNode _inflationFocus = FocusNode();
  final FocusNode _shortTermGoalAmountFocus = FocusNode();
  final FocusNode _shortTermGoalDurationFocus = FocusNode();
  final FocusNode _shortTermSavedFocus = FocusNode();
  final FocusNode _shortTermDropdownFocus = FocusNode();
  late final FocusNode _nextButtonFocus;

  bool _hasShortTermGoal = true;
  String? _selectedShortTermGoal;
  final List<String> _shortTermOptions = ['결혼', '자동차', '여행', '기타'];

  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;
  late final ValueNotifier<DateTime> _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth =
        widget.currentMonthNotifier ?? ValueNotifier<DateTime>(DateTime.now());

    _allControllers = [
      _currentAgeController,
      _retireAgeController,
      _livingExpenseController,
      _snpValueController,
      _expectedReturnController,
      _inflationController,
      _shortTermGoalController,
      _shortTermGoalAmountController,
      _shortTermGoalDurationController,
      _shortTermSavedController,
    ];

    _allFocusNodes = [
      _currentAgeFocus,
      _retireAgeFocus,
      _livingExpenseFocus,
      _snpValueFocus,
      _expectedReturnFocus,
      _inflationFocus,
      _shortTermGoalAmountFocus,
      _shortTermGoalDurationFocus,
      _shortTermSavedFocus,
      _shortTermDropdownFocus,
      (_nextButtonFocus = FocusNode()..canRequestFocus = false),
    ];

    if (widget.initialControllers != null &&
        widget.initialControllers!.isNotEmpty) {
      _loadInitialData(widget.initialControllers!);
    }
    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  void _loadInitialData(Map<String, dynamic> controllers) {
    String formatNumber(String text) {
      if (text.isEmpty) return '';
      if (text.contains(',')) return text;
      final number = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (number == null) return text;
      final intValue = number.toInt();
      return intValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }

    if (controllers['currentAgeController'] is TextEditingController) {
      _currentAgeController.text =
          (controllers['currentAgeController'] as TextEditingController).text;
    }
    if (controllers['retireAgeController'] is TextEditingController) {
      _retireAgeController.text =
          (controllers['retireAgeController'] as TextEditingController).text;
    }
    if (controllers['livingExpenseController'] is TextEditingController) {
      _livingExpenseController.text = formatNumber(
        (controllers['livingExpenseController'] as TextEditingController).text,
      );
    }
    if (controllers['snpValueController'] is TextEditingController) {
      _snpValueController.text = formatNumber(
        (controllers['snpValueController'] as TextEditingController).text,
      );
    }
    if (controllers['expectedReturnController'] is TextEditingController) {
      _expectedReturnController.text =
          (controllers['expectedReturnController'] as TextEditingController)
              .text;
    }
    if (controllers['inflationController'] is TextEditingController) {
      _inflationController.text =
          (controllers['inflationController'] as TextEditingController).text;
    }

    _hasShortTermGoal = controllers['hasShortTermGoal'] ?? true;
    _selectedShortTermGoal = controllers['selectedShortTermGoal'];

    if (controllers['shortTermAmountController'] is TextEditingController) {
      _shortTermGoalAmountController.text = formatNumber(
        (controllers['shortTermAmountController'] as TextEditingController)
            .text,
      );
    }
    if (controllers['shortTermDurationController'] is TextEditingController) {
      _shortTermGoalDurationController.text =
          (controllers['shortTermDurationController'] as TextEditingController)
              .text;
    }
    if (controllers['shortTermSavedController'] is TextEditingController) {
      _shortTermSavedController.text = formatNumber(
        (controllers['shortTermSavedController'] as TextEditingController).text,
      );
    }
  }

  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);
      if (widget.onNavigateToStep2 == null) {
        c.dispose();
      }
    }
    for (final f in _allFocusNodes) {
      f.dispose();
    }
    if (widget.currentMonthNotifier == null) {
      _currentMonth.dispose();
    }
    super.dispose();
  }

  bool _controllersFilled(List<TextEditingController> ctrls) =>
      ctrls.every((c) => c.text.trim().isNotEmpty);

  bool get _allFieldsFilled {
    final basic = [
      _currentAgeController,
      _retireAgeController,
      _livingExpenseController,
      _snpValueController,
      _expectedReturnController,
      _inflationController,
    ];
    if (!_controllersFilled(basic)) return false;
    if (_hasShortTermGoal) {
      if (_selectedShortTermGoal == null ||
          _selectedShortTermGoal!.trim().isEmpty)
        return false;
      final short = [
        _shortTermGoalAmountController,
        _shortTermGoalDurationController,
        _shortTermSavedController,
      ];
      if (!_controllersFilled(short)) return false;
    }
    return true;
  }

  void _navigateToStep2() {
    final controllers = {
      'currentAgeController': _currentAgeController,
      'retireAgeController': _retireAgeController,
      'livingExpenseController': _livingExpenseController,
      'snpValueController': _snpValueController,
      'expectedReturnController': _expectedReturnController,
      'inflationController': _inflationController,
      'hasShortTermGoal': _hasShortTermGoal,
      'selectedShortTermGoal': _selectedShortTermGoal,
      'shortTermAmountController': _shortTermGoalAmountController,
      'shortTermDurationController': _shortTermGoalDurationController,
      'shortTermSavedController': _shortTermSavedController,
    };

    if (widget.onNavigateToStep2 != null) {
      widget.onNavigateToStep2!(controllers);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DemoSalaryStep2Screen(
            currentAgeController: _currentAgeController,
            retireAgeController: _retireAgeController,
            livingExpenseController: _livingExpenseController,
            snpValueController: _snpValueController,
            expectedReturnController: _expectedReturnController,
            inflationController: _inflationController,
            hasShortTermGoal: _hasShortTermGoal,
            selectedShortTermGoal: _selectedShortTermGoal,
            shortTermAmountController: _shortTermGoalAmountController,
            shortTermDurationController: _shortTermGoalDurationController,
            shortTermSavedController: _shortTermSavedController,
            currentMonthNotifier: _currentMonth,
          ),
        ),
      );
    }
  }

  double? _parseDouble(String? s) {
    if (s == null) return null;
    final normalized = s.replaceAll(',', '').replaceAll('%', '').trim();
    return double.tryParse(normalized);
  }

  Future<void> _onNext() async {
    final orderedFocuses = <FocusNode?>[
      _currentAgeFocus,
      _retireAgeFocus,
      _livingExpenseFocus,
      _snpValueFocus,
      _expectedReturnFocus,
      _inflationFocus,
      _shortTermDropdownFocus,
      _shortTermGoalAmountFocus,
      _shortTermGoalDurationFocus,
      _shortTermSavedFocus,
    ];

    final FocusNode? currentFocus =
        FocusScope.of(context).focusedChild ??
        FocusManager.instance.primaryFocus;

    if (currentFocus != null) {
      final idx = orderedFocuses.indexWhere((f) => f == currentFocus);
      if (idx != -1) {
        for (int i = idx + 1; i < orderedFocuses.length; i++) {
          final next = orderedFocuses[i];
          if (next == null) continue;
          if (!_hasShortTermGoal &&
              (next == _shortTermDropdownFocus ||
                  next == _shortTermGoalAmountFocus ||
                  next == _shortTermGoalDurationFocus ||
                  next == _shortTermSavedFocus)) {
            continue;
          }
          Future.microtask(() {
            if (!mounted) return;
            FocusScope.of(context).requestFocus(next);
          });
          return;
        }
      }
    }

    final entries = <MapEntry<TextEditingController, FocusNode>>[
      MapEntry(_currentAgeController, _currentAgeFocus),
      MapEntry(_retireAgeController, _retireAgeFocus),
      MapEntry(_livingExpenseController, _livingExpenseFocus),
      MapEntry(_snpValueController, _snpValueFocus),
      MapEntry(_expectedReturnController, _expectedReturnFocus),
      MapEntry(_inflationController, _inflationFocus),
    ];

    if (_hasShortTermGoal) {
      if (_selectedShortTermGoal == null ||
          _selectedShortTermGoal!.trim().isEmpty) {
        Future.microtask(() {
          if (!mounted) return;
          FocusScope.of(context).requestFocus(_shortTermDropdownFocus);
        });
        return;
      }
      entries.addAll([
        MapEntry(_shortTermGoalAmountController, _shortTermGoalAmountFocus),
        MapEntry(_shortTermGoalDurationController, _shortTermGoalDurationFocus),
        MapEntry(_shortTermSavedController, _shortTermSavedFocus),
      ]);
    }

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

  void _changeMonth(DateTime newMonth) {
    _currentMonth.value = newMonth;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final keyboardConfig = KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _currentAgeFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _retireAgeFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _livingExpenseFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _snpValueFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _expectedReturnFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _inflationFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _shortTermGoalAmountFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _shortTermGoalDurationFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
        KeyboardActionsItem(
          focusNode: _shortTermSavedFocus,
          displayArrows: false,
          toolbarButtons: [],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('월급 최적화'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(
                left: Sizes.size20,
                right: Sizes.size20,
                top: Sizes.size12,
                bottom: Sizes.size24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      SectionHeader(
                        icon: Icons.flag_outlined,
                        title: '경제적자유 목표 설정',
                      ),
                    ],
                  ),
                  Gaps.v12,
                  NumberInputField(
                    label: '현재 나이',
                    hint: '예: 30',
                    controller: _currentAgeController,
                    focusNode: _currentAgeFocus,
                    nextFocus: _retireAgeFocus,
                    suffixText: '세',
                  ),
                  Gaps.v16,
                  NumberInputField(
                    label: '은퇴 희망 나이',
                    hint: '예: 65',
                    controller: _retireAgeController,
                    focusNode: _retireAgeFocus,
                    nextFocus: _livingExpenseFocus,
                    suffixText: '세',
                  ),
                  Gaps.v16,
                  NumberInputField(
                    label: '현재 희망 생활비',
                    hint: '예: 2,000,000',
                    controller: _livingExpenseController,
                    focusNode: _livingExpenseFocus,
                    nextFocus: _snpValueFocus,
                    suffixText: '₩',
                  ),
                  Gaps.v16,
                  NumberInputField(
                    label: '현재 S&P500 평가금액',
                    hint: '예: 3,000,000',
                    controller: _snpValueController,
                    focusNode: _snpValueFocus,
                    nextFocus: _expectedReturnFocus,
                    suffixText: '₩',
                  ),
                  Gaps.v16,
                  NumberInputField(
                    label: '기대수익률',
                    hint: '예: 8.2',
                    controller: _expectedReturnController,
                    focusNode: _expectedReturnFocus,
                    nextFocus: _inflationFocus,
                    allowDecimal: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    suffixText: '%',
                  ),
                  Gaps.v16,
                  NumberInputField(
                    label: '예상 물가 상승률',
                    hint: '예: 2.5',
                    controller: _inflationController,
                    focusNode: _inflationFocus,
                    nextFocus: _hasShortTermGoal
                        ? _shortTermDropdownFocus
                        : null,
                    allowDecimal: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    suffixText: '%',
                  ),
                  Gaps.v32,
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        title: Text(
                          '단기 목표가 있나요?',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontFamily: "Gmarket_sans",
                                fontWeight: FontWeight.w700,
                                fontSize: Sizes.size16 + Sizes.size2,
                              ),
                        ),
                        value: _hasShortTermGoal,
                        activeThumbColor: const Color(0xFFE9435A),
                        activeTrackColor: Colors.transparent,
                        trackOutlineColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.grey.shade400;
                          }
                          return Colors.grey.shade400;
                        }),
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.transparent,
                        onChanged: (val) {
                          Future.microtask(() {
                            if (!mounted) return;
                            setState(() => _hasShortTermGoal = val);
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.black,
                      ),
                    ),
                  ),
                  if (_hasShortTermGoal) ...[
                    Gaps.v16,
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '단기 목표',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontFamily: "Gmarket_sans",
                                  fontWeight: FontWeight.w400,
                                  fontSize: Sizes.size16 + Sizes.size2,
                                ),
                          ),
                          Gaps.v10,
                          DropdownButtonFormField<String>(
                            focusNode: _shortTermDropdownFocus,
                            dropdownColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Sizes.size8,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  Sizes.size8,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              border: OutlineInputBorder(
                                gapPadding: 5,
                                borderRadius: BorderRadius.circular(
                                  Sizes.size8,
                                ),
                              ),
                            ),
                            hint: const Text('단기 목표 선택'),
                            initialValue: _selectedShortTermGoal,
                            items: _shortTermOptions
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Container(child: Text(e)),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => Future.microtask(() {
                              if (!mounted) return;
                              setState(() => _selectedShortTermGoal = val);
                            }),
                            validator: (v) => (v == null || v.isEmpty)
                                ? '단기 목표를 선택하세요'
                                : null,
                          ),
                          Gaps.v16,
                          NumberInputField(
                            label: '단기 목표 금액',
                            hint: '예: 1,000,000',
                            controller: _shortTermGoalAmountController,
                            focusNode: _shortTermGoalAmountFocus,
                            nextFocus: _shortTermGoalDurationFocus,
                            suffixText: '₩',
                          ),
                          Gaps.v16,
                          NumberInputField(
                            label: '단기 목표 기간 (월)',
                            hint: '예: 12',
                            controller: _shortTermGoalDurationController,
                            focusNode: _shortTermGoalDurationFocus,
                            nextFocus: _shortTermSavedFocus,
                            suffixText: '개월',
                            keyboardType: TextInputType.number,
                          ),
                          Gaps.v16,
                          NumberInputField(
                            label: '현재 단기 목표 저축액',
                            hint: '예: 500,000',
                            controller: _shortTermSavedController,
                            focusNode: _shortTermSavedFocus,
                            nextFocus: null,
                            suffixText: '₩',
                            keyboardType: TextInputType.number,
                            action: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionButton(
        allFieldsFilled: _allFieldsFilled,
        onNext: _onNext,
        onNavigate: _navigateToStep2,
        buttonFocus: _nextButtonFocus,
      ),
    );
  }
}
