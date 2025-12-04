// lib/features/admin/admin_code_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/invite_code.dart';
import '../../services/invite_code_generator.dart';

class AdminCodeListScreen extends StatefulWidget {
  const AdminCodeListScreen({super.key});

  @override
  State<AdminCodeListScreen> createState() => _AdminCodeListScreenState();
}

class _AdminCodeListScreenState extends State<AdminCodeListScreen> {
  final InviteCodeGenerator _generator = InviteCodeGenerator();
  final TextEditingController _searchController = TextEditingController();

  List<InviteCode> _allCodes = [];
  List<InviteCode> _filteredCodes = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // all, used, unused

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  /// 📥 Firestore에서 모든 코드 불러오기
  Future<void> _loadCodes() async {
    setState(() => _isLoading = true);

    try {
      final codes = await _generator.getAllCodes();
      setState(() {
        _allCodes = codes;
        _filteredCodes = codes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('❌ 코드 불러오기 실패: $e', Colors.red);
    }
  }

  /// 🔍 검색 필터링
  void _filterCodes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCodes = _allCodes;
      } else {
        _filteredCodes = _allCodes
            .where(
              (code) =>
                  code.code.toLowerCase().contains(query.toLowerCase()) ||
                  (code.description?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }
      _applyStatusFilter();
    });
  }

  /// 📊 상태별 필터링 (전체/사용됨/미사용)
  void _applyStatusFilter() {
    setState(() {
      switch (_filterStatus) {
        case 'used':
          _filteredCodes = _filteredCodes
              .where((code) => code.usageCount >= code.maxUsage)
              .toList();
          break;
        case 'unused':
          _filteredCodes = _filteredCodes
              .where((code) => code.usageCount < code.maxUsage)
              .toList();
          break;
        case 'all':
        default:
          // 이미 _filteredCodes에 반영됨
          break;
      }
    });
  }

  /// 🗑️ 코드 비활성화
  Future<void> _deactivateCode(InviteCode code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '코드 비활성화',
          style: TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        content: Text(
          '${code.code} 코드를 비활성화하시겠습니까?\n\n이 코드는 더 이상 사용할 수 없습니다.',
          style: const TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('비활성화'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _generator.deactivateCode(code.code);
        _showSnackBar('✅ ${code.code} 비활성화 완료', Colors.green);
        _loadCodes(); // 목록 새로고침
      } catch (e) {
        _showSnackBar('❌ 비활성화 실패: $e', Colors.red);
      }
    }
  }

  /// 📋 코드 복사
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('📋 $code 복사 완료', Colors.blue);
  }

  /// 📊 통계 계산
  Map<String, int> _getStatistics() {
    final total = _allCodes.length;
    final used = _allCodes.where((c) => c.usageCount >= c.maxUsage).length;
    final unused = total - used;
    final inactive = _allCodes.where((c) => !c.isActive).length;

    return {
      'total': total,
      'used': used,
      'unused': unused,
      'inactive': inactive,
    };
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📊 초대 코드 관리',
          style: TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCodes,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: Column(
        children: [
          // 📊 통계 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('전체', stats['total']!, Colors.blue),
                    _buildStatItem('사용됨', stats['used']!, Colors.green),
                    _buildStatItem('미사용', stats['unused']!, Colors.orange),
                    _buildStatItem('비활성', stats['inactive']!, Colors.red),
                  ],
                ),
                const SizedBox(height: 16),
                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: stats['total']! > 0
                        ? stats['used']! / stats['total']!
                        : 0,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '사용률: ${stats['total']! > 0 ? ((stats['used']! / stats['total']!) * 100).toStringAsFixed(1) : 0}%',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // 🔍 검색 & 필터
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 검색창
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '코드 또는 설명 검색',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterCodes('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterCodes,
                ),
                const SizedBox(height: 12),
                // 상태 필터 버튼
                Row(
                  children: [
                    _buildFilterChip('전체', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('사용됨', 'used'),
                    const SizedBox(width: 8),
                    _buildFilterChip('미사용', 'unused'),
                  ],
                ),
              ],
            ),
          ),

          // 📋 코드 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCodes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '코드가 없습니다',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCodes.length,
                    itemBuilder: (context, index) {
                      final code = _filteredCodes[index];
                      return _buildCodeCard(code);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 📊 통계 아이템 위젯
  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// 🔘 필터 칩 위젯
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
          _filterCodes(_searchController.text);
        });
      },
      selectedColor: Colors.black,
      labelStyle: TextStyle(
        fontFamily: 'Gmarket_sans',
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// 🎫 코드 카드 위젯
  Widget _buildCodeCard(InviteCode code) {
    final isUsed = code.usageCount >= code.maxUsage;
    final isExpired =
        code.expiresAt != null && DateTime.now().isAfter(code.expiresAt!);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _copyCode(code.code),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 코드 & 상태
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 코드
                  Expanded(
                    child: Text(
                      code.code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  // 상태 배지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: !code.isActive
                          ? Colors.grey
                          : isUsed
                          ? Colors.green
                          : isExpired
                          ? Colors.red
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      !code.isActive
                          ? '비활성'
                          : isUsed
                          ? '사용완료'
                          : isExpired
                          ? '만료'
                          : '미사용',
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 사용 현황
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '사용: ${code.usageCount}/${code.maxUsage}',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '생성: ${_formatDate(code.createdAt)}',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              // 설명
              if (code.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  code.description!,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              // 만료일
              if (code.expiresAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isExpired ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '만료: ${_formatDate(code.expiresAt!)}',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 12,
                        color: isExpired ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],

              // 버튼들
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyCode(code.code),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text(
                        '복사',
                        style: TextStyle(fontFamily: 'Gmarket_sans'),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (code.isActive)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deactivateCode(code),
                        icon: const Icon(Icons.block, size: 16),
                        label: const Text(
                          '비활성화',
                          style: TextStyle(fontFamily: 'Gmarket_sans'),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 날짜 포맷
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
