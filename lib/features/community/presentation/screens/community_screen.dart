import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 24),
              const Text(
                '미라클머니 커뮤니티',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '유튜브 커뮤니티에서\n다양한 의견을 보내주세요!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => _launchYoutubeCommunity(context),
                icon: const Icon(Icons.play_arrow, size: 28),
                label: const Text(
                  '유튜브 커뮤니티 보러가기',
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '앱 내 커뮤니티 기능은 추후 업데이트 예정입니다',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchYoutubeCommunity(BuildContext context) async {
    final Uri url = Uri.parse(
      'https://www.youtube.com/@Miracle-Money/community',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '링크를 열 수 없습니다',
                style: TextStyle(fontFamily: 'Gmarket_sans'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '오류가 발생했습니다: $e',
              style: const TextStyle(fontFamily: 'Gmarket_sans'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
