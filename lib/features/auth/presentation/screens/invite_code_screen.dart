import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/auth/data/auth_service.dart';
import 'package:miraclemoney/features/auth/presentation/screens/user_info_screen.dart';
import 'package:miraclemoney/shared/widgets/google_form_button.dart';

class InviteCodeScreen extends StatefulWidget {
  const InviteCodeScreen({super.key});

  @override
  State<InviteCodeScreen> createState() => _InviteCodeScreenState();
}

class _InviteCodeScreenState extends State<InviteCodeScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  /// 🎫 초대코드 검증 (✨ 여기를 수정)
  Future<void> _verifyInviteCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      _showSnackBar('초대코드를 입력해주세요', Colors.orange);
      return;
    }

    if (code.length != 8) {
      _showSnackBar('초대코드는 8자리입니다', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyAndSaveInviteCode(code);

      if (mounted) {
        // ✨ 성공 시 UserInfoScreen으로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const UserInfoScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(
        '❌ ${e.toString().replaceAll('Exception: ', '')}',
        Colors.red,
      );
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  Future<void> _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('로그아웃', style: TextStyle(fontFamily: 'Gmarket_sans')),
        content: const Text(
          '로그인을 취소하시겠습니까?\n초대코드는 나중에 입력할 수 있습니다.',
          style: TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          // 로그아웃 후 Navigator를 초기화하여 로그인 화면으로 이동
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그아웃 실패: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _showLogoutDialog,
            tooltip: '로그아웃',
          ),
          title: const Text('초대코드 입력'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(Sizes.size24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 정보
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    Gaps.v12,
                    Text(
                      user?.displayName ?? '사용자',
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: Sizes.size16 + Sizes.size2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Gaps.v4,
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Gaps.v40,

              // 제목
              const Text(
                '초대코드를 입력하세요',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: Sizes.size24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Gaps.v8,
              Text(
                '멤버십 활성화를 위해 초대코드가 필요합니다',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: Sizes.size14,
                  color: Colors.grey.shade600,
                ),
              ),
              Gaps.v24,

              // ✨ 초대코드 입력 (salary_step1 스타일)
              TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                autofocus: true,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'ABC12345',
                  hintStyle: TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.grey.shade400,
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  // ✨ salary_step1과 동일한 border 스타일
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 12,
                  ),
                  suffixIcon: _codeController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _codeController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  counterText: '',
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: Sizes.size20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  // 자동 대문자 변환
                  if (value != value.toUpperCase()) {
                    _codeController.value = _codeController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  }
                  setState(() {});
                },
                onSubmitted: (_) => _verifyInviteCode(),
              ),
              Gaps.v32,

              // ✨ 확인 버튼 (salary_step1과 동일한 색상)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyInviteCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // ✨ salary_step1과 동일
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              '확인',
                              style: TextStyle(
                                fontFamily: 'Gmarket_sans',
                                fontSize: Sizes.size16 + 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              Gaps.v16,
              // ✨ "코드 없이 사용" 및 "코드 신청하기" 버튼
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/demo_salary_step1',
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '코드 없이 사용',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Sizes.size16),
                  GoogleFormButton(
                    label: '코드 신청',
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                    borderRadius: 8,
                  ),
                ],
              ),
              Gaps.v16,

              // 도움말
              Container(
                padding: const EdgeInsets.all(Sizes.size16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          size: 20,
                          color: Colors.grey.shade600,
                        ),
                        Gaps.v8,
                        Text(
                          '초대코드를 받지 못하셨나요?',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: Sizes.size12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Gaps.v8,
                    Text(
                      '• 이메일을 확인해주세요\n'
                      '• 스팸 폴더도 확인해보세요\n'
                      '• 구글폼으로 신청을 했는지 확인해주세요',

                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: Sizes.size12,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }
}
