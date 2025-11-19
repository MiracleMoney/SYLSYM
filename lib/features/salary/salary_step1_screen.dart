// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'widgets/form_widgets.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'salary_step2_screen.dart'; // same-folde
import 'widgets/bottom_action_button.dart';
import 'widgets/number_input_field.dart';

class SalaryStep1Screen extends StatefulWidget {
  const SalaryStep1Screen({super.key});

  @override
  State<SalaryStep1Screen> createState() => _SalaryStep1ScreenState();
}

class _SalaryStep1ScreenState extends State<SalaryStep1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // controllers
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

  // focus nodes (각 입력 필드 포커스 제어)
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
  // Next 버튼이 포커스를 가지지 않도록 할 FocusNode
  late final FocusNode _nextButtonFocus;

  bool _hasShortTermGoal = true;
  String? _selectedShortTermGoal;
  final List<String> _shortTermOptions = ['결혼', '자동차', '여행', '기타'];

  // helper lists for iteration
  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;
  // 현재 화면에서 선택된 연월 (실시간 공유를 위해 ValueNotifier 사용)
  late final ValueNotifier<DateTime> _currentMonth;

  @override
  void initState() {
    super.initState();
    // 현재 월을 기본값으로 설정 (데이터 저장/로딩은 나중에 구현)
    _currentMonth = ValueNotifier<DateTime>(DateTime.now());
    // ... 기존 코드 (controller 리스너 등) ...
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

      // 버튼 포커스 노드는 포커스 불가로 설정
      (_nextButtonFocus = FocusNode()..canRequestFocus = false),
    ];

    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    // 간단히 rebuild 하여 bottomNavigationBar 버튼을 교체
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadSavedData() async {
    // TODO: DB에서 불러와 controller.text에 세팅
    // ex) final saved = await MyDbService.loadUserInputs();
    // _currentAgeController.text = saved.currentAge?.toString() ?? '';
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);

      c.dispose();
    }
    for (final f in _allFocusNodes) {
      f.dispose();
    }
    _currentMonth.dispose(); // ValueNotifier dispose

    super.dispose();
  }

  bool _controllersFilled(List<TextEditingController> ctrls) {
    return ctrls.every((c) => c.text.trim().isNotEmpty);
  }

  bool get _allFieldsFilled {
    // 기본 필수 필드
    final basic = [
      _currentAgeController,
      _retireAgeController,
      _livingExpenseController,
      _snpValueController,
      _expectedReturnController,
      _inflationController,
    ];
    if (!_controllersFilled(basic)) return false;

    // 단기 목표가 켜져있다면 드롭다운과 단기 필드도 체크
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SalaryStep2Screen(
          // Step1의 컨트롤러들을 전달합니다.
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
          currentMonthNotifier: _currentMonth, // 추가: 월 동기화용
        ),
      ),
    );
  }

  double? _parseDouble(String? s) {
    if (s == null) return null;
    final normalized = s.replaceAll(',', '').replaceAll('%', '').trim();
    return double.tryParse(normalized);
  }

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '값을 입력하세요';
    if (_parseDouble(v) == null) return '유효한 숫자를 입력하세요';
    return null;
  }

  Future<void> _onNext() async {
    // 입력 필드 순서 (UI 상의 순서와 일치하도록)
    final orderedFocuses = <FocusNode?>[
      _currentAgeFocus,
      _retireAgeFocus,
      _livingExpenseFocus,
      _snpValueFocus,
      _expectedReturnFocus,
      _inflationFocus,
      // 드롭다운(단기 목표)도 순서에 포함
      _shortTermDropdownFocus,
      _shortTermGoalAmountFocus,
      _shortTermGoalDurationFocus,
      _shortTermSavedFocus,
    ];

    // 현재 포커스된 노드 얻기 (null일 수 있음)
    final FocusNode? currentFocus =
        FocusScope.of(context).focusedChild ??
        FocusManager.instance.primaryFocus;

    // 만약 현재 포커스가 목록에 있으면 다음 유효한 필드로 이동
    if (currentFocus != null) {
      final idx = orderedFocuses.indexWhere((f) => f == currentFocus);
      if (idx != -1) {
        for (int i = idx + 1; i < orderedFocuses.length; i++) {
          final next = orderedFocuses[i];
          if (next == null) continue;
          // 단기 목표 관련 필드는 섹션이 꺼져 있으면 건너뜀
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
        // 현재 포커스가 마지막 필드이면 fallback으로 아래 로직으로 넘어감
      }
    }
    // 위에서부터 첫 번째 빈 칸으로 포커스 이동 (키보드는 유지)
    final entries = <MapEntry<TextEditingController, FocusNode>>[
      MapEntry(_currentAgeController, _currentAgeFocus),
      MapEntry(_retireAgeController, _retireAgeFocus),
      MapEntry(_livingExpenseController, _livingExpenseFocus),
      MapEntry(_snpValueController, _snpValueFocus),
      MapEntry(_expectedReturnController, _expectedReturnFocus),
      MapEntry(_inflationController, _inflationFocus),
    ];

    if (_hasShortTermGoal) {
      // 드롭다운이 비어 있으면 드롭다운에 포커스
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
    // 모든 칸이 채워져 있으면 아무 동작도 하지 않음 (다음 화면 이동 등은 나중에 구현)
  }

  // 단순히 화면에 보이는 연월만 변경 (데이터 저장은 나중에 구현)
  void _changeMonth(DateTime newMonth) {
    _currentMonth.value = newMonth;
    // ValueNotifier가 알아서 리스너들에게 통지하므로 setState 불필요
    // 단, 현재 화면(Step1)도 갱신하려면 setState 호출 (아래 참고)
    if (mounted) setState(() {}); // Step1 화면 자체도 rebuild
  }

  @override
  Widget build(BuildContext context) {
    // KeyboardActions config (필요하면 활성화)
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
      appBar: AppBar(
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

        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(
              left: Sizes.size20,
              right: Sizes.size20,
              top: Sizes.size2,
              bottom: Sizes.size24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------- 월 네비게이션 바 (상단) ----------
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
                        _changeMonth(prev);
                      },
                    ),
                    Text(
                      '${_currentMonth.value.year}년 ${_currentMonth.value.month}월',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: "Gmarket_sans",
                        fontWeight: FontWeight.w500,
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
                        _changeMonth(next);
                      },
                    ),
                  ],
                ),
                Gaps.v12,
                Row(
                  children: [
                    const Icon(
                      Icons.flag_outlined, // 또는 Icons.trending_up
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '경제적자유 목표 설정',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size20,
                      ),
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
                ),
                Gaps.v16,
                NumberInputField(
                  label: '은퇴 희망 나이',
                  hint: '예: 65',
                  controller: _retireAgeController,
                  focusNode: _retireAgeFocus,
                  nextFocus: _livingExpenseFocus,
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
                  nextFocus: _hasShortTermGoal ? _shortTermDropdownFocus : null,
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
                      onChanged: (val) {
                        Future.microtask(() {
                          if (!mounted) return;
                          setState(() => _hasShortTermGoal = val);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Colors.transparent,
                    ),
                  ),
                ),
                if (_hasShortTermGoal) ...[
                  Gaps.v12,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
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
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Sizes.size8),
                              borderSide: BorderSide.none,
                            ),
                            border: OutlineInputBorder(
                              gapPadding: 5,
                              borderRadius: BorderRadius.circular(Sizes.size8),
                            ),
                          ),
                          hint: const Text('단기 목표 선택'),
                          initialValue: _selectedShortTermGoal,
                          items: _shortTermOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) => Future.microtask(() {
                            if (!mounted) return;
                            setState(() => _selectedShortTermGoal = val);
                          }),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? '단기 목표를 선택하세요' : null,
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
      // Next 버튼을 키보드 위에 고정
      bottomNavigationBar: BottomActionButton(
        allFieldsFilled: _allFieldsFilled,
        onNext: _onNext,
        onNavigate: _navigateToStep2,
        buttonFocus: _nextButtonFocus,
      ),
    );
  }
}
// ...existing code...