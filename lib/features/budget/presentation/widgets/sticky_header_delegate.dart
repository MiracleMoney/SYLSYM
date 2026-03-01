import 'package:flutter/material.dart';

/// 고정 헤더 델리게이트
class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  const StickyHeaderDelegate({required this.childBuilder, this.height = 160});

  final Widget Function(bool showShadow) childBuilder;
  final double height;

  @override
  double get minExtent => height; // 최소 높이

  @override
  double get maxExtent => height; // 최대 높이

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
    return oldDelegate.childBuilder != childBuilder ||
        oldDelegate.height != height;
  }
}
