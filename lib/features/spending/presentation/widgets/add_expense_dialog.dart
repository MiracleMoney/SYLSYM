import 'package:flutter/material.dart';
import 'package:miraclemoney/core/constants/sizes.dart';
import 'package:miraclemoney/features/spending/data/models/expense_model.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/calendar_widget.dart';
import 'package:miraclemoney/features/spending/presentation/widgets/category_selector_widget.dart';
import 'package:intl/intl.dart';

class AddExpenseDialog extends StatefulWidget {
  final Function(ExpenseModel) onExpenseAdded;
  final Function(ExpenseModel)? onExpenseUpdated;
  final Function(String)? onExpenseDeleted;
  final ExpenseModel? existingExpense;

  const AddExpenseDialog({
    super.key,
    required this.onExpenseAdded,
    this.onExpenseUpdated,
    this.onExpenseDeleted,
    this.existingExpense,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  late DateTime _selectedDate;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  String? _selectedSubcategory;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();

    // 기존 지출이 있으면 수정 모드, 없으면 추가 모드
    if (widget.existingExpense != null) {
      _selectedDate = widget.existingExpense!.date;
      _amountController = TextEditingController(
        text: NumberFormat(
          '#,###',
        ).format(widget.existingExpense!.amount.toInt()),
      );
      _descriptionController = TextEditingController(
        text: widget.existingExpense!.description,
      );
      _selectedCategory = widget.existingExpense!.category;
      _selectedSubcategory = widget.existingExpense!.subcategory;
    } else {
      _selectedDate = DateTime.now();
      _amountController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _amountController.text.isNotEmpty &&
        _amountController.text != '0' &&
        // _descriptionController.text.isNotEmpty &&
        _selectedCategory != null &&
        _selectedSubcategory != null;
  }

  void _saveExpense() {
    if (!_isFormValid()) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            '모든 필드를 입력해주세요.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      return;
    }

    final expense = ExpenseModel(
      id:
          widget.existingExpense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      date: _selectedDate,
      amount: double.parse(_amountController.text.replaceAll(',', '')),
      description: _descriptionController.text,
      category: _selectedCategory!,
      subcategory: _selectedSubcategory!,
      createdAt: widget.existingExpense?.createdAt ?? DateTime.now(),
    );

    // 수정 모드면 onExpenseUpdated, 추가 모드면 onExpenseAdded 호출
    if (widget.existingExpense != null) {
      widget.onExpenseUpdated?.call(expense);
    } else {
      widget.onExpenseAdded(expense);
    }

    Navigator.pop(context);
  }

  void _deleteExpense() {
    if (widget.existingExpense == null) return;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text(
            '지출 삭제',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            '이 지출을 삭제하시겠습니까?',
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onExpenseDeleted?.call(widget.existingExpense!.id);
                Navigator.pop(context);
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatAmount(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(',', ''));
    if (number == null) return value;
    return NumberFormat('#,###').format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(
            builder: (scaffoldContext) => Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.95,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 헤더
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.existingExpense != null ? '지출 수정' : '추가 지출',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontFamily: 'Gmarket_sans',
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        // 수정 모드일 때 삭제 버튼, 아니면 체크 버튼
                        widget.existingExpense != null
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: _deleteExpense,
                              )
                            : IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: _saveExpense,
                              ),
                      ],
                    ),
                  ),

                  // 콘텐츠
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 캘린더
                          CalendarWidget(
                            selectedDate: _selectedDate,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // 금액 입력
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '금액 *',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontFamily: 'Gmarket_sans',
                                        fontWeight: FontWeight.w700,
                                        fontSize: Sizes.size16 + Sizes.size2,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      Sizes.size8,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '₩ ',
                                        style: TextStyle(
                                          fontFamily: 'Gmarket_sans',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          controller: _amountController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            hintText: '0',
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Gmarket_sans',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                          onChanged: (value) {
                                            final formatted = _formatAmount(
                                              value,
                                            );
                                            if (formatted != value) {
                                              _amountController
                                                  .value = TextEditingValue(
                                                text: formatted,
                                                selection:
                                                    TextSelection.fromPosition(
                                                      TextPosition(
                                                        offset:
                                                            formatted.length,
                                                      ),
                                                    ),
                                              );
                                            }
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 설명 입력
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '세부내용',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontFamily: 'Gmarket_sans',
                                      fontWeight: FontWeight.w700,
                                      fontSize: Sizes.size16 + Sizes.size2,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: TextField(
                                  controller: _descriptionController,
                                  decoration: const InputDecoration(
                                    hintText: '예: 회사 점심 식대 등',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(16),
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Gmarket_sans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  minLines: 3,
                                  maxLines: 3,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 카테고리 선택
                          CategorySelectorWidget(
                            selectedCategory: _selectedCategory,
                            selectedSubcategory: _selectedSubcategory,
                            onCategorySelected: (category, subcategory) {
                              setState(() {
                                _selectedCategory = category;
                                _selectedSubcategory = subcategory;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // 저장 버튼
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        onPressed: _saveExpense,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.existingExpense != null ? '수정 완료' : '저장',
                          style: const TextStyle(
                            fontFamily: 'Gmarket_sans',
                            fontWeight: FontWeight.w700,
                            fontSize: Sizes.size16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
