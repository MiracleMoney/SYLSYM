import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:miraclemoney/features/auth/data/auth_service.dart';
import 'package:miraclemoney/features/auth/presentation/screens/terms_agreement_screen.dart';
import 'package:miraclemoney/features/auth/presentation/screens/invite_code_screen.dart';
import 'package:miraclemoney/features/auth/presentation/screens/user_info_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/demo_salary_step1_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/demo_salary_step2_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/demo_salary_result_screen.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale data is required for Intl date formatting (e.g., Korean weekdays).
  await initializeDateFormatting('ko_KR');

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miracle Money',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        fontFamily: "Gmarket_sans",
        useMaterial3: true,

        // Google Fonts Roboto로 전체 텍스트 테마 설정
        // textTheme: GoogleFonts.robotoTextTheme().copyWith(
        //   headlineLarge: GoogleFonts.roboto(
        //     textStyle: const TextStyle(
        //       fontSize: Sizes.size24,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        //   headlineMedium: GoogleFonts.roboto(
        //     textStyle: const TextStyle(
        //       fontSize: Sizes.size20 + Sizes.size2,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        //   titleMedium: GoogleFonts.roboto(
        //     textStyle: const TextStyle(
        //       fontSize: Sizes.size16 + Sizes.size4,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        //   titleSmall: GoogleFonts.roboto(
        //     textStyle: const TextStyle(
        //       fontSize: Sizes.size14,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        //   bodyLarge: GoogleFonts.roboto(
        //     textStyle: const TextStyle(fontSize: Sizes.size16),
        //   ),
        //   bodyMedium: GoogleFonts.roboto(
        //     textStyle: const TextStyle(fontSize: Sizes.size16 + Sizes.size4),
        //   ),
        // ),
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        // 색상 스킴
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFE9435A),
        ),
        splashColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: Sizes.size16 + Sizes.size2,
            fontWeight: FontWeight.w600,
          ),
        ),
        tabBarTheme: TabBarThemeData(
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade500,
        ),
      ),
      initialRoute: '/splash',
      // ✨ routes 추가
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const AuthGate(),
        '/demo_salary_step1': (context) => const DemoSalaryStep1Screen(),
        '/demo_salary_step2': (context) => const DemoSalaryStep2Screen(),
        '/demo_salary_result': (context) => const DemoSalaryResultScreen(),
        '/invite_code': (context) => const InviteCodeScreen(),
      },
    );
  }
}

/// 인증 게이트 — 로그인 상태와 온보딩 완료 여부에 따라 적절한 화면으로 라우팅.
///
/// StatefulWidget으로 _onboardingFuture를 State에 보관하여,
/// authStateChanges 재emit 시에도 Firestore를 반복 읽지 않도록 최적화.
/// users/{uid} 문서를 1회만 읽어 모든 온보딩 단계를 판단한다.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  /// 로그인 상태가 유지되는 동안 재사용되는 Future.
  /// 로그아웃 시 null로 초기화하여 다음 로그인에서 새로 생성된다.
  Future<OnboardingStep>? _onboardingFuture;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 인증 상태 확인 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }

        // ❌ 로그인 안 됨 → Future 초기화 후 로그인 화면
        if (!snapshot.hasData || snapshot.data == null) {
          _onboardingFuture = null;
          return const LoginScreen();
        }

        // ✅ 로그인 됨 → Future를 한 번만 생성하여 재사용 (??= 연산자)
        _onboardingFuture ??= AuthService().checkOnboardingStep();

        return FutureBuilder<OnboardingStep>(
          future: _onboardingFuture,
          builder: (context, stepSnapshot) {
            // 🔄 온보딩 단계 확인 중
            if (stepSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            // ⚠️ 오류 발생 시 재시도 화면 표시
            if (stepSnapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '데이터를 불러오는 중 오류가 발생했습니다.',
                        style: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _onboardingFuture =
                                AuthService().checkOnboardingStep();
                          });
                        },
                        child: const Text(
                          '다시 시도',
                          style: TextStyle(fontFamily: 'Gmarket_sans'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ✅ 단계별 화면 라우팅
            switch (stepSnapshot.data) {
              case OnboardingStep.terms:
                return const TermsAgreementScreen();
              case OnboardingStep.inviteCode:
                return const InviteCodeScreen();
              case OnboardingStep.userInfo:
                return const UserInfoScreen();
              case OnboardingStep.done:
              case null:
                return const MainNavigationScreen();
            }
          },
        );
      },
    );
  }

  /// 공통 로딩 위젯 — 기존 3곳에 중복 정의되어 있던 것을 통합
  Widget _buildLoading() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              '잠시만 기다려주세요...',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
