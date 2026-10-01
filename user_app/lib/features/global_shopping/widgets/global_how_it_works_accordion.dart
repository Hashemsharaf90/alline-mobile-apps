import 'package:flutter/material.dart';

class GlobalHowItWorksAccordion extends StatefulWidget {
  const GlobalHowItWorksAccordion({super.key});

  @override
  State<GlobalHowItWorksAccordion> createState() => _GlobalHowItWorksAccordionState();
}

class _GlobalHowItWorksAccordionState extends State<GlobalHowItWorksAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Accordion Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.help_outline_rounded,
                      color: primaryBlue,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'كيف تتسوق عالمياً عبر Alline؟',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: navyColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: secondaryTextColor,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Body
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  const Divider(color: Color(0xFFF0F4FA), height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  _buildStepItem(
                    stepNumber: '1',
                    title: 'اختر متجراً أو منتجاً',
                    description: 'تصفح المتاجر الأربعة المتاحة أو ابحث عن المنتجات المعروضة.',
                    primaryBlue: primaryBlue,
                    navyColor: navyColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNumber: '2',
                    title: 'أضف الرابط',
                    description: 'إذا كان لديك رابط من خارج التطبيق، الصقه وسيقوم فريقنا بقراءة مواصفاته.',
                    primaryBlue: primaryBlue,
                    navyColor: navyColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 10),
                  _buildStepItem(
                    stepNumber: '3',
                    title: 'راجع التكلفة والطلب',
                    description: 'سنقدم لك السعر النهائي شاملاً الشحن والجمارك حتى باب منزلك بالريال اليمني قبل تأكيد الدفع.',
                    primaryBlue: primaryBlue,
                    navyColor: navyColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
    required Color primaryBlue,
    required Color navyColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: primaryBlue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'AllineTajawal',
                fontSize: 12,
                color: secondaryTextColor,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: navyColor,
                  ),
                ),
                TextSpan(text: description),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
