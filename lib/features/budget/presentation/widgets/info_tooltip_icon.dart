import 'package:flutter/material.dart';

/// 정보를 표시하는 툴팁 아이콘 위젯
class InfoTooltipIcon extends StatefulWidget {
  const InfoTooltipIcon({super.key, required this.message});

  final String message;

  @override
  State<InfoTooltipIcon> createState() => _InfoTooltipIconState();
}

class _InfoTooltipIconState extends State<InfoTooltipIcon> {
  OverlayEntry? _overlayEntry;

  void _toggle(BuildContext context) {
    if (_overlayEntry != null) {
      _hide();
    } else {
      _show(context);
    }
  }

  void _show(BuildContext context) {
    final box = context.findRenderObject() as RenderBox;
    final iconPos = box.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // 투명 배리어 - 외부 탭 시 닫힘
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hide,
            ),
          ),
          // 말풍선
          Positioned(
            left: iconPos.dx - 120,
            top: iconPos.dy - 44,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontFamily: 'Gmarket_sans',
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
    );
  }
}
