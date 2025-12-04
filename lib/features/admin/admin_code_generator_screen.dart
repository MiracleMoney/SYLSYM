// lib/features/admin/admin_code_generator_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/invite_code_generator.dart';
import '../../models/invite_code.dart';
import 'admin_password_dialog.dart'; // AdminAuth 사용
import 'admin_code_list_screen.dart';

class AdminCodeGeneratorScreen extends StatefulWidget {
  const AdminCodeGeneratorScreen({super.key});

  @override
  State<AdminCodeGeneratorScreen> createState() =>
      _AdminCodeGeneratorScreenState();
}

class _AdminCodeGeneratorScreenState extends State<AdminCodeGeneratorScreen> {
  final InviteCodeGenerator _generator = InviteCodeGenerator();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _maxUsageController = TextEditingController(
    text: '1',
  );
  final TextEditingController _descriptionController = TextEditingController();

  List<InviteCode> _generatedCodes = [];
  bool _isLoading = false;
  String _progressText = '';

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  /// 🔐 관리자 권한 확인 (이메일만 체크)
  void _checkAdminAccess() {
    if (!AdminAuth.isAdmin()) {
      // 관리자가 아니면 즉시 화면 닫기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAccessDeniedDialog();
        }
      });
    }
  }

  /// ❌ 접근 거부 다이얼로그
  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.block, color: Colors.red, size: 32),
            SizedBox(width: 8),
            Text(
              '접근 거부',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '관리자 권한이 없습니다.',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '현재 로그인: ${AdminAuth.getAdminEmail() ?? "로그인 안됨"}',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '관리자 이메일로 로그인 후 다시 시도해주세요.',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 관리자 화면 닫기
            },
            child: const Text(
              '확인',
              style: TextStyle(fontFamily: 'Gmarket_sans'),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎫 대량 코드 생성
  Future<void> _generateBulkCodes() async {
    final count = int.tryParse(_countController.text) ?? 0;
    final maxUsage = int.tryParse(_maxUsageController.text) ?? 1;
    final description = _descriptionController.text.trim();

    // 입력 검증
    if (count <= 0 || count > 1000) {
      _showSnackBar('⚠️ 생성 개수는 1~1000 사이로 입력해주세요', Colors.orange);
      return;
    }

    if (maxUsage <= 0) {
      _showSnackBar('⚠️ 사용 횟수는 1 이상이어야 합니다', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
      _progressText = '생성 준비 중...';
      _generatedCodes = [];
    });

    try {
      final codes = await _generator.generateBulkCodes(
        count: count,
        maxUsage: maxUsage,
        description: description.isEmpty ? null : description,
        onProgress: (current, total) {
          if (mounted) {
            setState(() {
              _progressText = '생성 중: $current / $total';
            });
          }
        },
      );

      setState(() {
        _generatedCodes = codes;
        _isLoading = false;
        _progressText = '';
      });

      _showSnackBar('✅ ${codes.length}개 코드 생성 완료!', Colors.green);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('❌ 생성 실패: $e', Colors.red);
    }
  }

  /// 📋 전체 코드 복사 (텍스트)
  void _copyAllCodesAsText() {
    if (_generatedCodes.isEmpty) return;

    final text = _generatedCodes.map((code) => code.code).join('\n');
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('📋 ${_generatedCodes.length}개 코드 복사 완료!', Colors.blue);
  }

  /// 📊 CSV 형식으로 복사 (엑셀용)
  void _copyAllCodesAsCSV() {
    if (_generatedCodes.isEmpty) return;

    // CSV 헤더
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('코드,최대사용횟수,현재사용횟수,생성일,설명');

    // CSV 데이터
    for (final code in _generatedCodes) {
      csvBuffer.writeln(
        '${code.code},${code.maxUsage},${code.usageCount},'
        '${code.createdAt.toString().substring(0, 16)},'
        '"${code.description ?? ''}"',
      );
    }

    Clipboard.setData(ClipboardData(text: csvBuffer.toString()));
    _showSnackBar('📊 CSV 형식으로 복사 완료!\n엑셀에 붙여넣으세요', Colors.green);
  }

  /// 📧 이메일 발송 안내 표시
  void _showEmailGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '📧 이메일 발송 가이드',
          style: TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '1. 코드를 CSV로 복사',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('   → "CSV 복사" 버튼 클릭\n'),
              Text(
                '2. 엑셀에 붙여넣기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('   → Excel 열기 → Ctrl+V\n'),
              Text(
                '3. 이메일 주소 열 추가',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('   → B열에 각 수신자 이메일 입력\n'),
              Text(
                '4. Gmail 또는 Outlook 사용',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('   → 메일 머지 기능 사용\n'),
              Text(
                '💡 팁',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Text(
                '   - Gmail: "mail merge" 확장 프로그램 사용\n'
                '   - Outlook: "편지 병합" 기능 사용\n'
                '   - 네이버 메일: "대량 발송" 기능',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 관리자가 아니면 빈 화면 (다이얼로그가 뜰 것)
    if (!AdminAuth.isAdmin()) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🔐 초대 코드 생성기',
          style: TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminCodeListScreen(),
                ),
              );
            },
            tooltip: '코드 목록',
          ),
          // 현재 관리자 이메일 표시
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                AdminAuth.getAdminEmail() ?? '',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 안내 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '🔐 8자리 무작위 코드 생성',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('✅ 중복 자동 방지'),
                  Text('✅ 혼동 문자 제외 (I, O, 0, 1)'),
                  Text('✅ CSV 형식 엑셀 복사'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 생성 개수 입력
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '생성 개수 (최대 1000개)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
                hintText: '예: 100',
              ),
            ),
            const SizedBox(height: 16),

            // 1인당 사용 횟수
            TextField(
              controller: _maxUsageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '1인당 사용 횟수',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: '1 = 1명만 사용 가능',
              ),
            ),
            const SizedBox(height: 16),

            // 설명 입력
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                hintText: '예: 1월 프로모션용',
              ),
            ),
            const SizedBox(height: 24),

            // 생성 버튼
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateBulkCodes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.auto_awesome),
              label: const Text(
                '코드 생성',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // 진행 상황
            if (_isLoading) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(
                    _progressText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // 생성된 코드 목록
            if (_generatedCodes.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '생성된 코드 (${_generatedCodes.length}개)',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showEmailGuide,
                        icon: const Icon(Icons.help_outline),
                        tooltip: '이메일 발송 가이드',
                      ),
                      TextButton.icon(
                        onPressed: _copyAllCodesAsCSV,
                        icon: const Icon(Icons.table_chart),
                        label: const Text('CSV 복사'),
                      ),
                      TextButton.icon(
                        onPressed: _copyAllCodesAsText,
                        icon: const Icon(Icons.copy_all),
                        label: const Text('텍스트 복사'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    itemCount: _generatedCodes.length,
                    itemBuilder: (context, index) {
                      final code = _generatedCodes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            code.code,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          subtitle: Text(
                            code.description ?? '설명 없음',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: code.code));
                              _showSnackBar('📋 ${code.code} 복사됨', Colors.blue);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    _maxUsageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
