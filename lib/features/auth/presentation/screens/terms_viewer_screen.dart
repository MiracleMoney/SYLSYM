import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/terms_content.dart';

/// 약관 내용 보기 화면
class TermsViewerScreen extends StatelessWidget {
  final String title;
  final String content;

  const TermsViewerScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            content,
            style: const TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 14,
              height: 1.8,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  /// 개인정보 처리방침 보기
  static void showPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsViewerScreen(
          title: '개인정보 처리방침',
          content: TermsContent.privacyPolicy,
        ),
      ),
    );
  }

  /// 서비스 이용약관 보기
  static void showTermsOfService(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsViewerScreen(
          title: '서비스 이용약관',
          content: TermsContent.termsOfService,
        ),
      ),
    );
  }

  /// 제3자 정보 제공 안내 보기
  static void showThirdPartyInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsViewerScreen(
          title: '제3자 정보 제공 안내',
          content: TermsContent.thirdPartyInfo,
        ),
      ),
    );
  }
}
