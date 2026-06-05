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

// 입력 자릿수에 따른 동적 폰트 크기 (₩ 120px 입력칸 기준)
// 입력 금액 구간별 폰트 크기 (₩ 120px 입력칸 기준)
double _inputFontSize(String text) {
  final value = int.tryParse(text.replaceAll(',', '')) ?? 0;
  if (value >= 100000000) return 11; // 1억 이상
  if (value >= 10000000) return 13;  // 1천만 이상
  return 14;                          // ~ 9,999,999
}

// 순자산 전용: 음수도 실제 값 그대로 표시
String _formatNetAmount(double amount) {
  if (amount == 0) return '0원';
  final formatted = NumberFormat('#,###').format(amount.abs().round());
  return amount < 0 ? '-$formatted원' : '$formatted원';
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

class _AssetStatusScreenState extends State<AssetStatusScreen>
    with AutomaticKeepAliveClientMixin {
  final FirestoreService _firestoreService = FirestoreService();

  DateTime _selectedMonth = DateTime.now();
  String _selectedTab = '투자';
  Map<String, dynamic>? _summary;
  bool _isLoading = false;
  bool _isSaving = false;

  double _totalAssets = 0;
  double _netAssets = 0;

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

  @override
  bool get wantKeepAlive => true;

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  // monthly_summaries + asset_status를 병렬 로드
  Future<void> _loadData() async {
    final targetMonth = _selectedMonth; // 호출 시점 월 캡처
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait<Map<String, dynamic>?>([
        _firestoreService.loadMonthlySummary(targetMonth),
        _firestoreService.loadAssetStatus(targetMonth),
      ]);
      // 응답 도착 시점에 월이 바뀌었으면 결과 무시
      if (!mounted || !_isSameMonth(_selectedMonth, targetMonth)) return;
      setState(() => _summary = results[0]);
      _populateControllers(results[1]);
    } catch (_) {
      if (!mounted || !_isSameMonth(_selectedMonth, targetMonth)) return;
      // 읽기 실패 시 summary만 null로 처리, 컨트롤러 값은 유지
      setState(() => _summary = null);
    } finally {
      if (mounted && _isSameMonth(_selectedMonth, targetMonth)) {
        setState(() => _isLoading = false);
      }
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
        entry.value.text = value > 0
            ? NumberFormat('#,###').format(value.round())
            : '';
      }
    }

    fill(_investmentControllers, 'investment', 'valuation');
    fill(_savingsControllers, 'saving', 'accumulated');
    fill(_debtControllers, 'debt', 'balance');

    _computeAssets();
  }

  // 총자산액 = investment valuation 합 + saving accumulated 합
  // 순자산액 = 총자산액 - debt balance 합
  void _computeAssets() {
    double total = 0;
    for (final c in _investmentControllers.values) {
      total += double.tryParse(c.text.replaceAll(',', '')) ?? 0;
    }
    for (final c in _savingsControllers.values) {
      total += double.tryParse(c.text.replaceAll(',', '')) ?? 0;
    }

    double debt = 0;
    for (final c in _debtControllers.values) {
      debt += double.tryParse(c.text.replaceAll(',', '')) ?? 0;
    }

    setState(() {
      _totalAssets = total;
      _netAssets = total - debt;
    });
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

  // monthly_summaries에서 특정 카테고리의 세부항목 합계
  double _subcategoryTotal(String category) {
    if (_summary == null) return 0;
    final bySub = _summary!['bySubcategory'] as Map<String, dynamic>?;
    final catMap = bySub?[category] as Map<String, dynamic>?;
    if (catMap == null) return 0;
    double total = 0;
    for (final v in catMap.values) {
      total += (v as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  // 컨트롤러 맵 전체 합계
  double _sumControllers(Map<String, TextEditingController> controllers) {
    double total = 0;
    for (final c in controllers.values) {
      total += double.tryParse(c.text.replaceAll(',', '')) ?? 0;
    }
    return total;
  }

  // 저장 버튼 핸들러
  Future<void> _onSave() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

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
      _computeAssets(); // 저장 직후 상단 카드 즉시 갱신
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                          _AssetSummaryCard(
                            totalAssets: _totalAssets,
                            netAssets: _netAssets,
                            onRefresh: _loadData,
                            isRefreshing: _isLoading,
                          ),

                          const SizedBox(height: 24),

                          // 탭 (투자 / 저축 / 부채)
                          _AssetTabSelector(
                            tabs: _tabs,
                            selectedTab: _selectedTab,
                            onTabSelected: (tab) =>
                                setState(() => _selectedTab = tab),
                          ),

                          const SizedBox(height: 16),

                          // 탭별 요약 카드 + 계좌 목록
                          if (_selectedTab == '투자') ...[
                            _InvestmentSummaryCard(
                              principal: _subcategoryTotal(
                                'InvestmentExpenses',
                              ),
                              valuation: _sumControllers(
                                _investmentControllers,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _InvestmentTabContent(
                              summary: _summary,
                              controllers: _investmentControllers,
                            ),
                          ] else if (_selectedTab == '저축') ...[
                            _SavingSummaryCard(
                              savingAmount: _subcategoryTotal('SavingExpenses'),
                              accumulated: _sumControllers(_savingsControllers),
                            ),
                            const SizedBox(height: 12),
                            _SavingsTabContent(
                              summary: _summary,
                              controllers: _savingsControllers,
                            ),
                          ] else ...[
                            _DebtSummaryCard(
                              interestAmount: _subcategoryTotal(
                                'InterestExpenses',
                              ),
                              balance: _sumControllers(_debtControllers),
                            ),
                            const SizedBox(height: 12),
                            _DebtTabContent(
                              summary: _summary,
                              controllers: _debtControllers,
                            ),
                          ],

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
                    onPressed: (_isLoading || _isSaving) ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '저장',
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
  const _AssetSummaryCard({
    required this.totalAssets,
    required this.netAssets,
    this.onRefresh,
    this.isRefreshing = false,
  });

  final double totalAssets;
  final double netAssets;
  final VoidCallback? onRefresh;
  final bool isRefreshing;

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
          Row(
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
              const SizedBox(width: 4),
              if (onRefresh != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: isRefreshing ? null : onRefresh,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: isRefreshing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.white70,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: Colors.white70,
                              size: 18,
                            ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(totalAssets),
            style: const TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withAlpha(60)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '순자산 ${_formatNetAmount(netAssets)}',
                style: const TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w500,
                  fontSize: Sizes.size14,
                  color: Colors.white70,
                ),
              ),
              if (netAssets < 0) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        '순자산이 마이너스입니다',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      content: const Text(
                        '현재 부채가 자산보다 많습니다.\n\n'
                        '순자산은 총자산 - 부채로 계산되며,\n'
                        '현재는 부채가 자산보다 더 많아 순자산이 음수 상태입니다.\n\n'
                        '장기적으로 부채 감소 또는 자산 증가를 통해 순자산을 개선할 수 있습니다.',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                          ),
                          child: const Text(
                            '확인',
                            style: TextStyle(
                              fontFamily: 'Gmarket_sans',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('⚠️', style: TextStyle(fontSize: 14)),
                ),
              ],
            ],
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
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: Sizes.size12,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
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

  static const _color = Color(0xFFFFA726); // 예산 화면 투자 카테고리 색상

  static IconData _iconFor(String name) {
    switch (name) {
      case '연금':
        return Icons.account_balance;
      case 'IRP':
        return Icons.work_rounded;
      case 'ISA':
        return Icons.money;
      default:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _investmentAccounts.map((name) {
        final key = _investmentKey(name);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AssetAccountCard(
            accountName: name,
            icon: _iconFor(name),
            categoryColor: _color,
            firstFieldLabel: '투자금액',
            firstFieldAmount: _subAmount(summary, 'InvestmentExpenses', key),
            secondFieldHint: '0',
            controller: controllers[key]!,
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 저축 탭 콘텐츠
// ──────────────────────────────────────────────
class _SavingsTabContent extends StatelessWidget {
  const _SavingsTabContent({required this.summary, required this.controllers});

  final Map<String, dynamic>? summary;
  final Map<String, TextEditingController> controllers;

  static const _color = Color(0xFFEC407A); // 예산 화면 저축 카테고리 색상

  static IconData _iconFor(String name) {
    switch (name) {
      case '비상금':
        return Icons.warning_amber;
      case '단기목표':
        return Icons.flag;
      case '주택청약':
        return Icons.home_work;
      case '내집마련':
        return Icons.house;
      default:
        return Icons.savings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _savingsAccounts.map((name) {
        final key = _savingsKey(name);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AssetAccountCard(
            accountName: name,
            icon: _iconFor(name),
            categoryColor: _color,
            firstFieldLabel: '저축금액',
            firstFieldAmount: _subAmount(summary, 'SavingExpenses', key),
            secondFieldHint: '0',
            controller: controllers[key]!,
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 부채 탭 콘텐츠
// ──────────────────────────────────────────────
class _DebtTabContent extends StatelessWidget {
  const _DebtTabContent({required this.summary, required this.controllers});

  final Map<String, dynamic>? summary;
  final Map<String, TextEditingController> controllers;

  static const _color = Color(0xFFAB47BC); // 예산 화면 이자 카테고리 색상

  static IconData _iconFor(String name) {
    switch (name) {
      case '신용대출':
        return Icons.credit_card;
      case '전세대출':
        return Icons.apartment;
      case '주택담보대출':
        return Icons.home;
      default:
        return Icons.percent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _debtAccounts.map((name) {
        final key = _debtKey(name);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AssetAccountCard(
            accountName: name,
            icon: _iconFor(name),
            categoryColor: _color,
            firstFieldLabel: '이자금액',
            firstFieldAmount: _subAmount(summary, 'InterestExpenses', key),
            secondFieldHint: '0',
            controller: controllers[key]!,
          ),
        );
      }).toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 공통 자산 계좌 카드 (예산 입력 카드 스타일)
// ──────────────────────────────────────────────
class _AssetAccountCard extends StatelessWidget {
  const _AssetAccountCard({
    required this.accountName,
    required this.icon,
    required this.categoryColor,
    required this.firstFieldLabel,
    required this.firstFieldAmount,
    required this.secondFieldHint,
    required this.controller,
  });

  final String accountName;
  final IconData icon;
  final Color categoryColor;
  final String firstFieldLabel;
  final double firstFieldAmount;
  final String secondFieldHint;
  final TextEditingController controller; // 부모가 소유·dispose

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 아이콘 컨테이너 (예산 카드와 동일 구조)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: categoryColor, width: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: categoryColor, size: 18),
          ),
          const SizedBox(width: 12),
          // 왼쪽: 계좌명 + 읽기 전용 금액
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w700,
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$firstFieldLabel  ${_formatAmount(firstFieldAmount)}',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: Sizes.size10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 오른쪽: 사용자 직접 입력 — 자릿수에 따라 폰트 크기 자동 조정
          SizedBox(
            width: 120,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final fontSize = _inputFontSize(value.text);
                return TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandsSeparatorInputFormatter()],
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₩ ',
                    prefixStyle: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                      color: Colors.grey.shade600,
                    ),
                    hintText: secondFieldHint,
                    hintStyle: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w400,
                      fontSize: fontSize,
                      color: Colors.grey.shade400,
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFE9435A)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// 요약 카드 공통 컨테이너
// ──────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items});

  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: items.map((e) => Expanded(child: e)).toList()),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: Sizes.size12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size14,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// 투자 요약 카드
// ──────────────────────────────────────────────
class _InvestmentSummaryCard extends StatelessWidget {
  const _InvestmentSummaryCard({
    required this.principal,
    required this.valuation,
  });

  final double principal;
  final double valuation;

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      items: [
        _SummaryItem(label: '투자원금', value: _formatAmount(principal)),
        _SummaryItem(
          label: '평가금액',
          value: _formatAmount(valuation),
          alignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// 저축 요약 카드
// ──────────────────────────────────────────────
class _SavingSummaryCard extends StatelessWidget {
  const _SavingSummaryCard({
    required this.savingAmount,
    required this.accumulated,
  });

  final double savingAmount;
  final double accumulated;

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      items: [
        _SummaryItem(label: '저축금액', value: _formatAmount(savingAmount)),
        _SummaryItem(
          label: '누적금액',
          value: _formatAmount(accumulated),
          alignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// 부채 요약 카드
// ──────────────────────────────────────────────
class _DebtSummaryCard extends StatelessWidget {
  const _DebtSummaryCard({
    required this.interestAmount,
    required this.balance,
  });

  final double interestAmount;
  final double balance;

  @override
  Widget build(BuildContext context) {
    return _SummaryCard(
      items: [
        _SummaryItem(label: '이자금액', value: _formatAmount(interestAmount)),
        _SummaryItem(
          label: '대출잔액',
          value: _formatAmount(balance),
          alignment: CrossAxisAlignment.end,
        ),
      ],
    );
  }
}
