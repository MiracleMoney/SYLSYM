import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/sizes.dart';

/// 구글폼 신청 버튼 위젯
///
/// 초대코드 신청 구글폼을 여는 버튼입니다.
/// URL을 한 곳에서 관리하여 변경이 용이합니다.
class GoogleFormButton extends StatelessWidget {
  final String label;
  final bool isExpanded;
  final Size? minimumSize;
  final BorderSide? borderSide;
  final double? borderRadius;

  const GoogleFormButton({
    super.key,
    this.label = '코드 신청하기',
    this.isExpanded = true,
    this.minimumSize,
    this.borderSide,
    this.borderRadius,
  });

  /// 구글폼 URL (여기만 수정하면 모든 곳에 반영됨)
  static const String googleFormUrl =
      'https://docs.google.com/forms/d/e/1FAIpQLScuZW_JS9c7oIxRqtwqC1VOi11XBdgEw11n3AdzF80Fsjgevw/viewform?usp=sharing';

  Future<void> _openGoogleForm(BuildContext context) async {
    final Uri url = Uri.parse(googleFormUrl);

    try {
      final opened = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('구글폼을 열 수 없습니다')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('브라우저를 열 수 없습니다: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        minimumSize: minimumSize ?? const Size.fromHeight(56),
        side: borderSide ?? BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      onPressed: () => _openGoogleForm(context),
      icon: const Icon(Icons.send_outlined),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Gmarket_sans',
          fontWeight: FontWeight.w700,
          fontSize: Sizes.size16,
        ),
      ),
    );

    return isExpanded ? Expanded(child: button) : button;
  }
}
