import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/data/services/firestore_service.dart';
import 'package:miraclemoney/features/salary/presentation/widgets/form_widgets.dart';

const _investmentAccounts = ['연금', 'IRP', 'ISA', '일반'];
const _savingsAccounts = ['비상금', '단기목표', '주택청약', '내집마련', '기타'];
const _debtAccounts = ['신용대출', '전세대출', '주택담보대출', '기타'];

String _formatAmount(double amount) {
  if (amount <= 0) return '0원';
  return '${NumberFormat('#,###').format(amount.round())}원';
}

double _subAmount(Map<String, dynamic>? summary, String category, String key) {
  if (summary == null) return 0;
  final bySub = summary['bySubcategory'] as Map<String, dynamic>?;
  final catMap = bySub?[category] as Map<String, dynamic>?;
  return (catMap?[key] as num?)?.toDouble() ?? 0;
}

// ──────────────────────────────────────────────
// 계좌명 → Firestore 서브키 매핑
// ──────────────────────────────────────────────
String _investmentKey(String name) {
  switch (name) {
    case '연금':
      return 'PensionSaving';
    case 'IRP':
      return 'IRP';
    case 'ISA':
      return 'ISA';
    default:
      return 'General';
  }
}

String _savingsKey(String name) {
  switch (name) {
    case '비상금':
      return 'EmergencyFund';
    case '단기목표':
      return 'ShortTermGoal';
    case '주택청약':
      return 'HousingSubscription';
    case '내집마련':
      return 'HomeOwnership';
    default:
      return 'Other';
  }
}

String _debtKey(String name) {
  switch (name) {
    case '신용대출':
      return 'CreditLoan';
    case '전세대출':
      return 'JeonseLoan';
    case '주택담보대출':
      return 'Mortgage';
    default:
      return 'Other';
  }
}

class AssetStatusScreen extends StatefulWidget {
  const AssetStatusScreen({super.key});

  @override
  State<AssetStatusScreen> createState() => _AssetStatusScreenState();
}

