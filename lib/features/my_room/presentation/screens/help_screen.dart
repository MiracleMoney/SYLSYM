import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:miraclemoney/features/auth/presentation/screens/terms_viewer_screen.dart';

/// 도움말 화면
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '도움말',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // 문의하기 섹션
          _buildSectionHeader('문의하기'),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: Colors.black),
            title: const Text(
              '이메일 문의',
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 16),
            ),
            subtitle: const Text(
              'miraclemoney23kr@gmail.com',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _launchEmail(),
          ),
          const Divider(height: 1),

          // FAQ 섹션
          _buildSectionHeader('자주 묻는 질문 (FAQ)'),
          _buildFAQItem(
            context,
            question: '앱을 어떻게 시작하나요?',
            answer:
                '구글 또는 애플 계정으로 로그인한 후, 메인 화면에서 급여 계산이나 자산 관리 기능을 이용하실 수 있습니다.',
          ),
          const Divider(height: 1, indent: 16),
          _buildFAQItem(
            context,
            question: '로그인이 안 돼요',
            answer:
                '구글 또는 애플 계정으로 로그인할 수 있습니다. 문제가 지속되면 앱을 재시작하거나 아래 이메일로 문의해주세요.',
          ),
          const Divider(height: 1, indent: 16),
          _buildFAQItem(
            context,
            question: '내 데이터는 안전한가요?',
            answer:
                '모든 데이터는 구글 Firebase를 통해 안전하게 암호화되어 저장됩니다. 개인정보 처리방침에서 자세한 내용을 확인하실 수 있습니다.',
          ),
          const Divider(height: 1, indent: 16),
          _buildFAQItem(
            context,
            question: '계정을 삭제하고 싶어요',
            answer:
                '마이룸 > 로그아웃 후, 이메일(miraclemoney23kr@gmail.com)로 계정 삭제를 요청하시면 처리해드립니다.',
          ),
          const Divider(height: 1, indent: 16),
          _buildFAQItem(
            context,
            question: '경제적자유 금액 계산은 어떻게 하나요?',
            answer: '하단의 "자산" 탭에서 세부 탭인 "월급최적화"에서 모든 항목을 입력 후 계산 버튼을 누르시면 됩니다.',
          ),
          const Divider(height: 1),

          // 정책 및 약관 섹션
          _buildSectionHeader('정책 및 약관'),
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.black,
            ),
            title: const Text(
              '개인정보 처리방침',
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => TermsViewerScreen.showPrivacyPolicy(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.black,
            ),
            title: const Text(
              '서비스 이용약관',
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => TermsViewerScreen.showTermsOfService(context),
          ),
          const Divider(height: 1),

          // 앱 정보
          _buildSectionHeader('앱 정보'),
          const ListTile(
            leading: Icon(Icons.info_outlined, color: Colors.black),
            title: Text(
              '버전',
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 16),
            ),
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Gmarket_sans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        question,
        style: const TextStyle(
          fontFamily: 'Gmarket_sans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'miraclemoney23kr@gmail.com',
      query: 'subject=[미라클머니 문의]',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      debugPrint('이메일 앱 실행 실패: $e');
    }
  }
}
