import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

const _investmentAccounts = ['연금', 'IRP', 'ISA', '일반'];

class AssetStatusScreen extends StatefulWidget {
  const AssetStatusScreen({super.key});

  @override
  State<AssetStatusScreen> createState() => _AssetStatusScreenState();
}

class _AssetStatusScreenState extends State<AssetStatusScreen> {
  DateTime _selectedMonth = DateTime.now();
  String _selectedTab = '투자';

  static const List<String> _tabs = ['투자', '저축', '부채'];

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 월 이동 헤더
            SafeArea(
              bottom: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black),
                      onPressed: () => _changeMonth(-1),
                    ),
                    Text(
                      '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size16 + Sizes.size2,
                        color: Colors.black,
                      ),
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

            Expanded(
              child: SingleChildScrollView(
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
                      const _InvestmentTabContent()
                    else
                      _AssetTabPlaceholder(selectedTab: _selectedTab),

                    const SizedBox(height: 24),
                  ],
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
  const _InvestmentTabContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _investmentAccounts
          .map(
            (name) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InvestmentAccountCard(accountName: name),
            ),
          )
          .toList(),
    );
  }
}

// ──────────────────────────────────────────────
// 계좌별 투자 카드 (계좌명 + New 배지만 표시)
// ──────────────────────────────────────────────
class _InvestmentAccountCard extends StatelessWidget {
  const _InvestmentAccountCard({required this.accountName});

  final String accountName;

  static const _accentColor = Color(0xFFE9435A);

  IconData get _icon {
    switch (accountName) {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(_icon, size: 22, color: const Color(0xFF5B7EFF)),
            const SizedBox(width: 10),
            Text(
              accountName,
              style: const TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
                fontSize: Sizes.size16,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            // New 배지 (평가금액 미입력 상태)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: Colors.white,
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
// 저축 / 부채 탭 placeholder
// ──────────────────────────────────────────────
class _AssetTabPlaceholder extends StatelessWidget {
  const _AssetTabPlaceholder({required this.selectedTab});

  final String selectedTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.construction_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            '$selectedTab 항목은 다음 단계에서 구현됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
              fontSize: Sizes.size14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
