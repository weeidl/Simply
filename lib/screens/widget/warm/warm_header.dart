import 'package:flutter/material.dart';
import 'package:simply/themes/colors.dart';
import 'package:simply/themes/text_style.dart';

/// Big screen header used at the top of the warm screens — small eyebrow
/// label above the bold display title, with optional trailing widget.
class WarmHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const WarmHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 8, 20, 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null)
                  Text(eyebrow!,
                      style: AppTextStyle.bodySm(AppColor.inkTertiary)),
                if (eyebrow != null) const SizedBox(height: 4),
                Text(title, style: AppTextStyle.display(AppColor.ink)),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}
