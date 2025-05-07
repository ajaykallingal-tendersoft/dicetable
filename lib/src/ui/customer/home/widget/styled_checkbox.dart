import 'package:dicetable/src/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StyledCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;

  const StyledCheckbox({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  State<StyledCheckbox> createState() => _StyledCheckboxState();
}

class _StyledCheckboxState extends State<StyledCheckbox> {
  bool? _checked;

  @override
  void initState() {
    super.initState();
    _checked = widget.value;
  }

  @override
  void didUpdateWidget(covariant StyledCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _checked = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!_checked!);
          setState(() {
            _checked = !_checked!;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.all(6),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), // Rounded borders
          border: Border.all(
            color: AppColors.primary, // Border color
            width: 1.5,
          ),
          color: AppColors.primaryWhiteColor, // Fill color
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _checked!
              ?  Center(
            child: SvgPicture.asset('assets/svg/check.svg',fit: BoxFit.scaleDown,)
          )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}