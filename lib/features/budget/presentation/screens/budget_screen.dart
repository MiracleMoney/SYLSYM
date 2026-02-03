import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  DateTime _selectedMonth = DateTime.now();

  // 카테고리별 확장 상태
  final Map<String, bool> _expandedCategories = {
    'Fixed': true,
    'Investment': false,
    'Saving': false,
    'Living': false,
    'Interest': false,
  };

  // 카테고리별 예산 데이터
  final Map<String, Map<String, TextEditingController>> _budgetControllers = {
    'Fixed': {
      '보험': TextEditingController(text: '0'),
      '통신비': TextEditingController(text: '0'),
      '대중교통': TextEditingController(text: '0'),
      '자동차 할부': TextEditingController(text: '0'),
      '자동차 보험': TextEditingController(text: '0'),
      '주유': TextEditingController(text: '0'),
      '월세': TextEditingController(text: '0'),
      '공과금': TextEditingController(text: '0'),
      '관리비': TextEditingController(text: '0'),
      '기타': TextEditingController(text: '0'),
    },
    'Investment': {
      '연금 저축': TextEditingController(text: '0'),
      '퇴직 연금': TextEditingController(text: '0'),
      'ISA': TextEditingController(text: '0'),
      '일반계좌': TextEditingController(text: '0'),
    },
    'Saving': {
      '비상금': TextEditingController(text: '0'),
      '단기 목표': TextEditingController(text: '0'),
      '주택 청약': TextEditingController(text: '0'),
      '내집 마련': TextEditingController(text: '0'),
      '기타': TextEditingController(text: '0'),
    },
    'Living': {
      '식비': TextEditingController(text: '0'),
      '외식': TextEditingController(text: '0'),
      '배달 음식': TextEditingController(text: '0'),
      '커피': TextEditingController(text: '0'),
      '음료': TextEditingController(text: '0'),
      '술': TextEditingController(text: '0'),
      '생필품': TextEditingController(text: '0'),
      '담배': TextEditingController(text: '0'),
      '미용': TextEditingController(text: '0'),
      '옷': TextEditingController(text: '0'),
      '신발': TextEditingController(text: '0'),
      '액세서리': TextEditingController(text: '0'),
      '문화 생활': TextEditingController(text: '0'),
      '모임 회비': TextEditingController(text: '0'),
      '취미': TextEditingController(text: '0'),
      'OTT': TextEditingController(text: '0'),
      'OTT 외 구독 서비스': TextEditingController(text: '0'),
      '기타': TextEditingController(text: '0'),
    },
    'Interest': {
      '신용 대출': TextEditingController(text: '0'),
      '전세 대출': TextEditingController(text: '0'),
      '주택 담보 대출': TextEditingController(text: '0'),
      '기타 이자': TextEditingController(text: '0'),
    },
  };

  final TextEditingController _monthlyIncomeController = TextEditingController(
    text: '5000000',
  );

  @override
  void dispose() {
    for (var category in _budgetControllers.values) {
      for (var controller in category.values) {
        controller.dispose();
      }
    }
    _monthlyIncomeController.dispose();
    super.dispose();
  }

  double _getCategoryTotal(String category) {
    double total = 0;
    for (var controller in _budgetControllers[category]!.values) {
      final value = double.tryParse(controller.text) ?? 0;
      total += value;
    }
    return total;
  }

  double _getTotalBudget() {
    double total = 0;
    for (var category in _budgetControllers.keys) {
      total += _getCategoryTotal(category);
    }
    return total;
  }

  void _changeMonth(int months) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + months,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => _changeMonth(-1),
        ),
        title: Text(
          '${_selectedMonth.year}년 ${_selectedMonth.month}월',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w500,
            fontSize: Sizes.size16 + Sizes.size2,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chevron_right, color: Colors.black),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._budgetControllers.keys.map((category) {
                  return _buildCategorySection(category);
                }),
                const SizedBox(height: 24),
                _buildSummarySection(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final isExpanded = _expandedCategories[category] ?? false;
    final categoryTotal = _getCategoryTotal(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.chevron_right,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontWeight: FontWeight.w500,
                        fontSize: Sizes.size14,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    '\$${NumberFormat('#,###').format(categoryTotal.toInt())}',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: Sizes.size14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: _budgetControllers[category]!.entries.map((entry) {
                  return _buildBudgetItem(entry.key, entry.value);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w400,
                fontSize: Sizes.size12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w400,
                fontSize: Sizes.size12,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w400,
                  fontSize: Sizes.size12,
                  color: Colors.grey.shade600,
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
                  borderSide: BorderSide(color: Color(0xFFE9435A)),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final totalBudget = _getTotalBudget();
    final monthlyIncome = double.tryParse(_monthlyIncomeController.text) ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w600,
              fontSize: Sizes.size16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          ..._budgetControllers.keys.map((category) {
            final total = _getCategoryTotal(category);
            return _buildSummaryRow(category, total);
          }),
          Divider(height: 24, color: Colors.grey.shade300),
          _buildSummaryRow('Total Budget', totalBudget, isBold: true),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Monthly Income',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w400,
                    fontSize: Sizes.size14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _monthlyIncomeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w500,
                    fontSize: Sizes.size14,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w500,
                      fontSize: Sizes.size14,
                      color: Colors.grey.shade600,
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
                      borderSide: BorderSide(color: Color(0xFFE9435A)),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              fontSize: Sizes.size14,
              color: isBold ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            '\$${NumberFormat('#,###').format(amount.toInt())}',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              fontSize: Sizes.size14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              // TODO: 예산 저장 로직
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Budget saved!')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE9435A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save Budget',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w600,
                fontSize: Sizes.size16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
