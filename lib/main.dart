import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:miraclemoney/features/salary/salary_step1_screen.dart';
import 'package:miraclemoney/features/salary/salary_step2_screen.dart';

void main() {
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
        // Google Fonts Roboto로 전체 텍스트 테마 설정
        textTheme: GoogleFonts.robotoTextTheme().copyWith(
          headlineLarge: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: Sizes.size24,
              fontWeight: FontWeight.w700,
            ),
          ),
          headlineMedium: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: Sizes.size20 + Sizes.size2,
              fontWeight: FontWeight.w700,
            ),
          ),
          titleMedium: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: Sizes.size16 + Sizes.size4,
              fontWeight: FontWeight.w700,
            ),
          ),
          titleSmall: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: Sizes.size14,
              fontWeight: FontWeight.w700,
            ),
          ),
          bodyLarge: GoogleFonts.roboto(
            textStyle: const TextStyle(fontSize: Sizes.size16),
          ),
          bodyMedium: GoogleFonts.roboto(
            textStyle: const TextStyle(fontSize: Sizes.size16 + Sizes.size4),
          ),
        ),
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
      home: SalaryStep1Screen(),
    );
  }
}
