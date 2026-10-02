import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextFieldWidget extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Color? fillColor;
  final int maxLines;
  final bool isPassword;
  final bool isCountryPicker;
  final bool isShowBorder;
  final bool isIcon;
  final bool isShowSuffixIcon;
  final bool isShowPrefixIcon;
  final bool noBg;
  final Function? onTap;
  final String? suffixIconUrl;
  final String? prefixIconUrl;
  final bool isSearch;
  final bool isDisable;
  final bool noPadding;
  final Function? onChanged;
  final TextStyle? textStyle;

  const CustomTextFieldWidget({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.fillColor,
    this.isCountryPicker = false,
    this.isShowBorder = false,
    this.isShowSuffixIcon = false,
    this.isShowPrefixIcon = false,
    this.onTap,
    this.isIcon = false,
    this.isPassword = false,
    this.suffixIconUrl,
    this.prefixIconUrl,
    this.isSearch = false,
    this.isDisable = true,
    this.noBg = false,
    this.noPadding = false,
    this.onChanged,
    this.textStyle,
  });

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      enabled: widget.isDisable,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: widget.textStyle ?? Theme.of(context).textTheme.bodyLarge,
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      textDirection: widget.inputType == TextInputType.phone ||
              widget.inputType == TextInputType.number
          ? TextDirection.ltr
          : null,
      cursorColor: scheme.primary,
      obscureText: widget.isPassword && _obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: widget.fillColor ?? scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: scheme.onSurfaceVariant),
        prefixIcon: (widget.isShowPrefixIcon || widget.noBg) &&
                widget.prefixIconUrl != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(widget.prefixIconUrl!,
                    width: 20, height: 20, color: scheme.primary))
            : null,
        suffixIcon: widget.isShowSuffixIcon && widget.isPassword
            ? IconButton(
                tooltip: (_obscureText ? 'show_password' : 'hide_password').tr,
                icon: Icon(_obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: _toggle)
            : widget.isShowSuffixIcon &&
                    widget.isIcon &&
                    widget.suffixIconUrl != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(widget.suffixIconUrl!,
                        width: 20, height: 20))
                : null,
      ),
      onTap: widget.onTap as void Function()?,
      onSubmitted: (_) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
      },
      onChanged: widget.onChanged as void Function(String)?,
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
}
