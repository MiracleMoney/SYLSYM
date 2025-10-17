import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'widget.dart';

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

  bool _hasShortTermGoal = false;
  String? _selectedShortTermGoal;
  final List<String> _shortTermOptions = ['결혼', '자동차', '여행', '기타'];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    // TODO: DB에서 불러와 controller.text에 세팅
    // ex) final saved = await MyDbService.loadUserInputs();
    // _currentAgeController.text = saved.currentAge?.toString() ?? '';
  }

  @override
  void dispose() {
    _currentAgeController.dispose();
    _retireAgeController.dispose();
    _livingExpenseController.dispose();
    _snpValueController.dispose();
    _expectedReturnController.dispose();
    _inflationController.dispose();
    _shortTermGoalController.dispose();
    _shortTermGoalAmountController.dispose();
    _shortTermGoalDurationController.dispose();
    _shortTermSavedController.dispose();
    super.dispose();
  }

  double? _parseDouble(String? s) {
    if (s == null) return null;
    final normalized = s.replaceAll(',', '').trim();
    return double.tryParse(normalized);
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentAge = _parseDouble(_currentAgeController.text);
    final retireAge = _parseDouble(_retireAgeController.text);
    final livingExpense = _parseDouble(_livingExpenseController.text);
    final snpValue = _parseDouble(_snpValueController.text);
    final expectedReturn = _parseDouble(_expectedReturnController.text);
    final inflation = _parseDouble(_inflationController.text);
    final shortTermGoal = _shortTermGoalController.text.trim();

    // TODO: null/비정상 값 처리 및 계산 로직 호출
    // TODO: DB 저장 예: await MyDbService.saveUserInputs(...);

    // 예시 간단 검증
    if (currentAge == null) {
      // 오류 처리(토스트/다이얼로그 등)
      return;
    }

    // 계산 호출 예: final result = FinancialCalculator.compute(...);
  }

  String? _numberValidator(String? v) {
    if (v == null || v.trim().isEmpty) return '값을 입력하세요';
    if (_parseDouble(v) == null) return '유효한 숫자를 입력하세요';
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                LabeledTextFormField(
                  label: '현재 나이',
                  hint: '현재 나이',
                  controller: _currentAgeController,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 18),
                LabeledTextFormField(
                  label: '은퇴 희망 나이',
                  hint: '은퇴 희망 나이',
                  controller: _retireAgeController,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 18),
                LabeledTextFormField(
                  label: '현재 희망 생활비',
                  hint: '현재 희망 생활비',
                  controller: _livingExpenseController,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 18),
                LabeledTextFormField(
                  label: '현재 S&P500 평가금액',
                  hint: '현재 S&P500 평가금액',
                  controller: _snpValueController,
                  keyboardType: TextInputType.number,
                  validator: _numberValidator,
                ),
                const SizedBox(height: 18),
                LabeledTextFormField(
                  label: '기대수익률',
                  hint: '기대수익률',
                  controller: _expectedReturnController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _numberValidator,
                ),
                const SizedBox(height: 18),
                LabeledTextFormField(
                  label: '예상 물가 상승률',
                  hint: '예상 물가 상승률',
                  controller: _inflationController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _numberValidator,
                ),
                const SizedBox(height: 18),
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
                      title: const Text(
                        '단기 목표가 있나요?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      value: _hasShortTermGoal,
                      onChanged: (val) =>
                          setState(() => _hasShortTermGoal = val),
                      // SwitchListTile의 배경/모양을 추가로 제어하려면 아래 사용
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: Colors.transparent,
                    ),
                  ),
                ),

                if (_hasShortTermGoal) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '단기 목표를 고르세요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
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
                          onChanged: (val) =>
                              setState(() => _selectedShortTermGoal = val),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? '단기 목표를 선택하세요' : null,
                        ),
                        const SizedBox(height: 18),
                        LabeledTextFormField(
                          label: '단기 목표 금액',
                          hint: '예: 1,000,000',
                          controller: _shortTermGoalAmountController,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                        const SizedBox(height: 12),
                        LabeledTextFormField(
                          label: '단기 목표 기간 (월)',
                          hint: '예: 12',
                          controller: _shortTermGoalDurationController,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                        const SizedBox(height: 12),
                        LabeledTextFormField(
                          label: '현재 단기 목표 저축액',
                          hint: '예: 500,000',
                          controller: _shortTermSavedController,
                          keyboardType: TextInputType.number,
                          validator: _numberValidator,
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _onSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
