// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import '../widgets/form_widgets.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'salary_step2_screen.dart'; // same-folde
import '../widgets/bottom_action_button.dart';
import '../widgets/number_input_field.dart';
import '../../../../data/services/firestore_service.dart';
import '../widgets/month_selector.dart';
import '../../../../shared/widgets/loading/section_header.dart';

class SalaryStep1Screen extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onNavigateToStep2;
  final ValueNotifier<DateTime>? currentMonthNotifier; // ✅ 추가
  final Map<String, dynamic>? initialControllers; // ✅ 추가

  const SalaryStep1Screen({
    super.key,
    this.onNavigateToStep2,
    this.currentMonthNotifier, // ✅ 추가
    this.initialControllers, // ✅ 추가
  });

  @override
  State<SalaryStep1Screen> createState() => _SalaryStep1ScreenState();
}

class _SalaryStep1ScreenState extends State<SalaryStep1Screen> {
  final FirestoreService _firestoreService = FirestoreService();

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
    super.initState(); // ✅ 외부에서 전달받으면 사용, 없으면 새로 생성
    if (widget.currentMonthNotifier != null) {
      _currentMonth = widget.currentMonthNotifier!;
    } else {
      _currentMonth = ValueNotifier<DateTime>(DateTime.now());
    }
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
    // ✅ 초기 컨트롤러 값이 있으면 설정
    if (widget.initialControllers != null &&
        widget.initialControllers!.isNotEmpty) {
      _loadInitialData(widget.initialControllers!);
    }

    for (final c in _allControllers) {
      c.addListener(_onFieldChanged);
    }

    // ✅ 저장된 데이터 불러오기 추가
    // _loadSavedData();
  }

  // ✅ 초기 데이터를 컨트롤러에 로드하는 메서드
  void _loadInitialData(Map<String, dynamic> controllers) {
    // ✅ 숫자 포맷팅 헬퍼 함수
    String formatNumber(String text) {
      if (text.isEmpty) return '';

      // 이미 콤마가 있으면 그대로 반환
      if (text.contains(',')) return text;

      // 숫자만 추출
      final number = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), ''));
      if (number == null) return text;

      final intValue = number.toInt();
      final formatted = intValue.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return formatted;
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
      final text =
          (controllers['livingExpenseController'] as TextEditingController)
              .text;
      _livingExpenseController.text = formatNumber(text); // ✅ 포맷팅 적용
    }
    if (controllers['snpValueController'] is TextEditingController) {
      final text =
          (controllers['snpValueController'] as TextEditingController).text;
      _snpValueController.text = formatNumber(text); // ✅ 포맷팅 적용
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
      final text =
          (controllers['shortTermAmountController'] as TextEditingController)
              .text;
      _shortTermGoalAmountController.text = formatNumber(text); // ✅ 포맷팅 적용
    }
    if (controllers['shortTermDurationController'] is TextEditingController) {
      _shortTermGoalDurationController.text =
          (controllers['shortTermDurationController'] as TextEditingController)
              .text;
    }
    if (controllers['shortTermSavedController'] is TextEditingController) {
      final text =
          (controllers['shortTermSavedController'] as TextEditingController)
              .text;
      _shortTermSavedController.text = formatNumber(text); // ✅ 포맷팅 적용
    }
  }

  void _onFieldChanged() {
    // 간단히 rebuild 하여 bottomNavigationBar 버튼을 교체
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.removeListener(_onFieldChanged);

      // ✅ TabBar 모드에서는 컨트롤러를 dispose하지 않음 (부모가 관리)
      if (widget.onNavigateToStep2 == null) {
        c.dispose(); // 독립 실행 모드에서만 dispose
      }
    }
    for (final f in _allFocusNodes) {
      f.dispose();
    }
    // ✅ 외부에서 전달받지 않은 경우에만 dispose
    if (widget.currentMonthNotifier == null) {
      _currentMonth.dispose();
    } // ValueNotifier dispose

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
      // TabBar 모드: 콜백 사용
      widget.onNavigateToStep2!(controllers);
    } else {
      // 독립 실행 모드: Navigator 사용
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SalaryStep2Screen(
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
      body: SingleChildScrollView(
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
                // ---------- 월 네비게이션 바 (상단) ----------
                MonthSelector(
                  currentMonth: _currentMonth.value,
                  onPreviousMonth: () {
                    final prev = DateTime(
                      _currentMonth.value.year,
                      _currentMonth.value.month - 1,
                    );
                    _changeMonth(prev);
                  },
                  onNextMonth: () {
                    final next = DateTime(
                      _currentMonth.value.year,
                      _currentMonth.value.month + 1,
                    );
                    _changeMonth(next);
                  },
                ),
                Gaps.v12,
                Row(
                  children: [
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
                      tileColor: Colors.transparent,
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
                          dropdownColor: Colors.white,
                          focusNode: _shortTermDropdownFocus,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(Sizes.size8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
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