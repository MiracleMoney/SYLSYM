import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/invite_code_generator.dart';
import '../../../../data/models/invite_code/invite_code.dart';

class AdminCodeGeneratorTab extends StatefulWidget {
  const AdminCodeGeneratorTab({super.key});

  @override
  State<AdminCodeGeneratorTab> createState() => _AdminCodeGeneratorTabState();
}

class _AdminCodeGeneratorTabState extends State<AdminCodeGeneratorTab> {
  final InviteCodeGenerator _generator = InviteCodeGenerator();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _maxUsageController = TextEditingController(
    text: '1',
  );
  final TextEditingController _descriptionController = TextEditingController();

  List<InviteCode> _generatedCodes = [];
  bool _isLoading = false;
  String _progressText = '';
  bool _isCodesConfirmed = false; // ✨ 코드 복사 완료 여부

  @override
  void initState() {
    super.initState();
    _loadUnconfirmedCodes(); // ✨ 저장된 코드 불러오기
  }

  /// 💾 미확인 코드 불러오기 ✨
  Future<void> _loadUnconfirmedCodes() async {
    try {
      final codes = await _generator.getUnconfirmedCodes();
      if (codes.isNotEmpty) {
        setState(() {
          _generatedCodes = codes;
          _isCodesConfirmed = false;
        });
      }
    } catch (e) {
      print('코드 로드 실패: $e');
    }
  }

  /// 🎫 대량 코드 생성
  Future<void> _generateBulkCodes() async {
    final count = int.tryParse(_countController.text) ?? 0;
    final maxUsage = int.tryParse(_maxUsageController.text) ?? 1;
    final description = _descriptionController.text.trim();

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
      _isCodesConfirmed = false;
    });

    try {
      final codes = await _generator.generateBulkCodes(
        count: count,
        maxUsage: maxUsage,
        description: description.isEmpty ? null : description,
        markAsUnconfirmed: true, // ✨ 미확인 상태로 저장
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

  /// ✅ 복사 완료 처리 ✨
  Future<void> _confirmCodes() async {
    try {
      await _generator.markCodesAsConfirmed(_generatedCodes);
      setState(() {
        _isCodesConfirmed = true;
      });
      _showSnackBar('✅ 코드 복사 완료 처리됨!', Colors.green);
    } catch (e) {
      _showSnackBar('❌ 처리 실패: $e', Colors.red);
    }
  }

  /// 🗑️ 코드 목록 초기화 ✨
  void _clearCodes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('코드 목록 초기화'),
        content: const Text(
          '생성된 코드 목록을 삭제하시겠습니까?\n\n(Firestore의 코드는 삭제되지 않습니다)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _generatedCodes = [];
                _isCodesConfirmed = false;
              });
              _showSnackBar('🗑️ 코드 목록 초기화 완료', Colors.grey);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('코드,최대사용횟수,현재사용횟수,생성일,설명');

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
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
    return SingleChildScrollView(
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🔐 8자리 무작위 코드 생성',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('✅ 중복 자동 방지'),
                Text('✅ 혼동 문자 제외 (I, O, 0, 1)'),
                Text('✅ CSV 형식 엑셀 복사'),
                Text(
                  '✅ 페이지 이동 시에도 유지',
                  style: TextStyle(color: Colors.blue),
                ), // ✨
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
            // ✨ 상태 표시 배너
            if (!_isCodesConfirmed)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '⚠️ 코드를 복사한 후 "복사 완료" 버튼을 눌러주세요',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 헤더
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
                IconButton(
                  onPressed: _showEmailGuide,
                  icon: const Icon(Icons.help_outline),
                  tooltip: '이메일 발송 가이드',
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ✨ 버튼 그룹 (UI 오버플로우 해결)
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyAllCodesAsText,
                        icon: const Icon(Icons.copy_all, size: 18),
                        label: const Text('텍스트 복사'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _copyAllCodesAsCSV,
                        icon: const Icon(Icons.table_chart, size: 18),
                        label: const Text('CSV 복사'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isCodesConfirmed ? null : _confirmCodes,
                        icon: Icon(
                          _isCodesConfirmed ? Icons.check_circle : Icons.check,
                          size: 18,
                        ),
                        label: Text(_isCodesConfirmed ? '복사 완료됨' : '복사 완료'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCodesConfirmed
                              ? Colors.grey
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _clearCodes,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('목록 지우기'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 코드 목록
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SizedBox(
                height: 400,
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
