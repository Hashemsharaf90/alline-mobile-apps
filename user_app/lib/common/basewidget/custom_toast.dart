import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';

class CustomToast extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final SnackBarType sanckBarType;

  const CustomToast(
      {super.key,
      required this.text,
      this.backgroundColor = const Color(0xFF25282b),
      // sanckBarType == SnackBarType.success ?  Color(0xE608AE61) : sanckBarType == SnackBarType.warning ?  Color(0xE6334257) :  Color(0xE6334257),
      this.textColor = Colors.white,
      this.borderRadius = 30,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      required this.sanckBarType});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AllineThemeColors.of(context).surfaceElevated
                  : AllineThemeColors.of(context).textPrimary,
              borderRadius: BorderRadius.circular(AllineRadius.input),
              border: Border.all(
                color:
                    AllineThemeColors.of(context).border.withValues(alpha: .45),
              ),
            ),
            padding: padding,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                    sanckBarType == SnackBarType.success
                        ? Images.snackbarTickmark
                        : sanckBarType == SnackBarType.warning
                            ? Images.snackbarWarning
                            : Images.snackbarError,
                    width: 17,
                    height: 17),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Flexible(
                    child: Text(text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor, fontWeight: FontWeight.w600),
                        maxLines: 3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
