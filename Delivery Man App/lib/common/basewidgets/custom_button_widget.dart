import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final Function? onTap;
  final String btnTxt;
  final bool isShowBorder, transparent, withIcon;
  final IconData? icon;
  const CustomButtonWidget(
      {super.key,
      this.onTap,
      required this.btnTxt,
      this.isShowBorder = false,
      this.transparent = false,
      this.withIcon = false,
      this.icon});
  @override
  Widget build(BuildContext context) {
    final child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (withIcon) ...[Icon(icon), const SizedBox(width: 8)],
          Flexible(child: Text(btnTxt, textAlign: TextAlign.center))
        ]);
    final callback = onTap == null ? null : () => onTap!();
    return SizedBox(
        width: double.infinity,
        child: transparent
            ? TextButton(onPressed: callback, child: child)
            : isShowBorder
                ? OutlinedButton(onPressed: callback, child: child)
                : ElevatedButton(onPressed: callback, child: child));
  }
}
