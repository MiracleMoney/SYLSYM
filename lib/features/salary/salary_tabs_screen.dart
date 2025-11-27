import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'package:miraclemoney/features/salary/salary_step1_screen.dart';
import 'package:miraclemoney/features/salary/salary_step2_screen.dart';
import 'package:miraclemoney/features/salary/salary_result_screen.dart';
import 'package:miraclemoney/features/budget/budget_screen.dart';
import 'package:miraclemoney/features/asset_status/asset_status_screen.dart';
import 'package:miraclemoney/models/salary_complete_data.dart';
import 'package:miraclemoney/services/firestore_service.dart';

class SalaryTabsScreen extends StatefulWidget {
  const SalaryTabsScreen({super.key});

  @override
  State<SalaryTabsScreen> createState() => _SalaryTabsScreenState();
}

class _SalaryTabsScreenState extends State<SalaryTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _salaryPageController = PageController();
  int _currentSalaryPage = 0;

  // Step1에서 전달받은 컨트롤러들을 저장
  Map<String, dynamic> _step1Controllers = {};
  Map<String, dynamic> _step2Controllers = {}; // ✅ 추가

  // ✅ ValueNotifier를 TabsScreen에서 관리
  final ValueNotifier<DateTime> _currentMonth = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  final FirestoreService _firestoreService = FirestoreService(); // ✅ 추가
  bool _isLoadingData = true; // ✅ 로딩 상태

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!mounted) return;
      // 다른 탭으로 이동하면 Step1으로 리셋
      if (_tabController.index == 0 && _currentSalaryPage != 0) {
        _resetToStep1();
      }
    });
    // ✅ 현재 월 변경 시 데이터 확인
    _currentMonth.addListener(_checkAndLoadMonthData);

    // ✅ 초기 데이터 로드
    _checkAndLoadMonthData();
  }

  @override
  void dispose() {
    _currentMonth.removeListener(_checkAndLoadMonthData);

    _tabController.dispose();
    _salaryPageController.dispose();
    _currentMonth.dispose(); // ✅ 여기서만 dispose

    super.dispose();
  }

  // ✅ 현재 월의 데이터 확인 및 로드 (없으면 이전 달 데이터 불러오기)
  Future<void> _checkAndLoadMonthData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingData = true;
    });

    try {
      // 1. 현재 선택된 월의 데이터 먼저 시도
      SalaryCompleteData? data = await _firestoreService.loadSalaryDataByMonth(
        _currentMonth.value,
      );

      // 2. 현재 월 데이터가 없으면 이전 달 데이터 찾기
      if (data == null) {
        DateTime checkMonth = DateTime(
          _currentMonth.value.year,
          _currentMonth.value.month - 1,
        );
        // 최대 12개월 이전까지 검색
        for (int i = 0; i < 12; i++) {
          data = await _firestoreService.loadSalaryDataByMonth(checkMonth);

          if (data != null) {
            print('✅ 이전 달 데이터 발견: ${checkMonth.year}년 ${checkMonth.month}월');
            break;
          }

          // 한 달 더 이전으로
          checkMonth = DateTime(checkMonth.year, checkMonth.month - 1);
        }
      }

      if (data != null && mounted) {
        // 데이터가 있으면 컨트롤러 생성 및 Result 화면으로 이동
        _loadDataToControllers(data);

        setState(() {
          _currentSalaryPage = 2; // Result 페이지
          _isLoadingData = false;
        });

        // PageController가 준비된 후 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _salaryPageController.hasClients) {
            _salaryPageController.jumpToPage(2);
          }
        });
      } else {
        // 데이터가 없으면 Step1 유지
        setState(() {
          _currentSalaryPage = 0;
          _isLoadingData = false;
          _step1Controllers = {};
          _step2Controllers = {};
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _salaryPageController.hasClients) {
            _salaryPageController.jumpToPage(0);
          }
        });
      }
    } catch (e) {
      print('데이터 로드 실패: $e');
      if (mounted) {
        setState(() {
          _currentSalaryPage = 0;
          _isLoadingData = false;
        });
      }
    }
  }

  // ✅ Firestore 데이터를 컨트롤러로 변환
  void _loadDataToControllers(SalaryCompleteData data) {
    // Step1 컨트롤러 생성
    final currentAgeController = TextEditingController(
      text: data.step1.currentAge?.toString() ?? '',
    );
    final retireAgeController = TextEditingController(
      text: data.step1.retireAge?.toString() ?? '',
    );
    final livingExpenseController = TextEditingController(
      text: data.step1.livingExpense?.toString() ?? '',
    );
    final snpValueController = TextEditingController(
      text: data.step1.snpValue?.toString() ?? '',
    );
    final expectedReturnController = TextEditingController(
      text: data.step1.expectedReturn?.toString() ?? '',
    );
    final inflationController = TextEditingController(
      text: data.step1.inflation?.toString() ?? '',
    );
    final shortTermAmountController = TextEditingController(
      text: data.step1.shortTermAmount?.toString() ?? '',
    );
    final shortTermDurationController = TextEditingController(
      text: data.step1.shortTermDuration?.toString() ?? '',
    );
    final shortTermSavedController = TextEditingController(
      text: data.step1.shortTermSaved?.toString() ?? '',
    );

    _step1Controllers = {
      'currentAgeController': currentAgeController,
      'retireAgeController': retireAgeController,
      'livingExpenseController': livingExpenseController,
      'snpValueController': snpValueController,
      'expectedReturnController': expectedReturnController,
      'inflationController': inflationController,
      'hasShortTermGoal': data.step1.hasShortTermGoal,
      'selectedShortTermGoal': data.step1.shortTermGoal,
      'shortTermAmountController': shortTermAmountController,
      'shortTermDurationController': shortTermDurationController,
      'shortTermSavedController': shortTermSavedController,
    };

    // Step2 컨트롤러 생성
    final baseSalaryController = TextEditingController(
      text: data.step2.baseSalary?.toString() ?? '',
    );
    final overtimeController = TextEditingController(
      text: data.step2.overtime?.toString() ?? '',
    );
    final bonusController = TextEditingController(
      text: data.step2.bonus?.toString() ?? '',
    );
    final incentiveController = TextEditingController(
      text: data.step2.incentive?.toString() ?? '',
    );
    final side1Controller = TextEditingController(
      text: data.step2.sideIncome1?.toString() ?? '',
    );
    final side2Controller = TextEditingController(
      text: data.step2.sideIncome2?.toString() ?? '',
    );
    final side3Controller = TextEditingController(
      text: data.step2.sideIncome3?.toString() ?? '',
    );
    final retirementController = TextEditingController(
      text: data.step2.retirement?.toString() ?? '',
    );

    _step2Controllers = {
      'baseSalaryController': baseSalaryController,
      'overtimeController': overtimeController,
      'bonusController': bonusController,
      'incentiveController': incentiveController,
      'side1Controller': side1Controller,
      'side2Controller': side2Controller,
      'side3Controller': side3Controller,
      'retirementController': retirementController,
    };
  }

  void _resetToStep1() {
    setState(() {
      _currentSalaryPage = 0;
      _step1Controllers = {};
      _step2Controllers = {};
    });
    if (_salaryPageController.hasClients) {
      _salaryPageController.jumpToPage(0);
    }
  }

  void _navigateToStep2(Map<String, dynamic> controllers) {
    setState(() {
      _step1Controllers = controllers;
      _currentSalaryPage = 1;
    });
    _salaryPageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToResult(Map<String, dynamic> step2Controllers) {
    // ✅ 파라미터 추가
    setState(() {
      _step2Controllers = step2Controllers;
      _currentSalaryPage = 2;
    });
    _salaryPageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    if (_currentSalaryPage > 0) {
      setState(() {
        _currentSalaryPage--;
      });
      _salaryPageController.animateToPage(
        _currentSalaryPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:
            _tabController.index == 0 &&
                _currentSalaryPage > 0 &&
                _currentSalaryPage < 2
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack)
            : null,
        title: const Text(
          '자산 관리',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size24,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: const Color(0xFFE9435A),
          labelStyle: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w400,
            fontSize: 18,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: '월급최적화'),
            Tab(text: '예산'),
            Tab(text: '자산현황'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ✅ 로딩 중에는 로딩 인디케이터 표시
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              :
                // 월급최적화 플로우
                PageView(
                  controller: _salaryPageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    SalaryStep1Screen(
                      key: const ValueKey('step1'),
                      onNavigateToStep2: _navigateToStep2,
                      currentMonthNotifier: _currentMonth, // ✅ 전달
                    ),
                    if (_step1Controllers.isNotEmpty)
                      SalaryStep2Screen(
                        key: ValueKey('step2'),
                        currentAgeController:
                            _step1Controllers['currentAgeController'],
                        retireAgeController:
                            _step1Controllers['retireAgeController'],
                        livingExpenseController:
                            _step1Controllers['livingExpenseController'],
                        snpValueController:
                            _step1Controllers['snpValueController'],
                        expectedReturnController:
                            _step1Controllers['expectedReturnController'],
                        inflationController:
                            _step1Controllers['inflationController'],
                        hasShortTermGoal: _step1Controllers['hasShortTermGoal'],
                        selectedShortTermGoal:
                            _step1Controllers['selectedShortTermGoal'],
                        shortTermAmountController:
                            _step1Controllers['shortTermAmountController'],
                        shortTermDurationController:
                            _step1Controllers['shortTermDurationController'],
                        shortTermSavedController:
                            _step1Controllers['shortTermSavedController'],
                        currentMonthNotifier: _currentMonth, // ✅ 전달

                        onNavigateToResult: _navigateToResult, // ✅ 파라미터 전달
                      )
                    else
                      const SizedBox.shrink(),
                    if (_step1Controllers.isNotEmpty &&
                        _step2Controllers.isNotEmpty)
                      SalaryResultScreen(
                        key: const ValueKey('result'),
                        currentAgeController:
                            _step1Controllers['currentAgeController'],
                        retireAgeController:
                            _step1Controllers['retireAgeController'],
                        livingExpenseController:
                            _step1Controllers['livingExpenseController'],
                        snpValueController:
                            _step1Controllers['snpValueController'],
                        expectedReturnController:
                            _step1Controllers['expectedReturnController'],
                        inflationController:
                            _step1Controllers['inflationController'],
                        hasShortTermGoal: _step1Controllers['hasShortTermGoal'],
                        selectedShortTermGoal:
                            _step1Controllers['selectedShortTermGoal'],
                        shortTermAmountController:
                            _step1Controllers['shortTermAmountController'],
                        shortTermDurationController:
                            _step1Controllers['shortTermDurationController'],
                        shortTermSavedController:
                            _step1Controllers['shortTermSavedController'],
                        baseSalaryController:
                            _step2Controllers['baseSalaryController'],
                        overtimeController:
                            _step2Controllers['overtimeController'],
                        bonusController: _step2Controllers['bonusController'],
                        incentiveController:
                            _step2Controllers['incentiveController'],
                        side1Controller: _step2Controllers['side1Controller'],
                        side2Controller: _step2Controllers['side2Controller'],
                        side3Controller: _step2Controllers['side3Controller'],
                        retirementController:
                            _step2Controllers['retirementController'],
                        currentMonthNotifier: _currentMonth, // ✅ 전달
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
          const BudgetScreen(),
          const AssetStatusScreen(),
        ],
      ),
    );
  }
}
