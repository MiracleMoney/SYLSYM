import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminFinanceStatsTab extends StatefulWidget {
  const AdminFinanceStatsTab({super.key});

  @override
  State<AdminFinanceStatsTab> createState() => _AdminFinanceStatsTabState();
}

class _AdminFinanceStatsTabState extends State<AdminFinanceStatsTab> {
  bool _isLoading = true;

  // 전체 통계
  FinanceStats _totalStats = FinanceStats.empty();

  // 성별 통계
  FinanceStats _maleStats = FinanceStats.empty();
  FinanceStats _femaleStats = FinanceStats.empty();
  FinanceStats _unknownGenderStats = FinanceStats.empty();

  // 연령대별 통계
  Map<String, FinanceStats> _ageStats = {};

  // 월별 비교 데이터 ✨ 추가
  List<MonthlySnapshot> _monthlySnapshots = [];
  final String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  int _totalUsers = 0;
  String _selectedView = 'total'; // total, gender, age, monthly ✨

  @override
  void initState() {
    super.initState();
    _loadFinanceStats();
    _loadMonthlySnapshots(); // ✨ 추가
  }

  /// 📊 금융 통계 로드
  Future<void> _loadFinanceStats() async {
    setState(() => _isLoading = true);

    try {
      // 1. 모든 사용자 데이터 가져오기
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      _totalUsers = usersSnapshot.docs.length;

      // 임시 통계 변수들
      final tempTotalStats = FinanceStats.empty();
      final tempMaleStats = FinanceStats.empty();
      final tempFemaleStats = FinanceStats.empty();
      final tempUnknownStats = FinanceStats.empty();
      final tempAgeStats = <String, FinanceStats>{
        '10대': FinanceStats.empty(),
        '20대': FinanceStats.empty(),
        '30대': FinanceStats.empty(),
        '40대': FinanceStats.empty(),
        '50대 이상': FinanceStats.empty(),
      };

      // 2. 각 사용자별로 데이터 집계
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();

        final gender = userData['gender'] as String?;
        final birthYear = userData['birthYear'] as int?;

        // 사용자의 금융 데이터 가져오기
        final userFinance = await _getUserFinanceData(userId);

        // 전체 통계에 합산
        tempTotalStats.add(userFinance);

        // 성별 통계에 합산
        if (gender == 'male') {
          tempMaleStats.add(userFinance);
        } else if (gender == 'female') {
          tempFemaleStats.add(userFinance);
        } else {
          tempUnknownStats.add(userFinance);
        }

        // 연령대별 통계에 합산
        if (birthYear != null) {
          final age = DateTime.now().year - birthYear;
          final ageGroup = _getAgeGroup(age);
          if (tempAgeStats.containsKey(ageGroup)) {
            tempAgeStats[ageGroup]!.add(userFinance);
          }
        }
      }

      setState(() {
        _totalStats = tempTotalStats;
        _maleStats = tempMaleStats;
        _femaleStats = tempFemaleStats;
        _unknownGenderStats = tempUnknownStats;
        _ageStats = tempAgeStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('❌ 통계 로드 실패: $e', Colors.red);
    }
  }

  /// 📅 월별 스냅샷 로드 ✨ 새로 추가
  Future<void> _loadMonthlySnapshots() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('monthly_stats')
          .orderBy('month', descending: true)
          .limit(12) // 최근 12개월
          .get();

      final snapshots = snapshot.docs.map((doc) {
        final data = doc.data();
        return MonthlySnapshot(
          month: doc.id,
          totalAssets: (data['totalAssets'] as num?)?.toDouble() ?? 0,
          totalInvestment: (data['totalInvestment'] as num?)?.toDouble() ?? 0,
          totalCurrentValue:
              (data['totalCurrentValue'] as num?)?.toDouble() ?? 0,
          totalBudget: (data['totalBudget'] as num?)?.toDouble() ?? 0,
          totalSpent: (data['totalSpent'] as num?)?.toDouble() ?? 0,
          userCount: (data['userCount'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      setState(() {
        _monthlySnapshots = snapshots;
      });
    } catch (e) {
      print('월별 스냅샷 로드 실패: $e');
    }
  }

  /// 💾 현재 통계를 월간 스냅샷으로 저장 ✨ 새로 추가
  Future<void> _saveMonthlySnapshot() async {
    try {
      final monthKey = DateFormat('yyyy-MM').format(DateTime.now());

      await FirebaseFirestore.instance
          .collection('monthly_stats')
          .doc(monthKey)
          .set({
            'month': monthKey,
            'totalAssets': _totalStats.totalAssets,
            'totalInvestment': _totalStats.totalInvestment,
            'totalCurrentValue': _totalStats.totalCurrentValue,
            'totalBudget': _totalStats.totalBudget,
            'totalSpent': _totalStats.totalSpent,
            'userCount': _totalStats.userCount,
            'savedAt': FieldValue.serverTimestamp(),
          });

      _showSnackBar('✅ 이번 달 스냅샷 저장 완료!', Colors.green);
      _loadMonthlySnapshots(); // 다시 로드
    } catch (e) {
      _showSnackBar('❌ 스냅샷 저장 실패: $e', Colors.red);
    }
  }

  /// 💰 사용자의 금융 데이터 가져오기
  Future<FinanceStats> _getUserFinanceData(String userId) async {
    final stats = FinanceStats.empty();

    try {
      // 1. 투자 데이터
      final investmentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('investments')
          .get();

      for (final doc in investmentsSnapshot.docs) {
        final data = doc.data();
        final investmentAmount =
            (data['investmentAmount'] as num?)?.toDouble() ?? 0;
        final currentValue = (data['currentValue'] as num?)?.toDouble() ?? 0;

        stats.totalInvestment += investmentAmount;
        stats.totalCurrentValue += currentValue;
      }

      // 2. 예산/지출 데이터
      final budgetSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .get();

      for (final doc in budgetSnapshot.docs) {
        final data = doc.data();
        final budget = (data['amount'] as num?)?.toDouble() ?? 0;
        final spent = (data['spent'] as num?)?.toDouble() ?? 0;

        stats.totalBudget += budget;
        stats.totalSpent += spent;
      }

      // 3. 자산 (총 자산 = 현재 투자 평가금액 + 현금)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final cash = (userData?['cash'] as num?)?.toDouble() ?? 0;
        stats.totalAssets = stats.totalCurrentValue + cash;
      }

      stats.userCount = 1;
    } catch (e) {
      print('사용자 $userId 데이터 로드 실패: $e');
    }

    return stats;
  }

  /// 📅 연령대 계산
  String _getAgeGroup(int age) {
    if (age < 20) return '10대';
    if (age < 30) return '20대';
    if (age < 40) return '30대';
    if (age < 50) return '40대';
    return '50대 이상';
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              '금융 데이터 분석 중...\n시간이 걸릴 수 있습니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFinanceStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💰 금융 통계',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '총 $_totalUsers명',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🎯 뷰 선택 탭 (4개로 확장) ✨
            Row(
              children: [
                Expanded(child: _buildViewTab('total', '전체', Icons.pie_chart)),
                const SizedBox(width: 8),
                Expanded(child: _buildViewTab('gender', '성별', Icons.people)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildViewTab('age', '연령대', Icons.calendar_today),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildViewTab('monthly', '월별', Icons.timeline), // ✨ 추가
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 📊 통계 내용
            if (_selectedView == 'total') _buildTotalStatsView(),
            if (_selectedView == 'gender') _buildGenderStatsView(),
            if (_selectedView == 'age') _buildAgeStatsView(),
            if (_selectedView == 'monthly') _buildMonthlyStatsView(), // ✨ 추가

            const SizedBox(height: 24),

            // 💾 스냅샷 저장 버튼 ✨ 추가
            if (_selectedView != 'monthly')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveMonthlySnapshot,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    '이번 달 스냅샷 저장',
                    style: TextStyle(fontFamily: 'Gmarket_sans'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // 🔄 새로고침 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadFinanceStats,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  '데이터 새로고침',
                  style: TextStyle(fontFamily: 'Gmarket_sans'),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 월별 통계 뷰 ✨ 새로 추가
  Widget _buildMonthlyStatsView() {
    if (_monthlySnapshots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '저장된 월별 데이터가 없습니다\n\n위의 "이번 달 스냅샷 저장" 버튼을 눌러\n데이터를 저장하세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 📈 월별 증감 그래프
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📈 월별 총 자산 추이',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ..._monthlySnapshots.asMap().entries.map((entry) {
                final index = entry.key;
                final snapshot = entry.value;
                final prevSnapshot = index < _monthlySnapshots.length - 1
                    ? _monthlySnapshots[index + 1]
                    : null;

                final change = prevSnapshot != null
                    ? snapshot.totalAssets - prevSnapshot.totalAssets
                    : 0.0;
                final changePercent =
                    prevSnapshot != null && prevSnapshot.totalAssets > 0
                    ? (change / prevSnapshot.totalAssets) * 100
                    : 0.0;

                return _buildMonthlyCard(
                  snapshot,
                  change,
                  changePercent,
                  index == 0, // 최신 데이터
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// 📊 월별 카드
  Widget _buildMonthlyCard(
    MonthlySnapshot snapshot,
    double change,
    double changePercent,
    bool isLatest,
  ) {
    final isPositive = change >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLatest ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLatest ? Colors.blue.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _formatMonth(snapshot.month),
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isLatest ? Colors.blue : Colors.black,
                    ),
                  ),
                  if (isLatest) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${snapshot.userCount}명',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 자산',
                style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 14),
              ),
              Text(
                _formatCurrency(snapshot.totalAssets),
                style: const TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (change != 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${_formatCurrency(change)} (${changePercent.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMiniStat('투자', snapshot.totalInvestment)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('예산', snapshot.totalBudget)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('지출', snapshot.totalSpent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatCurrency(value),
          style: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatMonth(String monthKey) {
    try {
      final parts = monthKey.split('-');
      return '${parts[0]}년 ${int.parse(parts[1])}월';
    } catch (e) {
      return monthKey;
    }
  }

  // ...existing code... (나머지 메서드들은 그대로 유지)

  /// 🎯 뷰 선택 탭 버튼
  Widget _buildViewTab(String view, String label, IconData icon) {
    final isSelected = _selectedView == view;
    return InkWell(
      onTap: () => setState(() => _selectedView = view),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📊 전체 통계 뷰
  Widget _buildTotalStatsView() {
    return Column(
      children: [_buildStatsCard('전체 사용자', _totalStats, Colors.blue)],
    );
  }

  /// 👥 성별 통계 뷰
  Widget _buildGenderStatsView() {
    return Column(
      children: [
        _buildStatsCard('남성', _maleStats, Colors.blue),
        const SizedBox(height: 16),
        _buildStatsCard('여성', _femaleStats, Colors.pink),
        const SizedBox(height: 16),
        _buildStatsCard('미설정', _unknownGenderStats, Colors.grey),
      ],
    );
  }

  /// 📅 연령대별 통계 뷰
  Widget _buildAgeStatsView() {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
    ];

    return Column(
      children: _ageStats.entries.map((entry) {
        final index = _ageStats.keys.toList().indexOf(entry.key);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildStatsCard(
            entry.key,
            entry.value,
            colors[index % colors.length],
          ),
        );
      }).toList(),
    );
  }

  /// 📊 통계 카드
  Widget _buildStatsCard(String title, FinanceStats stats, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.userCount}명',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 통계 데이터
          _buildStatRow(
            '💎 총 자산',
            stats.totalAssets,
            Icons.account_balance_wallet,
            color,
          ),
          const Divider(height: 24),
          _buildStatRow(
            '📈 총 투자금액',
            stats.totalInvestment,
            Icons.trending_up,
            Colors.blue,
          ),
          const Divider(height: 24),
          _buildStatRow(
            '💰 총 평가금액',
            stats.totalCurrentValue,
            Icons.attach_money,
            Colors.green,
          ),
          const Divider(height: 24),
          _buildStatRow(
            '📊 수익/손실',
            stats.totalCurrentValue - stats.totalInvestment,
            Icons.assessment,
            stats.totalCurrentValue >= stats.totalInvestment
                ? Colors.green
                : Colors.red,
          ),
          const Divider(height: 24),
          _buildStatRow(
            '💳 총 예산',
            stats.totalBudget,
            Icons.credit_card,
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildStatRow(
            '🛒 총 지출',
            stats.totalSpent,
            Icons.shopping_cart,
            Colors.red,
          ),
          const Divider(height: 24),
          _buildStatRow(
            '💵 남은 예산',
            stats.totalBudget - stats.totalSpent,
            Icons.savings,
            Colors.purple,
          ),

          // 평균 정보
          if (stats.userCount > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 1인당 평균',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAverageRow(
                    '평균 자산',
                    stats.totalAssets / stats.userCount,
                  ),
                  _buildAverageRow(
                    '평균 투자',
                    stats.totalInvestment / stats.userCount,
                  ),
                  _buildAverageRow(
                    '평균 예산',
                    stats.totalBudget / stats.userCount,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAverageRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(1)}억원';
    } else if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만원';
    } else {
      return '${amount.toStringAsFixed(0)}원';
    }
  }
}

// 📊 금융 통계 데이터 모델
class FinanceStats {
  int userCount = 0;
  double totalAssets = 0;
  double totalInvestment = 0;
  double totalCurrentValue = 0;
  double totalBudget = 0;
  double totalSpent = 0;

  FinanceStats.empty();

  void add(FinanceStats other) {
    userCount += other.userCount;
    totalAssets += other.totalAssets;
    totalInvestment += other.totalInvestment;
    totalCurrentValue += other.totalCurrentValue;
    totalBudget += other.totalBudget;
    totalSpent += other.totalSpent;
  }
}

// 📅 월별 스냅샷 모델 ✨ 추가
class MonthlySnapshot {
  final String month; // "2024-12"
  final double totalAssets;
  final double totalInvestment;
  final double totalCurrentValue;
  final double totalBudget;
  final double totalSpent;
  final int userCount;

  MonthlySnapshot({
    required this.month,
    required this.totalAssets,
    required this.totalInvestment,
    required this.totalCurrentValue,
    required this.totalBudget,
    required this.totalSpent,
    required this.userCount,
  });
}
