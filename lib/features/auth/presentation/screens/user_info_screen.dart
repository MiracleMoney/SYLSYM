import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miraclemoney/core/constants/gaps.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/navigation/main_navigation_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _birthYearController = TextEditingController();
  final TextEditingController _birthMonthController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  final FocusNode _birthYearFocus = FocusNode();
  final FocusNode _birthMonthFocus = FocusNode();
  final FocusNode _birthDayFocus = FocusNode();

  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _birthYearController.dispose();
    _birthMonthController.dispose();
    _birthDayController.dispose();
    _birthYearFocus.dispose();
    _birthMonthFocus.dispose();
    _birthDayFocus.dispose();
    super.dispose();
  }

  /// 사용자 정보 저장
  Future<void> _saveUserInfo() async {
    // 유효성 검증
    if (_birthYearController.text.isEmpty ||
        _birthMonthController.text.isEmpty ||
        _birthDayController.text.isEmpty) {
      _showSnackBar('생년월일을 모두 입력해주세요', Colors.orange);
      return;
    }

    if (_selectedGender == null) {
      _showSnackBar('성별을 선택해주세요', Colors.orange);
      return;
    }

    final year = int.tryParse(_birthYearController.text);
    final month = int.tryParse(_birthMonthController.text);
    final day = int.tryParse(_birthDayController.text);

    if (year == null || year < 1900 || year > DateTime.now().year) {
      _showSnackBar('올바른 연도를 입력해주세요', Colors.red);
      return;
    }

    if (month == null || month < 1 || month > 12) {
      _showSnackBar('올바른 월을 입력해주세요', Colors.red);
      return;
    }

    if (day == null || day < 1 || day > 31) {
      _showSnackBar('올바른 일을 입력해주세요', Colors.red);
      return;
    }

    try {
      final birthdate = DateTime(year, month, day);
      if (birthdate.isAfter(DateTime.now())) {
        _showSnackBar('미래 날짜는 입력할 수 없습니다', Colors.red);
        return;
      }
    } catch (e) {
      _showSnackBar('올바른 날짜를 입력해주세요', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 정보가 없습니다');

      final birthdate = DateTime(year, month, day);

      await _firestore.collection('users').doc(user.uid).update({
        'birthdate': Timestamp.fromDate(birthdate),
        'gender': _selectedGender,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('정보 저장 실패: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Gmarket_sans'),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Sizes.size24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gaps.v32,
              // 제목
              const Text(
                '추가 정보를 입력해주세요',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Gaps.v8,
              const Text(
                '서비스 이용을 위해 필요한 정보입니다',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Gaps.v48,

              // 생년월일
              Row(
                children: [
                  Icon(Icons.cake_outlined, size: 20, color: Colors.grey[700]),
                  Gaps.v8,
                  const Text(
                    '생년월일',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Gaps.v12,
              Row(
                children: [
                  // 연도
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _birthYearController,
                      focusNode: _birthYearFocus,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '1990',
                        hintStyle: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          color: Colors.grey[400],
                        ),
                        counterText: '',
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _birthMonthFocus.requestFocus(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '년',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  // 월
                  Expanded(
                    child: TextField(
                      controller: _birthMonthController,
                      focusNode: _birthMonthFocus,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '01',
                        hintStyle: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          color: Colors.grey[400],
                        ),
                        counterText: '',
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _birthDayFocus.requestFocus(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '월',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  // 일
                  Expanded(
                    child: TextField(
                      controller: _birthDayController,
                      focusNode: _birthDayFocus,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: '15',
                        hintStyle: TextStyle(
                          fontFamily: 'Gmarket_sans',
                          color: Colors.grey[400],
                        ),
                        counterText: '',
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      '일',
                      style: TextStyle(
                        fontFamily: 'Gmarket_sans',
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),

              Gaps.v40,

              // 성별
              Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Colors.grey[700]),
                  Gaps.v8,
                  const Text(
                    '성별',
                    style: TextStyle(
                      fontFamily: 'Gmarket_sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Gaps.v12,
              Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      label: '남성',
                      isSelected: _selectedGender == '남성',
                      onTap: () => setState(() => _selectedGender = '남성'),
                    ),
                  ),
                  Gaps.v12,
                  Expanded(
                    child: _GenderButton(
                      label: '여성',
                      isSelected: _selectedGender == '여성',
                      onTap: () => setState(() => _selectedGender = '여성'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveUserInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '완료',
                          style: TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              Gaps.v24,
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
