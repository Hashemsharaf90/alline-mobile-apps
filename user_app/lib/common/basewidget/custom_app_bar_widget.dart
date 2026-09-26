import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final bool showActionButton;
  final Function()? onBackPressed;
  final bool centerTitle;
  final double? fontSize;
  final bool showResetIcon;
  final Widget? reset;
  final bool showLogo;
  final Color? iconColor;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.isBackButtonExist = true,
      this.onBackPressed,
      this.centerTitle = true,
      this.showActionButton = true,
      this.fontSize,
      this.showResetIcon = false,
      this.reset,
      this.showLogo = false,
      this.iconColor});

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppBar(
            actions: showResetIcon ? [reset!] : [],
            toolbarHeight: 56,
            automaticallyImplyLeading: false,
            title: Text(title ?? '',
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis),
            centerTitle: centerTitle,
            excludeHeaderSemantics: true,
            titleSpacing: 0,
            elevation: 0,
            clipBehavior: Clip.none,
            leadingWidth: isBackButtonExist ? 56 : 120,
            leading: isBackButtonExist
                ? IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: iconColor ?? Theme.of(context).primaryColor),
                    onPressed: () => onBackPressed != null
                        ? onBackPressed!()
                        : Navigator.pop(context))
                : showLogo
                    ? Padding(
                        padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault),
                        child: SizedBox(
                            child: Image.asset(Images.logoWithNameImage)))
                    : const SizedBox()));
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
