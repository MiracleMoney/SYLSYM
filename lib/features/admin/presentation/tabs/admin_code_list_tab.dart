import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/invite_code_generator.dart';
import '../../../../data/models/invite_code/invite_code.dart';

class AdminCodeListTab extends StatefulWidget {
  const AdminCodeListTab({super.key});

  @override
  State<AdminCodeListTab> createState() => _AdminCodeListTabState();
}

class _AdminCodeListTabState extends State<AdminCodeListTab> {
  final InviteCodeGenerator _generator = InviteCodeGenerator();
  List<InviteCode> _codes = [];
  List<InviteCode> _filteredCodes = [];
  bool _isLoading = true;
  String _filterStatus =
      'all'; // all, active, inactive, used, unused, unconfirmed ✨
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  /// 📋 코드 목록 로드
  Future<void> _loadCodes() async {
    setState(() => _isLoading = true);

    try {
      final codes = await _generator.getAllCodes();
      setState(() {
        _codes = codes;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('❌ 코드 로드 실패: $e', Colors.red);
    }
  }

  /// 🔍 필터 적용
  void _applyFilter() {
    var filtered = _codes;

    // 상태 필터
    switch (_filterStatus) {
      case 'active':
        filtered = filtered.where((c) => c.isActive).toList();
        break;
      case 'inactive':
        filtered = filtered.where((c) => !c.isActive).toList();
        break;
      case 'used':
        filtered = filtered.where((c) => c.usageCount >= c.maxUsage).toList();
        break;
      case 'unused':
        filtered = filtered.where((c) => c.usageCount < c.maxUsage).toList();
        break;
      case 'unconfirmed': // ✨ 미확인 필터 추가
        filtered = filtered.where((c) => c.isConfirmed == false).toList();
        break;
    }

    // 검색어 필터
    final searchText = _searchController.text.trim().toLowerCase();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((code) {
        return code.code.toLowerCase().contains(searchText) ||
            (code.description?.toLowerCase().contains(searchText) ?? false);
      }).toList();
    }

    setState(() => _filteredCodes = filtered);
  }

  /// ✅ 코드를 확인됨으로 표시 ✨
  Future<void> _markAsConfirmed(List<InviteCode> codes) async {
    try {
      await _generator.markCodesAsConfirmed(codes);
      _showSnackBar('✅ ${codes.length}개 코드 확인 완료!', Colors.green);
      _loadCodes();
    } catch (e) {
      _showSnackBar('❌ 처리 실패: $e', Colors.red);
    }
  }

  /// 🔄 코드 활성/비활성 토글
  Future<void> _toggleCodeActive(InviteCode code) async {
    try {
      await _generator.toggleCodeActive(code.code);
      _showSnackBar(
        code.isActive ? '❌ 코드 비활성화됨' : '✅ 코드 활성화됨',
        code.isActive ? Colors.orange : Colors.green,
      );
      _loadCodes();
    } catch (e) {
      _showSnackBar('❌ 상태 변경 실패: $e', Colors.red);
    }
  }

  /// 🗑️ 코드 삭제
  Future<void> _deleteCode(InviteCode code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('코드 삭제'),
        content: Text('${code.code} 코드를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _generator.deleteCode(code.code);
        _showSnackBar('🗑️ 코드 삭제됨', Colors.grey);
        _loadCodes();
      } catch (e) {
        _showSnackBar('❌ 삭제 실패: $e', Colors.red);
      }
    }
  }

