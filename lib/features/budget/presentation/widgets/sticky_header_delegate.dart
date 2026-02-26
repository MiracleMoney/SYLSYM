import 'package:flutter/material.dart';

/// 고정 헤더 델리게이트
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const StickyHeaderDelegate({required this.childBuilder});

  final Widget Function(bool showShadow) childBuilder;

  @override
  double get minExtent => 120; // 최소 높이

  @override
  double get maxExtent => 120; // 최대 높이

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // shrinkOffset이 0보다 크면 고정된 상태
    final isFixed = shrinkOffset > 0;
    return childBuilder(!isFixed);
  }

  @override
  bool shouldRebuild(covariant StickyHeaderDelegate oldDelegate) {
    return true; // 상태 변화를 감지할 수 있도록 true로 설정
  }
}
