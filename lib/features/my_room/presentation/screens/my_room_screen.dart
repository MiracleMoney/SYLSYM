import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miraclemoney/features/admin/presentation/screens/admin_home_screen.dart'; // ✅ 변경
import 'package:miraclemoney/features/admin/presentation/widgets/admin_password_dialog.dart';
import 'package:miraclemoney/features/my_room/presentation/screens/app_info_screen.dart';
import 'package:miraclemoney/features/my_room/presentation/screens/help_screen.dart';
import '../../../auth/data/auth_service.dart';

class MyRoomScreen extends StatelessWidget {
  const MyRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이룸',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        children: [
          // 사용자 프로필
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? '사용자',
                        style: const TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),

                      // TextButton(
                      //   onPressed: () => throw Exception(),
                      //   child: const Text("Throw Test Exception"),
                      // ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // 메뉴 리스트
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text(
              '도움말',
              style: TextStyle(fontFamily: 'Gmarket_sans'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text(
              '앱 정보',
              style: TextStyle(fontFamily: 'Gmarket_sans'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInfoScreen()),
              );
            },
          ),

          // ✅ 관리자만 보이는 버튼
          if (AdminAuth.isAdmin()) ...[
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.red,
              ),
              title: const Text(
                '🔐 관리자 페이지',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminHomeScreen(),
                  ),
                );
              },
            ),
          ],

          const Divider(),

          // 로그아웃
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              '로그아웃',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    '로그아웃',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: const Text(
                    '정말 로그아웃 하시겠습니까?',
                    style: TextStyle(fontFamily: 'Gmarket_sans'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          color: Colors.red,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                try {
                  await AuthService().signOut();
                  if (context.mounted) {
                    // 로그아웃 후 Navigator를 초기화하여 로그인 화면으로 이동
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('로그아웃 실패: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
