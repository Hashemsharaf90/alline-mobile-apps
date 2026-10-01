import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/data_source_enum.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/category/domain/models/find_what_you_need.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/home_category_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/most_demanded_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/models/product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/services/product_service_interface.dart';
import 'package:flutter_sixvalley_ecommerce/helper/api_checker.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/helper/data_sync_helper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';

class ProductController extends ChangeNotifier {
  final ProductServiceInterface? productServiceInterface;
  ProductController({required this.productServiceInterface});

  ProductType _selectedProductType = ProductType.newArrival;

  ProductType get productType => _selectedProductType;

  Product? _recommendedProduct;
  Product? get recommendedProduct => _recommendedProduct;

  ProductModel? _discountedProductModel;
  ProductModel? get discountedProductModel => _discountedProductModel;

  ProductModel? _selectedProductModel;
  ProductModel? get selectedProductModel => _selectedProductModel;

  ProductModel? _allProductModel;
  ProductModel? get allProductModel => _allProductModel;

  ProductModel? _homeAllProductModel;
  ProductModel? get homeAllProductModel => _homeAllProductModel;
  bool _isHomeAllProductLoading = false;
  bool get isHomeAllProductLoading => _isHomeAllProductLoading;
  bool _isHomeAllProductLoadingMore = false;
  bool get isHomeAllProductLoadingMore => _isHomeAllProductLoadingMore;
  bool _hasHomeAllProductError = false;
  bool get hasHomeAllProductError => _hasHomeAllProductError;

  ProductModel? _latestProductModel;
  ProductModel? get latestProductModel => _latestProductModel;

  ProductModel? _homeBestSellingModel;
  ProductModel? get homeBestSellingModel => _homeBestSellingModel;

  Future<void> getHomeBestSellingProducts({bool reload = false}) async {
    if (_homeBestSellingModel != null && !reload) return;
    try {
      final response =
          await productServiceInterface?.getProductModelByType<Response>(
              offset: 1,
              productType: ProductType.bestSelling,
              source: DataSourceEnum.client);
      if (response?.response?.statusCode == 200) {
        _homeBestSellingModel = ProductModel.fromJson(response!.response!.data);
      }
    } catch (_) {
      // Optional discovery content must not block the rest of Home.
    }
    _homeBestSellingModel ??= ProductModel(products: []);
    notifyListeners();
  }

  ProductModel? _featuredProductModel;
  ProductModel? get featuredProductModel => _featuredProductModel;

  ProductModel? _supermarketProductModel;
  ProductModel? get supermarketProductModel => _supermarketProductModel;
  bool _supermarketLoading = false;
  bool _supermarketHasError = false;
  bool get supermarketLoading => _supermarketLoading;
  bool get supermarketHasError => _supermarketHasError;

  List<dynamic> _nearbySupermarkets = [];
  List<dynamic> get nearbySupermarkets => _nearbySupermarkets;

  String? _supermarketLatitude;
  String? get supermarketLatitude => _supermarketLatitude;

  String? _supermarketLongitude;
  String? get supermarketLongitude => _supermarketLongitude;

  bool _supermarketUsingCurrentLocation = false;
  bool get supermarketUsingCurrentLocation => _supermarketUsingCurrentLocation;

  bool _nearbySupermarketLoading = false;
  bool get nearbySupermarketLoading => _nearbySupermarketLoading;
  bool _nearbySupermarketHasError = false;
  bool get nearbySupermarketHasError => _nearbySupermarketHasError;

  final List<HomeCategoryProduct> _homeCategoryProductList = [];
  List<HomeCategoryProduct> get homeCategoryProductList =>
      _homeCategoryProductList;

  MostDemandedProductModel? _mostDemandedProductModel;
  MostDemandedProductModel? get mostDemandedProductModel =>
      _mostDemandedProductModel;

  FindWhatYouNeedModel? _findWhatYouNeedModel;
  FindWhatYouNeedModel? get findWhatYouNeedModel => _findWhatYouNeedModel;

  ProductModel? _clearanceProductModel;
  ProductModel? get clearanceProductModel => _clearanceProductModel;

