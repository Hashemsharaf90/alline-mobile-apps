import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_tokens.dart';

class CustomButton extends StatelessWidget {
  final Function()? onTap;
  final String? buttonText;
  final bool isBuy;
  final bool isBorder;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final Color? loadingColor;
  final double? radius;
  final double? fontSize;
  final String? leftIcon;
  final double? borderWidth;
  final bool isLoading;
  final String? loadingText;
  final double buttonHeight;

  const CustomButton({
    super.key,
    this.onTap,
    required this.buttonText,
    this.isBuy = false,
    this.isBorder = false,
    this.backgroundColor,
    this.radius,
    this.textColor,
    this.fontSize,
    this.leftIcon,
    this.borderColor,
    this.loadingColor = Colors.white,
    this.borderWidth,
    this.isLoading = false,
    this.loadingText,
    this.buttonHeight = AllineTouchTarget.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = radius ?? AllineRadius.button;
    final foreground = textColor ??
        (isBorder
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onPrimary);
    final content = isLoading
        ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  loadingColor ?? foreground,
                ),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: AllineSpacing.sm),
            Text(loadingText ?? getTranslated('loading', context) ?? '...'),
          ])
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (leftIcon != null) ...[
              Image.asset(leftIcon!, width: 22, height: 22),
              const SizedBox(width: AllineSpacing.xs),
            ],
            Flexible(
              child: Text(
                buttonText ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ]);

    return Semantics(
      button: true,
      enabled: onTap != null && !isLoading,
      child: SizedBox(
        width: double.infinity,
        height: buttonHeight < AllineTouchTarget.minimum
            ? AllineTouchTarget.minimum
            : buttonHeight,
        child: isBorder
            ? OutlinedButton(
                onPressed: isLoading ? null : onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: foreground,
                  side: BorderSide(
                    color: borderColor ?? Theme.of(context).colorScheme.outline,
                    width: borderWidth ?? 1,
                  ),
                  textStyle: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: fontSize),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(effectiveRadius),
                  ),
                ),
                child: content,
              )
            : FilledButton(
                onPressed: isLoading ? null : onTap,
                style: FilledButton.styleFrom(
                  backgroundColor:
                      backgroundColor ?? Theme.of(context).colorScheme.primary,
                  foregroundColor: foreground,
                  textStyle: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontSize: fontSize),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(effectiveRadius),
                  ),
                ),
                child: content,
              ),
      ),
    );
  }
}
