import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_sixvalley_ecommerce/features/global_shopping/domain/models/global_shopping_store_model.dart';

/// Displays a supplied store logo without synthesizing or redrawing a brand mark.
/// Unknown brands use a neutral storefront symbol instead.
class GlobalStoreLogoWidget extends StatelessWidget {
  final GlobalShoppingStoreModel? store;
  final String? storeName;
  final String? logoUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const GlobalStoreLogoWidget({
    super.key,
    this.store,
    this.storeName,
    this.logoUrl,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  String get _name => (store?.name ?? storeName ?? '').toLowerCase();
  String? get _resolvedLogoUrl => store?.logoUrl ?? logoUrl;

  @override
  Widget build(BuildContext context) {
    final localAsset = _assetPath;
    final url = _resolvedLogoUrl;
    final uri = url == null ? null : Uri.tryParse(url);
    final fallback = _assetOrPlaceholder(context);

    // Known brands use bundled, tightly-cropped assets so inconsistent API
    // images cannot render as tiny squares or oversized banners.
    if (localAsset != null) {
      return SizedBox(
        width: width,
        height: height,
        child: Image.asset(
          localAsset,
          fit: fit,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    }

    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      final image = uri.path.toLowerCase().endsWith('.svg')
          ? SvgPicture.network(
              url!,
              fit: fit,
              placeholderBuilder: (_) => fallback,
              errorBuilder: (_, __, ___) => fallback,
            )
          : CachedNetworkImage(
              imageUrl: url!,
              fit: fit,
              placeholder: (_, __) => fallback,
              errorWidget: (_, __, ___) => fallback,
            );
      return SizedBox(width: width, height: height, child: image);
    }

    return SizedBox(width: width, height: height, child: fallback);
  }

  Widget _assetOrPlaceholder(BuildContext context) {
    final asset = _assetPath;
    if (asset == null) return _placeholder(context);
    return Image.asset(
      asset,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(context),
    );
  }

  String? get _assetPath {
    if (_name.contains('amazon')) {
      return 'assets/images/global_amazon_logo.png';
    }
    if (_name.contains('shein')) {
      return 'assets/images/global_shein_logo.png';
    }
    if (_name.contains('aliexpress')) {
      return 'assets/images/global_aliexpress_logo.png';
    }
    if (_name.contains('alibaba')) {
      return 'assets/images/global_alibaba_logo.png';
    }
    return null;
  }

  Widget _placeholder(BuildContext context) => Center(
        child: Icon(
          Icons.storefront_outlined,
          size: height == null ? 26 : (height! * .62).clamp(18, 34).toDouble(),
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}
