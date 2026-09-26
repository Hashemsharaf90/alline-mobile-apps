import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/category_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/category_asset_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/theme/custom_theme_colors.dart';

class CategoryCardWidget extends StatelessWidget {
  final CategoryModel category;

  const CategoryCardWidget({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AllineThemeColors.of(context);
    // 1. Resolve photo source: local HD asset or remote URL
    final String? localAsset = CategoryAssetHelper.getAssetForCategory(
      id: category.id,
      name: category.name,
      slug: category.slug,
    );

    final bool isSpecificAsset = localAsset != null &&
        localAsset != Images.category &&
        localAsset.isNotEmpty;

    final String? remoteUrl = category.imageFullUrl?.path;
    final bool hasValidRemoteUrl = remoteUrl != null &&
        remoteUrl.trim().isNotEmpty &&
        !remoteUrl.contains('placeholder');

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
          width: 1.2,
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: colors.textPrimary.withValues(alpha: .05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Background Photograph or Neutral Fallback
            _buildCardImage(
              isSpecificAsset: isSpecificAsset,
              localAsset: localAsset,
              hasValidRemoteUrl: hasValidRemoteUrl,
              remoteUrl: remoteUrl,
            ),

            // Layer 2: Gradient Text Scrim at the bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 28, 12, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x2E071B49), // rgba(#071B49, 0.18)
                      Color(0x9E071B49), // rgba(#071B49, 0.62)
                      Color(0xD9071B49), // rgba(#071B49, 0.85)
                    ],
                    stops: [0.0, 0.32, 0.72, 1.0],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category Name
                    Text(
                      category.name ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontFamily: 'AllineTajawal',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFFFFFF),
                        height: 1.25,
                      ),
                    ),

                    // Optional Item Count Subtext
                    if (category.totalProductCount != null &&
                        category.totalProductCount! > 0) ...[
                      const SizedBox(height: 3),
                      Text(
                        '${category.totalProductCount} ${getTranslated('products', context) ?? 'منتج'}',
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontFamily: 'AllineTajawal',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xD9FFFFFF), // rgba(#FFFFFF, 0.85)
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Layer 3: Interactive InkWell Tap Layer
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  splashColor: const Color(0x26015FC9),
                  highlightColor: const Color(0x14015FC9),
                  onTap: () {
                    RouterHelper.getBrandCategoryRoute(
                      action: RouteAction.push,
                      isBrand: false,
                      id: category.id,
                      name: category.name,
                      categoryModel: category,
                      isAllProduct: true,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage({
    required bool isSpecificAsset,
    required String? localAsset,
    required bool hasValidRemoteUrl,
    required String? remoteUrl,
  }) {
    // Priority 1: High-res local asset mapped to this category taxonomy
    if (isSpecificAsset && localAsset != null) {
      return Image.asset(
        localAsset,
        fit: BoxFit.cover,
        cacheWidth: 450,
        cacheHeight: 550,
        errorBuilder: (context, error, stackTrace) {
          if (hasValidRemoteUrl && remoteUrl != null) {
            return _buildNetworkImage(remoteUrl);
          }
          return _buildNeutralPlaceholder();
        },
      );
    }

    // Priority 2: Remote URL uploaded in backend
    if (hasValidRemoteUrl && remoteUrl != null) {
      return _buildNetworkImage(remoteUrl);
    }

    // Fallback: Neutral soft-blue background with no text or generic icons
    return _buildNeutralPlaceholder();
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: 450,
      memCacheHeight: 550,
      placeholder: (context, url) => _buildNeutralPlaceholder(),
      errorWidget: (context, url, error) => _buildNeutralPlaceholder(),
    );
  }

  /// Clean, neutral soft-blue card background without icons or text
  Widget _buildNeutralPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF4F8FE),
            Color(0xFFEBF2FA),
          ],
        ),
      ),
    );
  }
}
