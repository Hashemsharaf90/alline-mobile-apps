import 'package:flutter/material.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class AllineStepIndicator extends StatelessWidget {
  final int currentStep; // 0: الحساب, 1: بيانات المتجر, 2: التحقق, 3: المراجعة

  const AllineStepIndicator({
    super.key,
    this.currentStep = 0,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ['الحساب', 'بيانات المتجر', 'التحقق', 'المراجعة'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Divider connector
            final stepBefore = index ~/ 2;
            final isCompleted = stepBefore < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AllineColors.primary
                      : ColorResources.getBorder(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle Node
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AllineColors.primary
                      : (isActive ? AllineColors.primary : Colors.transparent),
                  border: Border.all(
                    color: isCompleted || isActive
                        ? AllineColors.primary
                        : ColorResources.getBorder(context),
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AllineColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 13,
                          color: Colors.white,
                        )
                      : Container(
                          width: isActive ? 6 : 0,
                          height: isActive ? 6 : 0,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive
                      ? AllineColors.primary
                      : ColorResources.getTextSubTitle(context),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
