import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class GlobalStoreBrandTile extends StatelessWidget {
  final GlobalShoppingStoreModel store;
  final VoidCallback onTap;
  final double? height;
  final double? width;

  const GlobalStoreBrandTile({
    super.key,
    required this.store,
    required this.onTap,
    this.height,
    this.width,
  });

  String? get _cardAsset {
    final name = store.name.toLowerCase();
    if (name.contains('aliexpress')) return Images.aliexpressCard;
    if (name.contains('alibaba')) return Images.alibabaCard;
    if (name.contains('amazon')) return Images.amazonCard;
    if (name.contains('shein')) return Images.sheinCard;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _cardAsset;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: asset != null
            ? Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackCard(context),
              )
            : _buildFallbackCard(context),
      ),
    );
  }

  Widget _buildFallbackCard(BuildContext context) {
    final name = store.name.toLowerCase();
    final List<Color> gradientColors;
    final String label;

    if (name.contains('aliexpress')) {
      gradientColors = const [Color(0xFFFF4840), Color(0xFFE4271A)];
      label = 'AliExpress';
    } else if (name.contains('alibaba')) {
      gradientColors = const [Color(0xFFFF841E), Color(0xFFFF5200)];
      label = 'Alibaba.com';
    } else if (name.contains('amazon')) {
      gradientColors = const [Color(0xFFFFB618), Color(0xFFFF9200)];
      label = 'amazon';
    } else if (name.contains('shein')) {
      gradientColors = const [Color(0xFF2E2E32), Color(0xFF161618)];
      label = 'SHEIN';
    } else {
      gradientColors = const [Color(0xFF015FC9), Color(0xFF032C75)];
      label = store.name;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Glossy sheen overlay
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