  bool filterApply = false;

  String? _searchText;
  String? get searchText => _searchText;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  String? _categorySearchProductText;
  String? get categorySearchProductText => _categorySearchProductText;

  void isFilterApply(bool apply, {bool reload = false}) {
    filterApply = apply;
    if (reload) {
      notifyListeners();
    }
  }

  Future<void> getSelectedProductModel(int offset,
      {bool isUpdate = true}) async {
    if (offset == 1) {
      _selectedProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: productType,
            source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: productType,
            source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _selectedProductModel = ProductModel.fromJson(data);
          } catch (e) {
            _selectedProductModel = ProductModel(offset: 1, products: []);
          }
          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getProductModelByType<Response>(
              offset: offset,
              productType: _selectedProductType,
              source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        _selectedProductModel?.totalSize = parsedProductModel.totalSize;
        _selectedProductModel?.offset = parsedProductModel.offset;
        _selectedProductModel?.products
            ?.addAll(parsedProductModel.products ?? []);
        notifyListeners();
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
    }
  }

  Future<void> getAllProductModelByType(
      {required int offset,
      required ProductType type,
      bool isUpdate = true}) async {
    if (offset == 1) {
      _allProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!.getProductModelByType(
            offset: offset, productType: type, source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!.getProductModelByType(
            offset: offset, productType: type, source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _allProductModel = ProductModel.fromJson(data);
          } catch (e) {
            _allProductModel = ProductModel(products: [], offset: offset);
          }
          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getProductModelByType<Response>(
              offset: offset, productType: type, source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        final existingIds = _allProductModel?.products
                ?.map((product) => product.id)
                .whereType<int>()
                .toSet() ??
            <int>{};
        final newProducts = (parsedProductModel.products ?? [])
            .where(
                (product) => product.id == null || existingIds.add(product.id!))
            .toList();

        _allProductModel?.totalSize = parsedProductModel.totalSize;
        _allProductModel?.offset = parsedProductModel.offset ?? offset;
        _allProductModel?.products?.addAll(newProducts);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  Future<void> getHomeAllProductList(int offset, {bool reload = false}) async {
    if (offset == 1) {
      if (_homeAllProductModel != null && !reload) return;
      _isHomeAllProductLoading = true;
      if (reload) {
        _homeAllProductModel = null;
      }
      notifyListeners();

      await DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!.getProductModelByType(
          offset: offset,
          productType: ProductType.allProduct,
          source: DataSourceEnum.local,
        ),
        fetchFromClient: () => productServiceInterface!.getProductModelByType(
          offset: offset,
          productType: ProductType.allProduct,
          source: DataSourceEnum.client,
        ),
        onResponse: (data, source) {
          try {
            final parsed = ProductModel.fromJson(data);
            final unique = <int>{};
            final initialProducts = (parsed.products ?? [])
                .where((p) => p.id == null || unique.add(p.id!))
                .toList();
            _homeAllProductModel = ProductModel(
              totalSize: parsed.totalSize,
              limit: parsed.limit,
              offset: parsed.offset ?? offset,
              products: initialProducts,
            );
          } catch (e) {
            _homeAllProductModel = ProductModel(products: [], offset: offset);
          }
          if (source == DataSourceEnum.client) {
            _isHomeAllProductLoading = false;
          }
          notifyListeners();
        },
      );
      _isHomeAllProductLoading = false;
      notifyListeners();
    } else {
      if (_isHomeAllProductLoadingMore) return;
      if (_homeAllProductModel?.totalSize != null &&
          (_homeAllProductModel?.products?.length ?? 0) >=
              _homeAllProductModel!.totalSize!) {
        return;
      }
      _isHomeAllProductLoadingMore = true;
      _hasHomeAllProductError = false;
      notifyListeners();

      try {
        final ApiResponseModel? apiResponse =
            await productServiceInterface?.getProductModelByType<Response>(
          offset: offset,
          productType: ProductType.allProduct,
          source: DataSourceEnum.client,
        );

        if (apiResponse?.response?.statusCode == 200) {
          final ProductModel parsedProductModel =
              ProductModel.fromJson(apiResponse?.response?.data);

          final existingIds = _homeAllProductModel?.products
                  ?.map((product) => product.id)
                  .whereType<int>()
                  .toSet() ??
              <int>{};
          final newProducts = (parsedProductModel.products ?? [])
              .where((product) =>
                  product.id == null || existingIds.add(product.id!))
              .toList();

          _homeAllProductModel?.totalSize = parsedProductModel.totalSize;
          _homeAllProductModel?.offset = parsedProductModel.offset ?? offset;
          _homeAllProductModel?.products?.addAll(newProducts);
          if ((parsedProductModel.products ?? []).isEmpty) {
            _homeAllProductModel?.totalSize =
                _homeAllProductModel?.products?.length ?? 0;
          }
        } else {
          _hasHomeAllProductError = true;
        }
      } catch (e) {
        _hasHomeAllProductError = true;
      }

      _isHomeAllProductLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getLatestProductList(int offset, {bool isUpdate = false}) async {
    if (offset == 1) {
      _latestProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: ProductType.latestProduct,
            source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: ProductType.latestProduct,
            source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _latestProductModel = ProductModel.fromJson(data);
          } catch (e) {
            _latestProductModel = ProductModel(offset: offset, products: []);
          }
          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getProductModelByType<Response>(
              offset: offset,
              productType: ProductType.latestProduct,
              source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        _latestProductModel?.totalSize = parsedProductModel.totalSize;
        _latestProductModel?.offset = parsedProductModel.offset;
        _latestProductModel?.products
            ?.addAll(parsedProductModel.products ?? []);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  Future<void> getSupermarketProductList(int offset,
      {bool isUpdate = false, String? latitude, String? longitude}) async {
    if (_supermarketLoading) return;
    _supermarketLoading = true;
    _supermarketHasError = false;
    notifyListeners();
    try {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getSupermarketProductList(
        offset.toString(),
        latitude: latitude,
        longitude: longitude,
      );

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        if (offset == 1 || _supermarketProductModel == null) {
          _supermarketProductModel = parsedProductModel;
        } else {
          _supermarketProductModel?.totalSize = parsedProductModel.totalSize;
          _supermarketProductModel?.offset = parsedProductModel.offset;
          _supermarketProductModel?.products
              ?.addAll(parsedProductModel.products ?? []);
        }
      } else if (apiResponse != null) {
        _supermarketHasError = true;
        ApiChecker.checkApi(apiResponse);
      } else {
        _supermarketHasError = true;
      }
    } catch (_) {
      _supermarketHasError = true;
    } finally {
      _supermarketLoading = false;
      notifyListeners();
    }
  }

  Future<void> getNearbySupermarkets(
      {bool isUpdate = false, String? latitude, String? longitude}) async {
    _nearbySupermarketLoading = true;
    _nearbySupermarketHasError = false;
    if (isUpdate) {
      notifyListeners();
    }

    try {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getNearbySupermarkets(
        latitude: latitude,
        longitude: longitude,
      );

      if (apiResponse?.response?.statusCode == 200) {
        final data = apiResponse?.response?.data;
        if (data is Map && data['stores'] is List) {
          _nearbySupermarkets = List<dynamic>.from(data['stores']);
        } else {
          _nearbySupermarkets = [];
        }
      } else {
        _nearbySupermarketHasError = true;
        if (apiResponse != null) {
          ApiChecker.checkApi(apiResponse);
        }
      }
    } catch (_) {
      _nearbySupermarketHasError = true;
    } finally {
      _nearbySupermarketLoading = false;
      notifyListeners();
    }
  }

  void setSupermarketLocationSource({
    String? latitude,
    String? longitude,
    bool usingCurrentLocation = false,
    bool isUpdate = false,
  }) {
    _supermarketLatitude = latitude;
    _supermarketLongitude = longitude;
    _supermarketUsingCurrentLocation = usingCurrentLocation;

    if (isUpdate) {
      notifyListeners();
    }
  }

  void onChangeSelectedProductType(ProductType type) {
    _selectedProductType = type;

    getSelectedProductModel(1);

    notifyListeners();
  }

  TextEditingController sellerProductSearch = TextEditingController();
  void clearSearchField(String id) {
    sellerProductSearch.clear();
    notifyListeners();
  }

  ProductModel? _brandOrCategoryProductList;

  ProductModel? get brandOrCategoryProductList => _brandOrCategoryProductList;

  Future<void> initBrandOrCategoryProductList(
      {required bool isBrand,
      required int? id,
      String searchProduct = '',
      required int offset,
      bool isUpdate = true}) async {
    if (offset == 1) {
      _brandOrCategoryProductList = null;
    }
    if (isUpdate) {
      notifyListeners();
    }

    ApiResponseModel apiResponse = await productServiceInterface!
        .getBrandOrCategoryProductList(
            isBrand: isBrand,
            id: id!,
            searchProduct: searchProduct,
            offset: offset);

    if (apiResponse.response?.statusCode == 200) {
      if (offset == 1) {
        _brandOrCategoryProductList =
            ProductModel.fromJson(apiResponse.response?.data);
      } else {
        final page = ProductModel.fromJson(apiResponse.response?.data);
        final existingIds = _brandOrCategoryProductList?.products
                ?.map((product) => product.id)
                .whereType<int>()
                .toSet() ??
            <int>{};
        final uniquePage = (page.products ?? [])
            .where(
                (product) => product.id == null || existingIds.add(product.id!))
            .toList();
        _brandOrCategoryProductList?.products?.addAll(uniquePage);
        _brandOrCategoryProductList?.offset = page.offset ?? offset;
        _brandOrCategoryProductList?.totalSize = page.totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    notifyListeners();
  }

  List<Product>? _relatedProductList;
  List<Product>? get relatedProductList => _relatedProductList;

  void initRelatedProductList(String id, BuildContext context) async {
    ApiResponseModel apiResponse =
        await productServiceInterface!.getRelatedProductList(id);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _relatedProductList = [];
      apiResponse.response!.data.forEach(
          (product) => _relatedProductList!.add(Product.fromJson(product)));
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void getMoreProductList(String id) async {
    ApiResponseModel apiResponse =
        await productServiceInterface!.getRelatedProductList(id);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      _relatedProductList = [];
      apiResponse.response!.data.forEach(
          (product) => _relatedProductList!.add(Product.fromJson(product)));
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void removePrevRelatedProduct() {
    _relatedProductList = null;
  }

  Future<void> getFeaturedProductModel(int offset,
      {bool isUpdate = false}) async {
    if (offset == 1) {
      _featuredProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: ProductType.featuredProduct,
            source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: ProductType.featuredProduct,
            source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _featuredProductModel = ProductModel.fromJson(data);
          } catch (e) {
            _featuredProductModel = ProductModel(products: [], offset: 1);
          }

          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getProductModelByType<Response>(
              offset: offset,
              productType: ProductType.featuredProduct,
              source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        _featuredProductModel?.totalSize = parsedProductModel.totalSize;
        _featuredProductModel?.offset = parsedProductModel.offset;
        _featuredProductModel?.products
            ?.addAll(parsedProductModel.products ?? []);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  Future<void> getRecommendedProduct() async {
    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => productServiceInterface!
          .getRecommendedProduct(source: DataSourceEnum.local),
      fetchFromClient: () => productServiceInterface!
          .getRecommendedProduct(source: DataSourceEnum.client),
      onResponse: (data, source) {
        try {
          if (data is List) {
            _recommendedProduct = Product(id: -1);
          } else {
            _recommendedProduct = Product.fromJson(data);
          }
        } catch (e) {
          _recommendedProduct = null;
        }

        notifyListeners();
      },
    );
  }

  Future<void> getHomeCategoryProductList(bool reload) async {
    if (_homeCategoryProductList.isEmpty || reload) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!
            .getHomeCategoryProductList(source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!
            .getHomeCategoryProductList(source: DataSourceEnum.client),
        onResponse: (data, _) {
          _homeCategoryProductList.clear();

          data.forEach((homeCategory) => _homeCategoryProductList
              .add(HomeCategoryProduct.fromJson(homeCategory)));

          notifyListeners();
        },
      );
    }
  }

  Future<void> getMostDemandedProduct() async {
    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => productServiceInterface!
          .getMostDemandedProduct(source: DataSourceEnum.local),
      fetchFromClient: () => productServiceInterface!
          .getMostDemandedProduct(source: DataSourceEnum.client),
      onResponse: (data, _) {
        try {
          _mostDemandedProductModel = MostDemandedProductModel.fromJson(data);
        } catch (e) {
          _mostDemandedProductModel = null;
        }

        notifyListeners();
      },
    );
  }

  Future<void> findWhatYouNeed() async {
    DataSyncHelper.fetchAndSyncData(
      fetchFromLocal: () => productServiceInterface!
          .getFindWhatYouNeed(source: DataSourceEnum.local),
      fetchFromClient: () => productServiceInterface!
          .getFindWhatYouNeed(source: DataSourceEnum.client),
      onResponse: (data, source) {
        try {
          _findWhatYouNeedModel = FindWhatYouNeedModel.fromJson(data);
        } catch (e) {
          _findWhatYouNeedModel = null;
        }

        notifyListeners();
      },
    );
  }

  ProductModel? _justForYouProductModel;
  ProductModel? get justForYouProductModel => _justForYouProductModel;

  Future<void> getJustForYouProduct(int offset,
      {bool isUpdate = true, int? limit}) async {
    if (offset == 1) {
      _justForYouProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: ProductType.justForYou,
            source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!.getProductModelByType(
            offset: offset,
            productType: ProductType.justForYou,
            source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _justForYouProductModel = ProductModel.fromJson(data);
          } finally {
            _justForYouProductModel = ProductModel(products: []);
          }
          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getProductModelByType<Response>(
              offset: offset,
              productType: ProductType.justForYou,
              source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        _justForYouProductModel?.totalSize = parsedProductModel.totalSize;
        _justForYouProductModel?.offset = parsedProductModel.offset;
        _justForYouProductModel?.products
            ?.addAll(parsedProductModel.products ?? []);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  ProductModel? _mostSearchingProduct;
  ProductModel? get mostSearchingProduct => _mostSearchingProduct;

  Future<void> getMostSearchingProduct(int offset,
      {bool isUpdate = true}) async {
    if (offset == 1) {
      _mostSearchingProduct = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!
            .getMostSearchingProductList(
                offset: offset, source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!
            .getMostSearchingProductList(
                offset: offset, source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _mostSearchingProduct = ProductModel.fromJson(data);
          } finally {
            _mostSearchingProduct = ProductModel(products: []);
          }
          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getMostSearchingProductList<Response>(
              offset: offset, source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        _mostSearchingProduct?.totalSize = parsedProductModel.totalSize;
        _mostSearchingProduct?.offset = parsedProductModel.offset;
        _mostSearchingProduct?.products
            ?.addAll(parsedProductModel.products ?? []);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  Future<void> getDiscountedProductList(int offset, bool reload,
      {bool isUpdate = true}) async {
    if (reload) {
      _discountedProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    ApiResponseModel apiResponse = await productServiceInterface!
        .getFilteredProductList(
            Get.context!, offset.toString(), ProductType.discountedProduct);

    if (apiResponse.response?.data != null &&
        apiResponse.response?.statusCode == 200) {
      if (offset == 1) {
        _discountedProductModel =
            ProductModel.fromJson(apiResponse.response?.data);
      } else {
        _discountedProductModel?.totalSize =
            ProductModel.fromJson(apiResponse.response?.data).totalSize;
        _discountedProductModel?.offset =
            ProductModel.fromJson(apiResponse.response?.data).offset;
        _discountedProductModel?.products?.addAll(
            ProductModel.fromJson(apiResponse.response?.data).products ?? []);
      }

      notifyListeners();
    } else {
      ApiChecker.checkApi(apiResponse);
    }
  }

  Future<void> getClearanceAllProductList(int offset,
      {bool isUpdate = true}) async {
    if (offset == 1) {
      _clearanceProductModel = null;

      if (isUpdate) {
        notifyListeners();
      }
    }

    if (offset == 1) {
      DataSyncHelper.fetchAndSyncData(
        fetchFromLocal: () => productServiceInterface!
            .getClearanceAllProductList(
                offset: offset, source: DataSourceEnum.local),
        fetchFromClient: () => productServiceInterface!
            .getClearanceAllProductList(
                offset: offset, source: DataSourceEnum.client),
        onResponse: (data, source) {
          try {
            _clearanceProductModel = ProductModel.fromJson(data);
          } catch (_) {
            _clearanceProductModel = ProductModel(products: [], offset: offset);
          }
          notifyListeners();
        },
      );
    } else {
      final ApiResponseModel? apiResponse =
          await productServiceInterface?.getClearanceAllProductList<Response>(
              offset: offset, source: DataSourceEnum.client);

      if (apiResponse?.response?.statusCode == 200) {
        final ProductModel parsedProductModel =
            ProductModel.fromJson(apiResponse?.response?.data);

        _clearanceProductModel?.totalSize = parsedProductModel.totalSize;
        _clearanceProductModel?.offset = parsedProductModel.offset;
        _clearanceProductModel?.products
            ?.addAll(parsedProductModel.products ?? []);
      } else {
        ApiChecker.checkApi(apiResponse!);
      }
      notifyListeners();
    }
  }

  ProductModel? clearanceSearchProductModel;
  bool isSearchLoading = false;
  bool isSearchActive = false;
  bool isFilterActive = false;
  Future<ApiResponseModel> getClearanceSearchProduct(
      {required String query,
      String? categoryIds,
      String? brandIds,
      String? authorIds,
      String? publishingIds,
      String? sort,
      String? priceMin,
      String? priceMax,
      required int offset,
      String? productType,
      String offerType = 'clearance_sale',
      bool fromPaginantion = false,
      isNotify = true}) async {
    if (!fromPaginantion && isNotify) {
      isSearchLoading = true;
      notifyListeners();
    }

    // if(reload) {
    //   sellerProduct = null;
    // }

    ApiResponseModel apiResponse = await productServiceInterface!
        .getClearanceSearchProducts(
            query,
            categoryIds,
            brandIds,
            authorIds,
            publishingIds,
            sort,
            priceMin,
            priceMax,
            offset,
            productType,
            offerType);
    if (apiResponse.response != null &&
        apiResponse.response!.statusCode == 200) {
      if (offset == 1) {
        // clearanceSearchProductModel = null;
        clearanceSearchProductModel =
            ProductModel.fromJson(apiResponse.response!.data);
      } else {
        clearanceSearchProductModel?.products?.addAll(
            ProductModel.fromJson(apiResponse.response!.data).products!);
        clearanceSearchProductModel?.offset =
            (ProductModel.fromJson(apiResponse.response!.data).offset!);
        clearanceSearchProductModel?.totalSize =
            ProductModel.fromJson(apiResponse.response!.data).totalSize;
      }
    } else {
      ApiChecker.checkApi(apiResponse);
    }

    isSearchLoading = false;

    notifyListeners();
    return apiResponse;
  }

  void setSearchText(String? value, {bool isUpdate = true}) {
    _searchText = value;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void toggleSearchActive() {
    isSearchActive = !isSearchActive;
    notifyListeners();
  }

  void disableSearch({bool isUpdate = true}) {
    clearanceSearchProductModel = null;
    isSearchActive = false;
    isSearchLoading = false;
    isFilterActive = false;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void updateSelectedCategoryId({required int id, bool isUpdate = true}) {
    _selectedCategoryId = id;
    if (isUpdate) {
      notifyListeners();
    }
  }

  void setCategorySearchProductText(String? value, {bool isUpdate = true}) {
    _categorySearchProductText = value;
    if (isUpdate) {
      notifyListeners();
    }
  }
}

class ProductTypeModel {
  String? title;
  ProductType productType;

  ProductTypeModel(this.title, this.productType);
}
