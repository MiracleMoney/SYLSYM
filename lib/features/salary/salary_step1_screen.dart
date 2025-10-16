import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'package:miraclemoney/constants/sizes.dart';
import 'widget.dart'; // 추가

class SalaryStep1Screen extends StatefulWidget {
  const SalaryStep1Screen({super.key});

  @override
  State<SalaryStep1Screen> createState() => _SalaryStep1ScreenState();
}

class _SalaryStep1ScreenState extends State<SalaryStep1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, String> formData = {};
  bool _hasShortTermGoal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('월급 최적화')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size20,
              vertical: Sizes.size24,
            ),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '현재 나이',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.size8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '현재 나이',
                        border: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(Sizes.size8),
                        ),
                      ),
                      onSaved: (value) {
                        formData['field1'] = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '은퇴 희망 나이',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.size8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '은퇴 희망 나이',
                        border: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(Sizes.size8),
                        ),
                      ),
                      onSaved: (value) {
                        formData['field1'] = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '현재 희망 생활비',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.size8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '현재 희망 생활비',
                        border: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(Sizes.size8),
                        ),
                      ),
                      onSaved: (value) {
                        formData['field1'] = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 18),

                LabeledTextFormField(
                  label: '현재 S&P500 평가금액',
                  hint: '현재 S&P500 평가금액',
                  keyboardType: TextInputType.number,
                  onSaved: (value) => formData['snpValue'] = value ?? '',
                ),
                SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '기대수익률',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.size8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '기대수익률',
                        border: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(Sizes.size8),
                        ),
                      ),
                      onSaved: (value) {
                        formData['field1'] = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      '예상 물가 상승률',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Sizes.size8),
                          borderSide: BorderSide.none,
                        ),
                        hintText: '예상 물가 상승률',
                        border: OutlineInputBorder(
                          gapPadding: 5,
                          borderRadius: BorderRadius.circular(Sizes.size8),
                        ),
                      ),
                      onSaved: (value) {
                        formData['field1'] = value ?? '';
                      },
                    ),
                  ],
                ),
                SizedBox(height: 18),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '단기 목표가 있나요?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  value: _hasShortTermGoal,
                  onChanged: (val) {
                    setState(() {
                      _hasShortTermGoal = val;
                    });
                  },
                ),

                // 단기 목표가 있을 때만 입력칸 표시
                if (_hasShortTermGoal) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '단기 목표',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(Sizes.size8),
                            borderSide: BorderSide.none,
                          ),
                          hintText: '단기 목표 금액/설명',
                          border: OutlineInputBorder(
                            gapPadding: 5,
                            borderRadius: BorderRadius.circular(Sizes.size8),
                          ),
                        ),
                        onSaved: (value) {
                          formData['shortTermGoal'] = value ?? '';
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // Process the form data
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
