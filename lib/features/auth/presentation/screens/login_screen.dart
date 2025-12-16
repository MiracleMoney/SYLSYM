import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import '../../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && mounted) {
        // 로그인 성공 - AuthStateChanges가 자동으로 화면 전환
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ 로그인 성공!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 로그인 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 로고 또는 앱 이름
              Text(
                'Miracle Money',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w700,
                  fontSize: Sizes.size40,
                ),
              ),

              Gaps.v20,

              Text(
                'Save Your Money,\nSave Your Life',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Gmarket_sans',
                  color: Colors.grey.shade600,
                  fontSize: Sizes.size16,
                  height: 1.5,
                ),
              ),

              Gaps.v64,

              // 구글 로그인 버튼
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_outlined, size: 20),
                            const SizedBox(width: 12),
                            const Text(
                              'Google 계정으로 시작하기',
                              style: TextStyle(
                                fontFamily: 'Gmarket_sans',
                                fontSize: Sizes.size16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              Gaps.v64,
              Gaps.v32,
            ],
          ),
        ),
      ),
    );
  }
}
