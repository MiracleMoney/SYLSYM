import 'package:flutter/material.dart';
import '../widgets/admin_password_dialog.dart';
import '../tabs/admin_dashboard_tab.dart';
import '../tabs/admin_code_generator_tab.dart';
import '../tabs/admin_code_list_tab.dart';
import '../tabs/admin_user_list_tab.dart'; //
import '../tabs/admin_finance_stats_tab.dart'; // ✅ 추가

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    if (!AdminAuth.isAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showAccessDeniedDialog();
        }
      });
    }
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
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
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AdminAuth.isAdmin()) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🔐 관리자 페이지',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
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
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          AdminDashboardTab(),
          AdminCodeGeneratorTab(),
          AdminCodeListTab(),
          AdminUserListTab(), // ✅ 추가
          AdminFinanceStatsTab(), // ✅ 추가
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Gmarket_sans',
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Gmarket_sans'),
        type: BottomNavigationBarType.fixed, // ✅ 4개 이상일 때 필수

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '대시보드'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: '코드 생성'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: '코드 목록'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '사용자 목록',
          ), // ✅ 추가
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: '금융 통계',
          ), // ✅ 추가
        ],
      ),
    );
  }
}