class _AssetStatusScreenState extends State<AssetStatusScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  DateTime _selectedMonth = DateTime.now();
  String _selectedTab = '투자';
  Map<String, dynamic>? _summary;
  bool _isLoading = false;

  static const List<String> _tabs = ['투자', '저축', '부채'];

  // 사용자 직접 입력값 컨트롤러 — 부모가 소유·dispose
  final Map<String, TextEditingController> _investmentControllers = {
    'PensionSaving': TextEditingController(),
    'IRP': TextEditingController(),
    'ISA': TextEditingController(),
    'General': TextEditingController(),
  };

  final Map<String, TextEditingController> _savingsControllers = {
    'EmergencyFund': TextEditingController(),
    'ShortTermGoal': TextEditingController(),
    'HousingSubscription': TextEditingController(),
    'HomeOwnership': TextEditingController(),
    'Other': TextEditingController(),
  };

  final Map<String, TextEditingController> _debtControllers = {
    'CreditLoan': TextEditingController(),
    'JeonseLoan': TextEditingController(),
    'Mortgage': TextEditingController(),
    'Other': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _investmentControllers.values) {
      c.dispose();
    }
    for (final c in _savingsControllers.values) {
      c.dispose();
    }
    for (final c in _debtControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // monthly_summaries + asset_status를 병렬 로드
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<Map<String, dynamic>?>([
        _firestoreService.loadMonthlySummary(_selectedMonth),
        _firestoreService.loadAssetStatus(_selectedMonth),
      ]);
      if (mounted) {
        setState(() => _summary = results[0]);
        _populateControllers(results[1]);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _summary = null);
        _clearControllers();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 불러온 asset_status 값을 컨트롤러에 세팅
  void _populateControllers(Map<String, dynamic>? assetStatus) {
    void fill(
      Map<String, TextEditingController> controllers,
      String section,
      String valueKey,
    ) {
      final sectionData = assetStatus?[section] as Map<String, dynamic>?;
      for (final entry in controllers.entries) {
        final sub = sectionData?[entry.key] as Map<String, dynamic>?;
        final value = (sub?[valueKey] as num?)?.toDouble() ?? 0;
        entry.value.text =
            value > 0 ? NumberFormat('#,###').format(value.round()) : '';
      }
    }

    fill(_investmentControllers, 'investment', 'valuation');
    fill(_savingsControllers, 'saving', 'accumulated');
    fill(_debtControllers, 'debt', 'balance');
  }

  void _clearControllers() {
    for (final c in _investmentControllers.values) {
      c.text = '';
    }
    for (final c in _savingsControllers.values) {
      c.text = '';
    }
    for (final c in _debtControllers.values) {
      c.text = '';
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
    _loadData();
  }

  double _parseController(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '')) ?? 0.0;

  // 저장 버튼 핸들러
  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();

    final yearMonth =
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

    final assetData = {
      'yearMonth': yearMonth,
      'updatedAt': DateTime.now().toIso8601String(),
      'investment': {
        for (final e in _investmentControllers.entries)
          e.key: {'valuation': _parseController(e.value)},
      },
      'saving': {
        for (final e in _savingsControllers.entries)
          e.key: {'accumulated': _parseController(e.value)},
      },
      'debt': {
        for (final e in _debtControllers.entries)
          e.key: {'balance': _parseController(e.value)},
      },
    };

    try {
      await _firestoreService.saveAssetStatus(assetData, _selectedMonth);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '자산현황이 저장되었습니다.',
              style: TextStyle(fontFamily: 'Gmarket_sans'),
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '저장에 실패했습니다: $e',
              style: const TextStyle(fontFamily: 'Gmarket_sans'),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 월 이동 헤더 — 스크롤과 함께 이동
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                              ),
                              onPressed: () => _changeMonth(-1),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                                  style: const TextStyle(
                                    fontFamily: 'Gmarket_sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: Sizes.size16 + Sizes.size2,
                                    color: Colors.black,
                                  ),
                                ),
                                if (_isLoading) ...[
                                  const SizedBox(width: 8),
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.black,
                              ),
                              onPressed: () => _changeMonth(1),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // 총자산 그라데이션 카드
                          const _AssetSummaryCard(),

                          const SizedBox(height: 24),

                          // 탭 (투자 / 저축 / 부채)
                          _AssetTabSelector(
                            tabs: _tabs,
                            selectedTab: _selectedTab,
                            onTabSelected: (tab) =>
                                setState(() => _selectedTab = tab),
                          ),

                          const SizedBox(height: 16),

                          // 탭별 콘텐츠
                          if (_selectedTab == '투자')
                            _InvestmentTabContent(
                              summary: _summary,
                              controllers: _investmentControllers,
                            )
                          else if (_selectedTab == '저축')
                            _SavingsTabContent(
                              summary: _summary,
                              controllers: _savingsControllers,
                            )
                          else
                            _DebtTabContent(
                              summary: _summary,
                              controllers: _debtControllers,
                            ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 저장 버튼 (고정)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '자산현황 저장',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 총자산 요약 카드
// ──────────────────────────────────────────────
class _AssetSummaryCard extends StatelessWidget {
  const _AssetSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B7EFF), Color(0xFFAB47BC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B7EFF).withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '총자산액',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
              fontSize: Sizes.size14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '0원',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withAlpha(60)),
          const SizedBox(height: 12),
          const Text(
            '순자산 0원',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
              fontSize: Sizes.size14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 탭 셀렉터 (투자 / 저축 / 부채)
// ──────────────────────────────────────────────
class _AssetTabSelector extends StatelessWidget {
  const _AssetTabSelector({
    required this.tabs,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final List<String> tabs;
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = tab == selectedTab;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTabSelected(tab),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE9435A)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: Sizes.size12,
                        color:
                            isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 투자 탭 콘텐츠
// ──────────────────────────────────────────────
class _InvestmentTabContent extends StatelessWidget {
  const _InvestmentTabContent({
    required this.summary,
    required this.controllers,
  });

  final Map<String, dynamic>? summary;
  final Map<String, TextEditingController> controllers;

  static IconData _iconFor(String name) {
    switch (name) {
      case '연금':
        return Icons.savings_outlined;
      case 'IRP':
        return Icons.account_balance_outlined;
      case 'ISA':
        return Icons.bar_chart_outlined;
      default:
        return Icons.trending_up_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _investmentAccounts
          .map((name) {
            final key = _investmentKey(name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AssetAccountCard(
                accountName: name,
                icon: _iconFor(name),
                firstFieldLabel: '투자금액',
                firstFieldAmount: _subAmount(
                  summary,
                  'InvestmentExpenses',
                  key,
                ),
                secondFieldLabel: '평가금액',
                secondFieldHint: '평가금액 입력',
                controller: controllers[key]!,
              ),
            );
          })
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 저축 탭 콘텐츠
// ──────────────────────────────────────────────
class _SavingsTabContent extends StatelessWidget {
  const _SavingsTabContent({
    required this.summary,
    required this.controllers,
  });

  final Map<String, dynamic>? summary;
  final Map<String, TextEditingController> controllers;

  static IconData _iconFor(String name) {
    switch (name) {
      case '비상금':
        return Icons.account_balance_wallet_outlined;
      case '단기목표':
        return Icons.flag_outlined;
      case '주택청약':
        return Icons.home_outlined;
      case '내집마련':
        return Icons.house_outlined;
      default:
        return Icons.savings_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _savingsAccounts
          .map((name) {
            final key = _savingsKey(name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AssetAccountCard(
                accountName: name,
                icon: _iconFor(name),
                firstFieldLabel: '저축금액',
                firstFieldAmount: _subAmount(
                  summary,
                  'SavingExpenses',
                  key,
                ),
                secondFieldLabel: '누적금액',
                secondFieldHint: '누적금액 입력',
                controller: controllers[key]!,
              ),
            );
          })
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 부채 탭 콘텐츠
// ──────────────────────────────────────────────
class _DebtTabContent extends StatelessWidget {
  const _DebtTabContent({
    required this.summary,
    required this.controllers,
  });

  final Map<String, dynamic>? summary;
  final Map<String, TextEditingController> controllers;

  static IconData _iconFor(String name) {
    switch (name) {
      case '신용대출':
        return Icons.credit_card_outlined;
      case '전세대출':
        return Icons.apartment_outlined;
      case '주택담보대출':
        return Icons.home_work_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _debtAccounts
          .map((name) {
            final key = _debtKey(name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AssetAccountCard(
                accountName: name,
                icon: _iconFor(name),
                firstFieldLabel: '이자금액',
                firstFieldAmount: _subAmount(
                  summary,
                  'InterestExpenses',
                  key,
                ),
                secondFieldLabel: '대출잔액',
                secondFieldHint: '대출잔액 입력',
                controller: controllers[key]!,
              ),
            );
          })
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 공통 자산 계좌 카드
// ──────────────────────────────────────────────
class _AssetAccountCard extends StatefulWidget {
  const _AssetAccountCard({
    required this.accountName,
    required this.icon,
    required this.firstFieldLabel,
    required this.firstFieldAmount,
    required this.secondFieldLabel,
    required this.secondFieldHint,
    required this.controller,
  });

  final String accountName;
  final IconData icon;
  final String firstFieldLabel;
  final double firstFieldAmount;
  final String secondFieldLabel;
  final String secondFieldHint;
  final TextEditingController controller; // 부모가 소유

  @override
  State<_AssetAccountCard> createState() => _AssetAccountCardState();
}

class _AssetAccountCardState extends State<_AssetAccountCard> {
  static const _accentColor = Color(0xFFE9435A);

  bool _isExpanded = false;
  late bool _hasValue;

  @override
  void initState() {
    super.initState();
    _hasValue = widget.controller.text.isNotEmpty; // 초기값 반영
    widget.controller.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    final hasValue = widget.controller.text.isNotEmpty;
    if (hasValue != _hasValue) setState(() => _hasValue = hasValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onInputChanged);
    // controller 자체는 부모가 dispose하므로 여기서는 제거하지 않음
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded
                ? _accentColor.withAlpha(80)
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(_isExpanded ? 14 : 8),
              blurRadius: _isExpanded ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 (탭 가능)
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(16),
                bottom: Radius.circular(_isExpanded ? 0 : 16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, size: 22, color: const Color(0xFF5B7EFF)),
                    const SizedBox(width: 10),
                    Text(
                      widget.accountName,
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16,
                        color: Colors.black,
                      ),
                    ),
                    if (!_hasValue) ...[
                      const SizedBox(width: 6),
                      const Text(
                        'New',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: _accentColor,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),

            // 펼침 영역
            if (_isExpanded) ...[
              Container(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 첫 번째 필드 — monthly_summaries 연동 (읽기 전용)
                    _FieldLabel(widget.firstFieldLabel),
                    const SizedBox(height: 6),
                    Text(
                      _formatAmount(widget.firstFieldAmount),
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w700,
                        fontSize: Sizes.size16,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 두 번째 필드 — 사용자 직접 입력 (저장 대상)
                    _FieldLabel(widget.secondFieldLabel),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandsSeparatorInputFormatter()],
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: widget.secondFieldHint,
                          hintStyle: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: Sizes.size14,
                            color: Colors.grey.shade400,
                          ),
                          suffixText: '원',
                          suffixStyle: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: Sizes.size14,
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w500,
                          fontSize: Sizes.size14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Gmarket_sans',
        fontSize: Sizes.size12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade600,
      ),
    );
  }
}