  /// 📋 코드 복사
  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    _showSnackBar('📋 $code 복사됨', Colors.blue);
  }

  /// 📋 미확인 코드 텍스트 복사 ✨
  void _copyUnconfirmedAsText() {
    final unconfirmedCodes = _codes
        .where((c) => c.isConfirmed == false)
        .toList();

    if (unconfirmedCodes.isEmpty) {
      _showSnackBar('⚠️ 미확인 코드가 없습니다', Colors.orange);
      return;
    }

    final text = unconfirmedCodes.map((code) => code.code).join('\n');
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('📋 ${unconfirmedCodes.length}개 미확인 코드 복사 완료!', Colors.green);
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

    // ✨ 미확인 코드 개수 계산
    final unconfirmedCount = _codes.where((c) => c.isConfirmed == false).length;

    return Column(
      children: [
        // ✨ 미확인 코드 알림 배너
        if (unconfirmedCount > 0)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange.shade50,
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '⚠️ 미확인 코드 $unconfirmedCount개',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterStatus = 'unconfirmed';
                      _applyFilter();
                    });
                  },
                  child: const Text('보기'),
                ),
              ],
            ),
          ),

        // 검색 및 필터
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey.shade50,
          child: Column(
            children: [
              // 검색창
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '코드 또는 설명 검색...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => _applyFilter(),
              ),
              const SizedBox(height: 12),

              // 필터 버튼
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('전체', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      '미확인 ⚠️',
                      'unconfirmed',
                      unconfirmedCount,
                    ), // ✨
                    const SizedBox(width: 8),
                    _buildFilterChip('활성', 'active'),
                    const SizedBox(width: 8),
                    _buildFilterChip('비활성', 'inactive'),
                    const SizedBox(width: 8),
                    _buildFilterChip('사용됨', 'used'),
                    const SizedBox(width: 8),
                    _buildFilterChip('미사용', 'unused'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 결과 개수
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.blue.shade50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${_filteredCodes.length}개',
                style: const TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // ✨ CSV 복사 버튼 (미확인 필터일 때만)
                  if (_filterStatus == 'unconfirmed' &&
                      _filteredCodes.isNotEmpty)
                    TextButton.icon(
                      onPressed: _copyUnconfirmedAsText,
                      icon: const Icon(Icons.table_chart, size: 18),
                      label: const Text('텍스트 복사'),
                    ),
                  TextButton.icon(
                    onPressed: _loadCodes,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('새로고침'),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 코드 목록
        Expanded(
          child: _filteredCodes.isEmpty
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
                        _filterStatus == 'unconfirmed'
                            ? '미확인 코드가 없습니다 ✅'
                            : '검색 결과가 없습니다',
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
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredCodes.length,
                  itemBuilder: (context, index) {
                    final code = _filteredCodes[index];
                    final isUsed = code.usageCount >= code.maxUsage;
                    final isUnconfirmed = code.isConfirmed == false; // ✨

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      // ✨ 미확인 코드 강조
                      color: isUnconfirmed
                          ? Colors.orange.shade50
                          : Colors.white,
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isUnconfirmed
                                ? Colors
                                      .orange // ✨ 미확인
                                : code.isActive
                                ? (isUsed ? Colors.green : Colors.blue)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isUnconfirmed
                                ? Icons
                                      .warning_amber // ✨
                                : code.isActive
                                ? (isUsed ? Icons.check : Icons.pending)
                                : Icons.block,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              code.code,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            // ✨ 미확인 뱃지
                            if (isUnconfirmed) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '미확인',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              code.description ?? '설명 없음',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '사용: ${code.usageCount}/${code.maxUsage}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              onTap: () => _copyCode(code.code),
                              child: const Row(
                                children: [
                                  Icon(Icons.copy, size: 20),
                                  SizedBox(width: 8),
                                  Text('복사'),
                                ],
                              ),
                            ),
                            // ✨ 확인 완료 처리 메뉴
                            if (isUnconfirmed)
                              PopupMenuItem(
                                onTap: () => _markAsConfirmed([code]),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 8),
                                    Text('확인 완료'),
                                  ],
                                ),
                              ),
                            PopupMenuItem(
                              onTap: () => _toggleCodeActive(code),
                              child: Row(
                                children: [
                                  Icon(
                                    code.isActive ? Icons.block : Icons.check,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(code.isActive ? '비활성화' : '활성화'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () => _deleteCode(code),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '삭제',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ✨ 일괄 확인 완료 버튼 (미확인 필터일 때만)
        if (_filterStatus == 'unconfirmed' && _filteredCodes.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markAsConfirmed(_filteredCodes),
                icon: const Icon(Icons.check_circle),
                label: Text('전체 확인 완료 (${_filteredCodes.length}개)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, [int? count]) {
    final isSelected = _filterStatus == value;
    return FilterChip(
      label: Text(count != null && count > 0 ? '$label ($count)' : label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = value;
          _applyFilter();
        });
      },
      selectedColor: value == 'unconfirmed' ? Colors.orange : Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontFamily: 'Gmarket_sans',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
