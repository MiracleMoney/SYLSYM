import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  const CalendarWidget({
    super.key,
    required this.onDateSelected,
    required this.selectedDate,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDate;
  bool isWeekly = true;
  static const _days = ['월 ', '화', '수', '목', '금', '토', '일'];

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.selectedDate;
  }

  // 주간 캘린더 생성
  List<DateTime> _getWeekDates(DateTime date) {
    int currentWeekday = date.weekday;
    DateTime mondayOfWeek = date.subtract(Duration(days: currentWeekday - 1));
    return List.generate(7, (index) => mondayOfWeek.add(Duration(days: index)));
  }

  // 월간 캘린더를 그리드로 표시할 날짜 리스트
  List<DateTime> _getMonthDates(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    List<DateTime> dates = [];

    // 이전 달의 날짜들 (회색으로 표시)
    if (firstWeekday > 1) {
      final prevMonthLastDay = DateTime(date.year, date.month, 0).day;
      for (int i = firstWeekday - 1; i > 0; i--) {
        dates.add(
          DateTime(date.year, date.month - 1, prevMonthLastDay - i + 1),
        );
      }
    }

    // 이번 달 날짜
    for (int i = 1; i <= daysInMonth; i++) {
      dates.add(DateTime(date.year, date.month, i));
    }

    // 다음 달 날짜 (회색으로 표시) - 42개가 될 때까지
    int nextMonthDay = 1;
    while (dates.length < 42) {
      dates.add(DateTime(date.year, date.month + 1, nextMonthDay));
      nextMonthDay++;
    }

    return dates;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == _focusedDate.month && date.year == _focusedDate.year;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(5, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 캘린더 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '날짜 선택',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Gmarket_sans',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildCalendarToggleButton(
                      label: '주간',
                      isSelected: isWeekly,
                      onTap: () {
                        setState(() {
                          isWeekly = true;
                        });
                      },
                    ),
                    _buildCalendarToggleButton(
                      label: '월간',
                      isSelected: !isWeekly,
                      onTap: () {
                        setState(() {
                          isWeekly = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 주간/월간 캘린더
          if (isWeekly) _buildWeeklyCalendar() else _buildMonthlyCalendar(),

          const SizedBox(height: 16),

          // 선택된 날짜 표시
          Center(
            child: Text(
              DateFormat('EEE, M/d/y', 'ko_KR').format(widget.selectedDate),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'Gmarket_sans',
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Gmarket_sans',
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
              color: isSelected ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    final weekDates = _getWeekDates(_focusedDate);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 요일 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days
              .map(
                (day) => Text(
                  day,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),

        // 날짜 버튼 - Row로 변경 (더 가벼움)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDates.map((date) => _buildDateButton(date)).toList(),
        ),
      ],
    );
  }

  Widget _buildMonthlyCalendar() {
    final monthDates = _getMonthDates(_focusedDate);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 요일 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _days
              .map(
                (day) => Text(
                  day,
                  style: TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),

        // 날짜 그리드 - Wrap으로 변경 (GridView.builder보다 가벼움)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: monthDates.map((date) => _buildDateButton(date)).toList(),
        ),
      ],
    );
  }

  Widget _buildDateButton(DateTime date) {
    final isSelected = _isSameDay(date, widget.selectedDate);
    final isCurrentMonth = _isCurrentMonth(date);
    final today = DateTime.now();
    final isToday = _isSameDay(date, today);

    return SizedBox(
      width: 45,
      height: 45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onDateSelected(date);
            setState(() {
              _focusedDate = date;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFE9435A) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontFamily: 'Gmarket_sans',
                fontWeight: isSelected
                    ? FontWeight.w700
                    : isToday
                    ? FontWeight.w700
                    : FontWeight.w500,
                fontSize: 13,
                color: isSelected
                    ? Colors.white
                    : isCurrentMonth
                    ? Colors.black
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
