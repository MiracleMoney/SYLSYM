import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miraclemoney/features/salary/salary_result_screen.dart';
import 'package:miraclemoney/features/salary/salary_step1_screen.dart';
import 'package:miraclemoney/features/salary/salary_step2_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/login_screen.dart';
import 'features/main_navigation_screen.dart'; // ✅ 변경

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      themeMode: ThemeMode.system,
      theme: ThemeData(
        fontFamily: "Gmarket_sans",

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffe46d1fd),
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
    );
  }
}

// ✅ 인증 게이트 (로그인 상태 체크)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 로그인 상태 확인
        if (snapshot.hasData) {
          // 로그인됨 → 메인 화면
          return const MainNavigationScreen();
        } else {
          // 로그인 안됨 → 로그인 화면
          return const LoginScreen();
        }
      },
    );
  }
}
