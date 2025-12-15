import 'package:flutter/material.dart';
import 'package:miraclemoney/features/admin/presentation/tabs/admin_dashboard_tab.dart';
import 'admin_code_generator_tab.dart';
import 'admin_code_list_tab.dart';

class AdminCodeTab extends StatelessWidget {
  const AdminCodeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              labelStyle: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(fontFamily: 'Gmarket_sans'),
              tabs: [
                Tab(text: '대시보드'),
                Tab(text: '코드 생성'),
                Tab(text: '코드 목록'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                AdminDashboardTab(),
                AdminCodeGeneratorTab(),
                AdminCodeListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
