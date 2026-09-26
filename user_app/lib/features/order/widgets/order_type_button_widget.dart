import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/alline_colors.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class OrderTypeButton extends StatelessWidget {
  final String? text;
  final int index;
  final IconData? icon;
  final String? count;

  const OrderTypeButton({
    super.key,
    required this.text,
    required this.index,
    this.icon,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, orderController, _) {
        final bool isSelected = orderController.orderTypeIndex == index;
        final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

        return InkWell(
          onTap: () => orderController.setIndex(index),
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AllineColors.primary
                  : (isDark ? Theme.of(context).cardColor : Colors.white),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isSelected ? AllineColors.primary : const Color(0xFFE1E8F2),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AllineColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? Colors.white : const Color(0xFF6D85AF),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  text ?? '',
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF071B49)),
                  ),
                ),
                if (count != null && count!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : AllineColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count!,
                      style: titilliumBold.copyWith(
                        fontSize: 10,
                        color: isSelected ? Colors.white : AllineColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}