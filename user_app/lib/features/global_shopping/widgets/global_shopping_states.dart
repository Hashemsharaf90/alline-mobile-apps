import 'package:flutter/material.dart';

class GlobalShoppingSkeletonWidget extends StatefulWidget {
  const GlobalShoppingSkeletonWidget({super.key});

  @override
  State<GlobalShoppingSkeletonWidget> createState() => _GlobalShoppingSkeletonWidgetState();
}

class _GlobalShoppingSkeletonWidgetState extends State<GlobalShoppingSkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    double borderRadius = 16,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0).withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Banner Skeleton
          _shimmerBox(width: double.infinity, height: 160, borderRadius: 24),
          const SizedBox(height: 16),

          // Search & Link Row Skeleton
          Row(
            children: [
              Expanded(flex: 3, child: _shimmerBox(width: double.infinity, height: 48, borderRadius: 16)),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: _shimmerBox(width: double.infinity, height: 48, borderRadius: 16)),
            ],
          ),
          const SizedBox(height: 20),

          // Stores 2x2 Grid Skeleton
          _shimmerBox(width: 120, height: 16, borderRadius: 6),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.36,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => _shimmerBox(width: double.infinity, height: double.infinity, borderRadius: 16),
          ),
          const SizedBox(height: 20),

          // Filter Chips Skeleton
          Row(
            children: [
              _shimmerBox(width: 50, height: 32, borderRadius: 20),
              const SizedBox(width: 6),
              _shimmerBox(width: 70, height: 32, borderRadius: 20),
              const SizedBox(width: 6),
              _shimmerBox(width: 65, height: 32, borderRadius: 20),
              const SizedBox(width: 6),
              _shimmerBox(width: 75, height: 32, borderRadius: 20),
            ],
          ),
          const SizedBox(height: 14),

          // Products 2 Cards Skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.68,
            ),
            itemCount: 2,
            itemBuilder: (_, __) => _shimmerBox(width: double.infinity, height: double.infinity, borderRadius: 16),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class GlobalShoppingEmptyWidget extends StatelessWidget {
  final VoidCallback onAddLinkTap;
  final VoidCallback onBrowseStoresTap;

  const GlobalShoppingEmptyWidget({
    super.key,
    required this.onAddLinkTap,
    required this.onBrowseStoresTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDBEAFE)),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 38,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد منتجات معروضة حالياً',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: navyColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ابدأ باستكشاف المتاجر العالمية أو أضف رابط منتج للبحث عن منتج معين وسنقوم بتوفيره لك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onBrowseStoresTap,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: borderColor, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'تصفّح المتاجر',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: navyColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onAddLinkTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.add_link_rounded, size: 17, color: Colors.white),
                    label: const Text(
                      'أضف رابط منتج',
                      style: TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GlobalShoppingErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const GlobalShoppingErrorWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF015FC9);
    const borderColor = Color(0xFFE1E8F2);
    const navyColor = Color(0xFF071B49);
    const secondaryTextColor = Color(0xFF6D85AF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Color(0xFFD9363E),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'تعذّر تحميل المنتجات',
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: navyColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'حدث خطأ أثناء تحميل بيانات المنتجات العالمية. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'AllineTajawal',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: secondaryTextColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20, color: Colors.white),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: 'AllineTajawal',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
