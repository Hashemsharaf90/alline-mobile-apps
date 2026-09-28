import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool isPassword;
  final bool isOptional;
  final Widget? prefixWidget;
  final IconData? prefixIcon;
  final String? errorText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;

  const AllineTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.isPassword = false,
    this.isOptional = false,
    this.prefixWidget,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled = true,
  });

  @override
  State<AllineTextField> createState() => _AllineTextFieldState();
}

class _AllineTextFieldState extends State<AllineTextField> {
  bool _obscureText = true;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _internalFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Row
        Row(
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ColorResources.getTextTitle(context),
              ),
            ),
            if (widget.isOptional) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isDark ? AllineColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'اختياري',
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),

        // Input Box
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 50,
          decoration: BoxDecoration(
            color: widget.enabled
                ? (isDark ? AllineColors.darkCard : AllineColors.white)
                : (isDark ? const Color(0xFF161F36) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? AllineColors.error
                  : (_isFocused ? AllineColors.primary : ColorResources.getBorder(context)),
              width: _isFocused || hasError ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AllineColors.primary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AllineColors.primaryDark.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Prefix Icon / Widget
              if (widget.prefixWidget != null) ...[
                widget.prefixWidget!,
              ] else if (widget.prefixIcon != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 14, end: 8),
                  child: Icon(
                    widget.prefixIcon,
                    size: 18,
                    color: _isFocused
                        ? AllineColors.primary
                        : ColorResources.getTextSubTitle(context),
                  ),
                ),
              ] else ...[
                const SizedBox(width: 14),
              ],

              // Native TextField
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _internalFocusNode,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  obscureText: widget.isPassword ? _obscureText : false,
                  enabled: widget.enabled,
                  inputFormatters: widget.inputFormatters,
                  onChanged: widget.onChanged,
                  onSubmitted: (v) {
                    if (widget.nextFocus != null) {
                      FocusScope.of(context).requestFocus(widget.nextFocus);
                    } else if (widget.onSubmitted != null) {
                      widget.onSubmitted!(v);
                    }
                  },
                  style: TextStyle(
                    fontFamily: 'AllineTajawal',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorResources.getTextTitle(context),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              // Suffix (Password show/hide toggle)
              if (widget.isPassword) ...[
                IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 19,
                    color: ColorResources.getTextSubTitle(context),
                  ),
                  splashRadius: 20,
                ),
              ] else ...[
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),

        // Error String
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 13,
                  color: AllineColors.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      fontFamily: 'AllineTajawal',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AllineColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
