import 'package:flutter/material.dart';
import 'package:miraclemoney/constants/gaps.dart';
import 'package:miraclemoney/constants/sizes.dart';

class SalaryStep1Screen extends StatefulWidget {
  const SalaryStep1Screen({super.key});

  @override
  State<SalaryStep1Screen> createState() => _SalaryStep1ScreenState();
}

class _SalaryStep1ScreenState extends State<SalaryStep1Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, String> formData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('월급 최적화')),
      body: Form(
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
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
                        borderRadius: BorderRadius.circular(Sizes.size8),
                      ),
                    ),
                    onSaved: (value) {
                      formData['field1'] = value ?? '';
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide.none,
                  ),
                  labelText: '현재 나이',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                ),
                onSaved: (value) {
                  formData['field1'] = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide.none,
                  ),
                  labelText: '현재 나이',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                ),
                onSaved: (value) {
                  formData['field1'] = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide.none,
                  ),
                  labelText: '현재 나이',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                ),
                onSaved: (value) {
                  formData['field1'] = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide.none,
                  ),
                  labelText: '현재 나이',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                ),
                onSaved: (value) {
                  formData['field1'] = value ?? '';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                    borderSide: BorderSide.none,
                  ),
                  labelText: '현재 나이',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                ),
                onSaved: (value) {
                  formData['field1'] = value ?? '';
                },
              ),
              const SizedBox(height: 16),

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
    );
  }
}
