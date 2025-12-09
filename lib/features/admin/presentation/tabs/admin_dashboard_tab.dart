import 'package:flutter/material.dart';
import '../../../../data/services/invite_code_generator.dart';
import '../../../../data/models/invite_code/invite_code.dart';

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final InviteCodeGenerator _generator = InviteCodeGenerator();
  bool _isLoading = true;

  // 통계 데이터
  int _totalCodes = 0;
  int _activeCodes = 0;
  int _inactiveCodes = 0;
  int _usedCodes = 0;
  int _unusedCodes = 0;
  int _totalUsageCount = 0;
  int _totalMaxUsage = 0;
  List<InviteCode> _recentCodes = [];
  Map<String, int> _codesByMonth = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// 📊 대시보드 데이터 로드
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final codes = await _generator.getAllCodes();

      // 기본 통계
      _totalCodes = codes.length;
      _activeCodes = codes.where((c) => c.isActive).length;
      _inactiveCodes = codes.where((c) => !c.isActive).length;
      _usedCodes = codes.where((c) => c.usageCount >= c.maxUsage).length;
      _unusedCodes = codes
          .where((c) => c.usageCount < c.maxUsage && c.isActive)
          .length;

      // 사용 통계
      _totalUsageCount = codes.fold(0, (sum, code) => sum + code.usageCount);
      _totalMaxUsage = codes.fold(0, (sum, code) => sum + code.maxUsage);

      // 최근 생성된 코드 (상위 5개)
      _recentCodes = codes.take(5).toList();

      // 월별 생성 통계 (최근 6개월)
      _codesByMonth = {};
      final now = DateTime.now();
      for (int i = 5; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        final monthKey =
            '${month.year}-${month.month.toString().padLeft(2, '0')}';
        _codesByMonth[monthKey] = codes.where((code) {
          return code.createdAt.year == month.year &&
              code.createdAt.month == month.month;
        }).length;
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('❌ 데이터 로드 실패: $e', Colors.red);
    }
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
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
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
                  '📊 전체 통계',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🎯 주요 지표 카드들
            Row(
              children: [
                Expanded(
                  child: _buildMainStatCard(
                    '전체 코드',
                    _totalCodes.toString(),
                    Icons.qr_code_2,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMainStatCard(
                    '활성 코드',
                    _activeCodes.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMainStatCard(
                    '사용됨',
                    _usedCodes.toString(),
                    Icons.done_all,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMainStatCard(
                    '미사용',
                    _unusedCodes.toString(),
                    Icons.pending,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 📈 사용률 통계
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 전체 사용률',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_totalUsageCount / $_totalMaxUsage',
                        style: const TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_totalMaxUsage > 0 ? ((_totalUsageCount / _totalMaxUsage) * 100).toStringAsFixed(1) : 0}%',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalMaxUsage > 0
                          ? _totalUsageCount / _totalMaxUsage
                          : 0,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '총 $_totalUsageCount명이 초대 코드를 사용했습니다',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 📅 월별 생성 통계
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📅 월별 생성 현황 (최근 6개월)',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_codesByMonth.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '데이터가 없습니다',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._codesByMonth.entries.map((entry) {
                      final maxValue = _codesByMonth.values.isEmpty
                          ? 1
                          : _codesByMonth.values.reduce(
                              (a, b) => a > b ? a : b,
                            );
                      final percentage = maxValue > 0 && entry.value > 0
                          ? entry.value / maxValue
                          : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatMonth(entry.key),
                                  style: const TextStyle(
                                    fontFamily: 'Gmarket_sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${entry.value}개',
                                  style: const TextStyle(
                                    fontFamily: 'Gmarket_sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.green.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🕐 최근 생성된 코드
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🕐 최근 생성된 코드',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_recentCodes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          '생성된 코드가 없습니다',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentCodes.map((code) {
                      final isUsed = code.usageCount >= code.maxUsage;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isUsed ? Colors.green : Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isUsed ? Icons.check : Icons.pending,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    code.code,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    code.description ?? '설명 없음',
                                    style: TextStyle(
                                      fontFamily: 'Gmarket_sans',
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${code.usageCount}/${code.maxUsage}',
                                  style: const TextStyle(
                                    fontFamily: 'Gmarket_sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatDateTime(code.createdAt),
                                  style: TextStyle(
                                    fontFamily: 'Gmarket_sans',
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🔄 새로고침 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  '새로고침',
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

  /// 📊 주요 통계 카드
  Widget _buildMainStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  String _formatMonth(String monthKey) {
    final parts = monthKey.split('-');
    return '${parts[0]}년 ${int.parse(parts[1])}월';
  }

  String _formatDateTime(DateTime date) {
    return '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
