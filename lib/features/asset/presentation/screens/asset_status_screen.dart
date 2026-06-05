import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';

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
                    _AssetSummaryCard(),

                    const SizedBox(height: 24),

                    // 탭 (투자 / 저축 / 부채)
                    _AssetTabSelector(
                      tabs: _tabs,
                      selectedTab: _selectedTab,
                      onTabSelected: (tab) => setState(() => _selectedTab = tab),
                    ),

                    const SizedBox(height: 16),

                    // 탭별 placeholder
                    _AssetTabPlaceholder(selectedTab: _selectedTab),
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

class _AssetSummaryCard extends StatelessWidget {
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
          Container(
            height: 1,
            color: Colors.white.withAlpha(60),
          ),
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
                        color: isSelected
                            ? Colors.white
                            : Colors.grey.shade700,
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
          Icon(Icons.construction_outlined, size: 40, color: Colors.grey.shade400),
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
