import 'package:flutter/material.dart';
import 'package:miraclemoney/features/auth/presentation/screens/terms_viewer_screen.dart';

/// 도움말 화면
class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

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
          ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.black,
            ),
            title: const Text(
              '개인정보 처리방침 보기',
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
              '서비스 이용약관 보기',
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => TermsViewerScreen.showTermsOfService(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.people_outline, color: Colors.black),
            title: const Text(
              '제3자 정보 제공 안내 보기',
              style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 16),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => TermsViewerScreen.showThirdPartyInfo(context),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
