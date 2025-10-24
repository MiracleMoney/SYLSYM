// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'widget.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

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

  bool _hasShortTermGoal = true;
  String? _selectedShortTermGoal;
  final List<String> _shortTermOptions = ['결혼', '자동차', '여행', '기타'];

  // helper lists for iteration
  late final List<TextEditingController> _allControllers;
  late final List<FocusNode> _allFocusNodes;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
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
    ];
  }

  Future<void> _loadSavedData() async {
    // TODO: DB에서 불러와 controller.text에 세팅
    // ex) final saved = await MyDbService.loadUserInputs();
    // _currentAgeController.text = saved.currentAge?.toString() ?? '';
  }

  @override
  void dispose() {
    for (final c in _allControllers) {
      c.dispose();
    }
    for (final f in _allFocusNodes) {
      f.dispose();
    }
    super.dispose();
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

  Widget _buildNumberField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.number,
    List<TextInputFormatter>? inputFormatters,
    String? suffixText,
    required FocusNode? nextFocus,
    bool allowDecimal = false,
    TextInputAction? action,
  }) {
    final defaultFormatters = allowDecimal
        ? <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ]
        : <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            ThousandsSeparatorInputFormatter(),
          ];

    return LabeledTextFormField(
      label: label,
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters ?? defaultFormatters,
      suffixText: suffixText,
      focusNode: focusNode,
      textInputAction: action ?? TextInputAction.next,
      onFieldSubmitted: (_) {
        // 레이아웃/시맨틱스 중간에 포커스 변경으로 인한 assertion 방지
        Future.microtask(() {
          if (!mounted) return;
          if (nextFocus != null) {
            FocusScope.of(context).requestFocus(nextFocus);
          } else {
            FocusScope.of(context).unfocus();
          }
        });
      },

      validator: _numberValidator,
    );
  }

  Future<void> _onNext() async {
    // 위에서부터 첫 번째 빈 칸으로 포커스 이동 (자동 입력 없음)
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
        // build/레이아웃이 끝난 뒤 포커스 이동 — microtask로 연기
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

    // 모두 채워졌으면 검증 후 처리
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentAge = _parseDouble(_currentAgeController.text);
    // TODO: 실제 처리 로직 추가
    if (currentAge == null) return;
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
      appBar: AppBar(title: const Text('월급 최적화')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size20,
              vertical: Sizes.size24,
            ),
            child: Column(
              children: [
                _buildNumberField(
                  label: '현재 나이',
                  hint: '현재 나이',
                  controller: _currentAgeController,
                  focusNode: _currentAgeFocus,
                  nextFocus: _retireAgeFocus,
                ),
                const SizedBox(height: 28),
                _buildNumberField(
                  label: '은퇴 희망 나이',
                  hint: '예: 65',
                  controller: _retireAgeController,
                  focusNode: _retireAgeFocus,
                  nextFocus: _livingExpenseFocus,
                ),
                const SizedBox(height: 28),
                _buildNumberField(
                  label: '현재 희망 생활비',
                  hint: '예: 2,000,000',
                  controller: _livingExpenseController,
                  focusNode: _livingExpenseFocus,
                  nextFocus: _snpValueFocus,
                  suffixText: '₩',
                ),
                const SizedBox(height: 28),
                _buildNumberField(
                  label: '현재 S&P500 평가금액',
                  hint: '예: 3,000,000',
                  controller: _snpValueController,
                  focusNode: _snpValueFocus,
                  nextFocus: _expectedReturnFocus,
                  suffixText: '₩',
                ),
                const SizedBox(height: 28),
                _buildNumberField(
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
                const SizedBox(height: 28),
                _buildNumberField(
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
                const SizedBox(height: 28),
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
                            ?.copyWith(fontWeight: FontWeight.w700),
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
                  const SizedBox(height: 28),
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
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
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
                        const SizedBox(height: 28),
                        _buildNumberField(
                          label: '단기 목표 금액',
                          hint: '예: 1,000,000',
                          controller: _shortTermGoalAmountController,
                          focusNode: _shortTermGoalAmountFocus,
                          nextFocus: _shortTermGoalDurationFocus,
                          suffixText: '₩',
                        ),
                        const SizedBox(height: 28),
                        _buildNumberField(
                          label: '단기 목표 기간 (월)',
                          hint: '예: 12',
                          controller: _shortTermGoalDurationController,
                          focusNode: _shortTermGoalDurationFocus,
                          nextFocus: _shortTermSavedFocus,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 28),
                        _buildNumberField(
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
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.grey.shade400, width: 2),
              ),
              onPressed: _onNext,
              child: const Text('Next'),
            ),
          ),
        ),
      ),
    );
  }
}
// ...existing code...