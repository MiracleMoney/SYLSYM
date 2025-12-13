import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/auth/presentation/screens/terms_viewer_screen.dart';
import 'package:miraclemoney/features/auth/presentation/screens/invite_code_screen.dart';

/// 약관 동의 화면
class TermsAgreementScreen extends StatefulWidget {
  const TermsAgreementScreen({super.key});

  @override
  State<TermsAgreementScreen> createState() => _TermsAgreementScreenState();
}

class _TermsAgreementScreenState extends State<TermsAgreementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _privacyPolicyAgreed = false;
  bool _termsOfServiceAgreed = false;
  bool _thirdPartyInfoAgreed = false;
  bool _isLoading = false;

  bool get _allAgreed =>
      _privacyPolicyAgreed && _termsOfServiceAgreed && _thirdPartyInfoAgreed;

  /// 약관 동의 저장
  Future<void> _saveAgreement() async {
    if (!_allAgreed) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 정보가 없습니다');

      await _firestore.collection('users').doc(user.uid).update({
        'termsAgreed': true,
        'termsAgreedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const InviteCodeScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('약관 동의 저장 실패: ${e.toString()}', Colors.red);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v32,
              // 제목
              const Text(
                '서비스 이용을 위해\n약관에 동의해 주세요',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.3,
                ),
              ),
              Gaps.v8,
              const Text(
                '모든 항목은 필수입니다',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Gaps.v48,

              // 체크박스 리스트
              _TermsCheckbox(
                title: '개인정보 처리방침에 동의합니다',
                isChecked: _privacyPolicyAgreed,
                onChanged: (value) =>
                    setState(() => _privacyPolicyAgreed = value ?? false),
                onViewTap: () => TermsViewerScreen.showPrivacyPolicy(context),
              ),
              Gaps.v16,
              _TermsCheckbox(
                title: '서비스 이용약관에 동의합니다',
                isChecked: _termsOfServiceAgreed,
                onChanged: (value) =>
                    setState(() => _termsOfServiceAgreed = value ?? false),
                onViewTap: () => TermsViewerScreen.showTermsOfService(context),
              ),
              Gaps.v16,
              _TermsCheckbox(
                title: '제3자 정보 제공에 동의합니다',
                isChecked: _thirdPartyInfoAgreed,
                onChanged: (value) =>
                    setState(() => _thirdPartyInfoAgreed = value ?? false),
                onViewTap: () => TermsViewerScreen.showThirdPartyInfo(context),
              ),

              const Spacer(),

              // 동의하고 계속하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _allAgreed && !_isLoading ? _saveAgreement : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '동의하고 계속하기',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              Gaps.v24,
            ],
          ),
        ),
      ),
    );
  }
}

/// 약관 체크박스 위젯
class _TermsCheckbox extends StatelessWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onViewTap;

  const _TermsCheckbox({
    required this.title,
    required this.isChecked,
    required this.onChanged,
    required this.onViewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isChecked ? Colors.black : Colors.grey[300]!,
          width: isChecked ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isChecked,
              onChanged: onChanged,
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Gaps.v12,
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 14,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
          TextButton(
            onPressed: onViewTap,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              '보기',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 13,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
