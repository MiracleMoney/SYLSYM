import 'package:flutter/material.dart';
import 'package:miraclemoney/features/auth/data/auth_service.dart';
import 'package:miraclemoney/features/auth/presentation/screens/invite_code_screen.dart';
import 'package:miraclemoney/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/salary_tabs_screen.dart';
import 'package:miraclemoney/features/spending/presentation/screens/spending_screen.dart';
import 'package:miraclemoney/features/my_room/presentation/screens/my_room_screen.dart';
import 'package:miraclemoney/features/community/presentation/screens/community_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final AuthService _authService = AuthService(); // ✨ 추가

  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const SalaryTabsScreen(), // 월급최적화, 예산, 자산현황 탭
    const SpendingScreen(),
    const CommunityScreen(),

    const MyRoomScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _checkInviteCodeValidity(); // ✨ 초기 검증
  }

  /// ✨ 초대코드 유효성 검증
  Future<void> _checkInviteCodeValidity() async {
    final isValid = await _authService.checkInviteCodeValidity();

    if (!isValid && mounted) {
      // 유효하지 않으면 로그아웃 처리
      _showInvalidCodeDialog();
    }
  }

  /// ✨ 비활성화 알림 다이얼로그
  Future<void> _showInvalidCodeDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('접근 제한', style: TextStyle(fontFamily: 'Gmarket_sans')),
          ],
        ),
        content: const Text(
          '초대코드가 비활성화되었습니다.\n새로운 초대코드를 입력해주세요.',
          style: TextStyle(fontFamily: 'Gmarket_sans', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 새로운 코드를 입력할 수 있도록 InviteCodeScreen으로 이동
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const InviteCodeScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text(
              '코드 입력',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.bold,
              ),
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
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE9435A),
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Gmarket_sans',
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Gmarket_sans',
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: '대시보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: '자산',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: '지출',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum_outlined),
            activeIcon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: '마이룸',
          ),
        ],
      ),
    );
  }
}
