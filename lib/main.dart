import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:miraclemoney/features/auth/data/auth_service.dart';
import 'package:miraclemoney/features/auth/presentation/screens/terms_agreement_screen.dart';
import 'package:miraclemoney/features/auth/presentation/screens/invite_code_screen.dart';
import 'package:miraclemoney/features/auth/presentation/screens/user_info_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/demo_salary_step1_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/demo_salary_step2_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/demo_salary_result_screen.dart';
import 'package:miraclemoney/features/salary/presentation/screens/salary_result_screen.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/navigation/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: const AuthGate(),
      // ✨ routes 추가
      routes: {
        '/demo_salary_step1': (context) => const DemoSalaryStep1Screen(),
        '/demo_salary_step2': (context) => const DemoSalaryStep2Screen(),
        '/demo_salary_result': (context) => const DemoSalaryResultScreen(),
        '/invite_code': (context) => const InviteCodeScreen(),
      },
    );
  }
}

/// ✨ 인증 게이트 (5단계 라우팅)
/// 1. 로그인 여부 확인
/// 2. 약관 동의 여부 확인
/// 3. 초대코드 입력 여부 확인
/// 4. 사용자 정보(생년월일/성별) 입력 여부 확인
/// 5. 적절한 화면으로 이동
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 3,
              ),
            ),
          );
        }

        // ❌ 로그인 안 됨 → 로그인 화면
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // ✅ 로그인 됨 → 약관 동의 확인
        return FutureBuilder<bool>(
          future: AuthService().hasAgreedToTerms(),
          builder: (context, termsSnapshot) {
            // 🔄 약관 동의 확인 중
            if (termsSnapshot.connectionState == ConnectionState.waiting) {
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

            // ❌ 약관 동의 안 함 → 약관 동의 화면
            if (termsSnapshot.data == false) {
              return const TermsAgreementScreen();
            }

            // ✅ 약관 동의 완료 → 초대코드 확인
            return FutureBuilder<bool>(
              future: AuthService().hasInviteCode(),
              builder: (context, codeSnapshot) {
                // 🔄 초대코드 확인 중
                if (codeSnapshot.connectionState == ConnectionState.waiting) {
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

                // ❌ 초대코드 없음 → 초대코드 입력 화면
                if (codeSnapshot.data == false) {
                  return const InviteCodeScreen();
                }

                // ✅ 초대코드 있음 → 사용자 정보 확인
                return FutureBuilder<bool>(
                  future: AuthService().hasUserInfo(),
                  builder: (context, userInfoSnapshot) {
                    // 🔄 사용자 정보 확인 중
                    if (userInfoSnapshot.connectionState ==
                        ConnectionState.waiting) {
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

                    // ❌ 사용자 정보 없음 → 사용자 정보 입력 화면
                    if (userInfoSnapshot.data == false) {
                      return const UserInfoScreen();
                    }

                    // ✅ 모든 정보 완료 → 홈 화면
                    return const MainNavigationScreen();
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
