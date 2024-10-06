import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_forward_app/screens/login/cubit/auth_cubit.dart';
import 'package:sms_forward_app/screens/login/cubit/auth_segmented_control_cubit.dart';
import 'package:sms_forward_app/themes/colors.dart';

class CustomSegmentedControl extends StatelessWidget {
  final Map<AuthSegmentedControlState, Widget> children;
  final AuthSegmentedControlState groupValue;
  final ValueChanged<AuthSegmentedControlState> onValueChanged;

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
        children: children.keys.map((state) {
          final isSelected = groupValue == state;
          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(state),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(44),
                ),
                alignment: Alignment.center,
                child: children[state],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
