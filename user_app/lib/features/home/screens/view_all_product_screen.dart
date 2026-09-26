import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/widgets/alline_product_listing_view.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';

class ViewAllProductScreen extends StatefulWidget {
  final ProductType productType;
  const ViewAllProductScreen({super.key, required this.productType});

  @override
  State<ViewAllProductScreen> createState() => _ViewAllProductScreenState();
}

class _ViewAllProductScreenState extends State<ViewAllProductScreen> {
  @override
  void initState() {
    super.initState();

    Provider.of<ProductController>(context, listen: false)
        .getAllProductModelByType(
      offset: 1,
      type: widget.productType,
      isUpdate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkTheme = Provider.of<ThemeController>(context).darkTheme;

    return Scaffold(
      backgroundColor:
          isDarkTheme ? Theme.of(context).scaffoldBackgroundColor : null,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
          title: getTranslated(_getTitle(widget.productType), context)),
      body: Consumer<ProductController>(
        builder: (context, productController, child) {
          final model = productController.allProductModel;
          return AllineProductListingView(
            key: PageStorageKey<String>('view-all-${widget.productType.name}'),
            products: model?.products ?? const [],
            totalSize: model?.totalSize,
            isLoading: model == null,
            searchQuery: '',
            onReload: () => productController.getAllProductModelByType(
              offset: 1,
              type: widget.productType,
            ),
            onLoadMore: () async {
              if (model?.totalSize != null &&
                  (model?.products?.length ?? 0) >= model!.totalSize!) {
                return;
              }
              await productController.getAllProductModelByType(
                offset: (model?.offset ?? 0) + 1,
                type: widget.productType,
              );
            },
          );
        },
      ),
    );
  }

  String _getTitle(ProductType productType) {
    switch (productType) {
      case ProductType.allProduct:
        return 'all_products';

      case ProductType.featuredProduct:
        return 'featured_product';

      case ProductType.justForYou:
        return 'just_for_you';

      default:
        return 'latest_product';
    }
  }
}
