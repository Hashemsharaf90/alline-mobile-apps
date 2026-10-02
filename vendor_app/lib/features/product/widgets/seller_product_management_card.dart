import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_image_widget.dart';
import 'package:sixvalley_vendor_app/features/addProduct/screens/add_product_tab_view_screen.dart';
import 'package:sixvalley_vendor_app/features/product/controllers/product_controller.dart';
import 'package:sixvalley_vendor_app/features/product/domain/models/product_model.dart';
import 'package:sixvalley_vendor_app/features/product_details/screens/product_details_screen.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/utill/color_resources.dart';

class SellerProductManagementCard extends StatelessWidget {
  const SellerProductManagementCard({
    super.key,
    required this.product,
    required this.onChanged,
  });

  final Product product;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final border = ColorResources.getBorder(context);
    final secondary = ColorResources.getTextSubTitle(context);
    final title = ColorResources.getTextTitle(context);
    final int stock = product.currentStock ?? 0;
    final bool isDigital = product.productType == 'digital';
    final bool isOutOfStock = !isDigital && stock <= 0;
    final bool isActive = product.status == 1;
    final Color stockColor = isOutOfStock
        ? ColorResources.getError(context)
        : ColorResources.getSuccess(context);
    final Color statusColor = isActive
        ? ColorResources.getSuccess(context)
        : secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productModel: product),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: CustomImageWidget(
                      image: product.thumbnailFullUrl?.path ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name?.trim().isNotEmpty == true
                                  ? product.name!.trim()
                                  : 'منتج بدون اسم',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: title,
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'AllineTajawal',
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              tooltip: 'إجراءات المنتج',
                              padding: EdgeInsets.zero,
                              icon: Icon(Icons.more_horiz, color: secondary),
                              onPressed: () => _showActions(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        PriceConverter.convertPrice(context, product.unitPrice),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF015FC9),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'AllineTajawal',
                        ),
                      ),
                      const SizedBox(height: 7),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          _MetaStatus(
                            color: stockColor,
                            label: isDigital
                                ? 'منتج رقمي'
                                : isOutOfStock
                                    ? 'نفد المخزون'
                                    : 'المخزون: $stock',
                          ),
                          _MetaStatus(
                            color: statusColor,
                            label: isActive ? 'نشط' : 'غير نشط',
                          ),
                        ],
                      ),
                      if (product.requestStatus == 0 ||
                          product.requestStatus == 2) ...[
                        const SizedBox(height: 6),
                        _MetaStatus(
                          color: product.requestStatus == 2
                              ? ColorResources.getError(context)
                              : ColorResources.getWarning(context),
                          label: product.requestStatus == 2
                              ? 'مرفوض'
                              : 'قيد المراجعة',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorResources.getBorder(sheetContext),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'إدارة المنتج',
                style: TextStyle(
                  color: ColorResources.getTextTitle(sheetContext),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'AllineTajawal',
                ),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                icon: Icons.edit_outlined,
                label: 'تعديل المنتج',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductTabView(
                        product: product,
                        fromHome: false,
                      ),
                    ),
                  ).then((_) => onChanged());
                },
              ),
              _ActionTile(
                icon: Icons.open_in_new_rounded,
                label: 'عرض التفاصيل',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsScreen(productModel: product),
                    ),
                  );
                },
              ),
              const Divider(height: 12),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                label: 'حذف المنتج',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(sheetContext);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'حذف المنتج؟',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'AllineTajawal', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'هل أنت متأكد من حذف هذا المنتج؟ لا يمكن التراجع عن هذا الإجراء.',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'AllineTajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD9363E)),
            onPressed: () async {
              final deleted = await Provider.of<ProductController>(context, listen: false)
                  .deleteProduct(context, product.id);
              if (deleted) await onChanged();
            },
            child: const Text(
              'حذف',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaStatus extends StatelessWidget {
  const _MetaStatus({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: ColorResources.getTextSubTitle(context),
              fontSize: 11,
              fontFamily: 'AllineTajawal',
            ),
          ),
        ],
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? ColorResources.getError(context)
        : ColorResources.getTextTitle(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: 28,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'AllineTajawal',
        ),
      ),
      onTap: onTap,
    );
  }
}
