import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/salary/presentation/screens/salary_step1_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/salary_step2_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/salary_result_screen.dart';
import 'package:miraclemoney/features/budget/presentaion/screens/budget_screen.dart';
import 'package:miraclemoney/features/asset_status/presentation/screens/asset_status_screen.dart';
import 'package:miraclemoney/data/models/salary/salary_complete_data.dart';
import 'package:miraclemoney/data/services/firestore_service.dart';
import 'package:flutter/foundation.dart'; // 👈 추가

class SalaryTabsScreen extends StatefulWidget {
  const SalaryTabsScreen({super.key});

  @override
  State<SalaryTabsScreen> createState() => _SalaryTabsScreenState();
}

class _SalaryTabsScreenState extends State<SalaryTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
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
    _tabController = TabController(length: 1, vsync: this);

    // ✅ 월급최적화 탭으로 돌아올 때 현재 상태 확인 후 적절한 페이지로 복원
    // _tabController.addListener(() {
    //   if (!mounted) return;

    //   // 월급최적화 탭(index 0)으로 돌아왔을 때
    //   if (_tabController.index == 0) {
    //     // 현재 저장된 페이지 위치로 복원 (리셋하지 않음)
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (mounted && _salaryPageController.hasClients) {
    //         // 애니메이션 없이 즉시 이동
    //         if (_salaryPageController.page != _currentSalaryPage.toDouble()) {
    //           _salaryPageController.jumpToPage(_currentSalaryPage);
    //         }
    //       }
    //     });
    //   }
    // });
    // ✅ 현재 월 변경 시 데이터 확인
    _currentMonth.addListener(_checkAndLoadMonthData);

    // ✅ 초기 데이터 로드
    _checkAndLoadMonthData();
  }

  @override
  void dispose() {
    _currentMonth.removeListener(_checkAndLoadMonthData);

    _tabController.dispose();
    _currentMonth.dispose(); // ✅ 여기서만 dispose

    super.dispose();
  }

  // ✅ 현재 월의 데이터 확인 및 로드 (없으면 이전 달 데이터 불러오기)
  Future<void> _checkAndLoadMonthData() async {
    if (!mounted) return;
    // ✅ 이미 컨트롤러가 있으면 (탭 전환 시) 로딩 상태 변경하지 않음
    final bool shouldShowLoading =
        _step1Controllers.isEmpty && _step2Controllers.isEmpty;

    if (shouldShowLoading) {
      setState(() {
        _isLoadingData = true;
      });
    }
    try {
      // 1. 현재 선택된 월의 데이터 먼저 시도
      SalaryCompleteData? data = await _firestoreService.loadSalaryDataByMonth(
        _currentMonth.value,
      );

      if (data != null && mounted) {
        // 현재 월 데이터가 있으면 Result 화면으로 이동
        _loadDataToControllers(data);

        setState(() {
          _currentSalaryPage = 2; // Result 페이지
          _isLoadingData = false;
        });
      } else {
        // 2. 현재 월 데이터가 없으면 바로 이전 달 데이터만 확인
        final previousMonth = DateTime(
          _currentMonth.value.year,
          _currentMonth.value.month - 1,
        );

        final previousData = await _firestoreService.loadSalaryDataByMonth(
          previousMonth,
        );

        if (previousData != null && mounted) {
          // ✅ 바로 이전 달 데이터가 있으면 Step1에만 표시 (Step2는 빈 상태)
          if (kDebugMode) {
            print(
              '✅ 이전 달 데이터 발견: ${previousMonth.year}년 ${previousMonth.month}월',
            );
          }
          _loadDataToControllersStep1Only(previousData); // ✅ Step1만 로드

          setState(() {
            _currentSalaryPage = 0; // ✅ Step1 페이지로 설정
            if (shouldShowLoading) _isLoadingData = false;
          });
        } else {
          // 이전 달 데이터도 없으면 빈 Step1 유지
          setState(() {
            _currentSalaryPage = 0;
            if (shouldShowLoading) _isLoadingData = false;
            _step1Controllers = {};
            _step2Controllers = {};
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ 데이터 로드 중 오류 발생: $e');
      }
      if (mounted) {
        setState(() {
          _currentSalaryPage = 0;
          if (shouldShowLoading) _isLoadingData = false;
        });
      }
    }
  }

  // ✅ Firestore 데이터를 컨트롤러로 변환 (전체)
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

  // ✅ Step1만 로드 (이전 달 데이터 참고용)
  void _loadDataToControllersStep1Only(SalaryCompleteData data) {
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

    // ✅ Step2는 빈 상태 유지 (사용자가 직접 입력)
    _step2Controllers = {};
  }

  void _resetToStep1() {
    // ✅ 기존 컨트롤러들 dispose
    _step1Controllers.forEach((key, value) {
      if (value is TextEditingController) {
        value.dispose();
      }
    });
    _step2Controllers.forEach((key, value) {
      if (value is TextEditingController) {
        value.dispose();
      }
    });
    setState(() {
      _currentSalaryPage = 0;
      _step1Controllers = {};
      _step2Controllers = {};
    });
  }

  void _navigateToStep2(Map<String, dynamic> controllers) {
    setState(() {
      _step1Controllers = controllers;
      _currentSalaryPage = 1; // ✅ IndexedStack은 setState만으로 충분
    });
  }

  void _navigateToResult(Map<String, dynamic> step2Controllers) {
    // ✅ 파라미터 추가
    setState(() {
      _step2Controllers = step2Controllers;
      _currentSalaryPage = 2;
    });
  }

  void _navigateToStep1FromResult() {
    setState(() {
      _currentSalaryPage = 0;
    });
  }

  void _goBack() {
    if (_currentSalaryPage > 0) {
      setState(() {
        _currentSalaryPage--;
      });
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
          '월급최적화',
          style: TextStyle(
            fontFamily: 'Gmarket_sans',
            fontWeight: FontWeight.w700,
            fontSize: Sizes.size24,
          ),
        ),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentSalaryPage,
              children: [
                SalaryStep1Screen(
                  key: ValueKey(
                    'step1_${_step1Controllers.hashCode}',
                  ), // ✅ 데이터가 바뀔 때마다 새로운 Key
                  onNavigateToStep2: _navigateToStep2,
                  currentMonthNotifier: _currentMonth, // ✅ 전달
                  // ✅ 로드된 컨트롤러를 전달
                  initialControllers: _step1Controllers.isNotEmpty
                      ? _step1Controllers
                      : null,
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
                    snpValueController: _step1Controllers['snpValueController'],
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
                    snpValueController: _step1Controllers['snpValueController'],
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
                    overtimeController: _step2Controllers['overtimeController'],
                    bonusController: _step2Controllers['bonusController'],
                    incentiveController:
                        _step2Controllers['incentiveController'],
                    side1Controller: _step2Controllers['side1Controller'],
                    side2Controller: _step2Controllers['side2Controller'],
                    side3Controller: _step2Controllers['side3Controller'],
                    retirementController:
                        _step2Controllers['retirementController'],
                    currentMonthNotifier: _currentMonth,
                    onNavigateToStep1: _navigateToStep1FromResult, // ✅ 콜백 전달
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
    );
  }
}
