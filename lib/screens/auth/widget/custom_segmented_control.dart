import 'package:flutter/material.dart';
import 'package:simply/screens/auth/cubit/auth_cubit.dart';
import 'package:simply/themes/colors.dart';

class CustomSegmentedControl extends StatelessWidget {
  final Map<AuthStatus, Widget> children;
  final AuthStatus groupValue;
  final ValueChanged<AuthStatus> onValueChanged;

  const CustomSegmentedControl({
    Key? key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.greyLight,
        borderRadius: BorderRadius.circular(44),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children.keys.map((status) {
          final isSelected = groupValue == status;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(status),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(44),
                ),
                alignment: Alignment.center,
                child: children[status],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
